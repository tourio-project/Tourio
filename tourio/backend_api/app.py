
import os
from typing import List, Dict, Any

import numpy as np
import requests
import tensorflow as tf
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import firebase_admin
from firebase_admin import credentials, firestore


from .AItrain import encode_user, encode_loc



GOOGLE_CRED = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "new_tourio_key_python.json")
OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
LOC_COLLECTION = os.getenv("TOURIO_LOC_COLLECTION", "Locations").strip()


_MODEL_ENV = os.getenv("TOURIO_MODEL_PATH", "TourioModel.keras")
MODEL_CANDIDATES: List[str] = []


MODEL_CANDIDATES.append(_MODEL_ENV)

_here = os.path.dirname(__file__)
MODEL_CANDIDATES.append(os.path.join(_here, _MODEL_ENV))
MODEL_CANDIDATES.append(os.path.join(_here, "TourioModel.keras"))
MODEL_CANDIDATES.append("TourioModel.keras")



if not firebase_admin._apps:
    try:
        cred = credentials.Certificate(GOOGLE_CRED)
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"[WARN] Firebase init failed with '{GOOGLE_CRED}': {e}")

try:
    db = firestore.client()
except Exception as e:
    print(f"[WARN] Firestore client unavailable: {e}")
    db = None

print(f"[CFG] Using Firestore collection: {LOC_COLLECTION}")


LOCATIONS: List[Dict[str, Any]] = []
if db:
    try:
        docs = db.collection(LOC_COLLECTION).stream()
        LOCATIONS = [d.to_dict() for d in docs]
        print(f"[INFO] Loaded {len(LOCATIONS)} docs from '{LOC_COLLECTION}'")
    except Exception as e:
        print(f"[WARN] Failed to load '{LOC_COLLECTION}': {e}")

print(f"[INFO] Total locations loaded: {len(LOCATIONS)}")


MODEL = None
_last_err = None
for path in MODEL_CANDIDATES:
    try:
        if os.path.exists(path):
            MODEL = tf.keras.models.load_model(path)
            print(f"[INFO] Loaded model from: {path}")
            break
    except Exception as e:
        _last_err = e
if MODEL is None:
    raise RuntimeError(f"Could not load model. Tried: {MODEL_CANDIDATES}. Last error: {_last_err}")



app = FastAPI(title="Tourio Recommender API", version="1.0.0")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],         
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_current_weather(city: str = "Amman") -> str:
    """Return a simple weather label compatible with your model."""
    if not OPENWEATHER_API_KEY:
        return "Clear"
    try:
        r = requests.get(
            "https://api.openweathermap.org/data/2.5/weather",
            params={"q": city, "appid": OPENWEATHER_API_KEY, "units": "metric"},
            timeout=5,
        )
        data = r.json()
        if "weather" in data and data["weather"]:
            return data["weather"][0].get("main", "Clear")
    except Exception as e:
        print(f"[WARN] Weather fetch failed for '{city}': {e}")
    return "Clear"


def prefilter(user: Dict[str, Any], numlocs: int, budgetpadding: float = 1.5) -> List[Dict[str, Any]]:
    """
    Permissive filter so we don't collapse to a single item:
    - If weather_ok exists and user weather NOT in it => drop.
      If weather_ok missing/empty => treat as OK.
    - If cost exists and exceeds padded per-slot budget => drop.
      If cost missing/invalid => treat as OK.
    - Only return filtered set if it's "big enough"; else return ALL LOCATIONS
      and let the model rank.
    """
    if not LOCATIONS:
        return []

    kept: List[Dict[str, Any]] = []
    for loc in LOCATIONS:
        try:
            woks = loc.get("weather_ok")
            if woks and user["weather"] not in woks:
                continue

            cost = loc.get("cost", None)
            if cost not in (None, "", 0, 0.0):
                try:
                    if float(cost) > float(user["budget"]) * budgetpadding:
                        continue
                except Exception:
                    pass

            kept.append(loc)
        except Exception:
            kept.append(loc)

    threshold = max(3, numlocs)
    return kept if len(kept) >= threshold else LOCATIONS


def score_items_user(user: Dict[str, Any], numlocs: int) -> List[tuple]:
    """Build [user||loc] vectors, predict scores, return list[(loc, score)] sorted desc."""
    filtered = prefilter(user, numlocs)
    if not filtered:
        return []

    uservec = encode_user(user)

    batch: List[np.ndarray] = []
    safe: List[Dict[str, Any]] = []
    for loc in filtered:
        try:
            lv = encode_loc(loc)
            batch.append(np.concatenate([uservec, lv]))
            safe.append(loc)
        except Exception:
            continue

    if not batch:
        return []

    arr = np.array(batch, dtype=np.float32)
    scores = MODEL.predict(arr, verbose=0).reshape(-1)

    ranked = sorted(zip(safe, scores), key=lambda t: t[1], reverse=True)

    print(
        f"[DBG] weather={user['weather']}, total={len(LOCATIONS)}, "
        f"filtered={len(filtered)}, ranked={len(ranked)}, need={numlocs}"
    )
    return ranked


def cluster_by_day(locs: List[Dict[str, Any]], days: int, options: int) -> List[List[Dict[str, Any]]]:
    """
    Cluster top locs into 'days' via KMeans(lat,lon) when possible.
    Always tries to fill each day with up to 'options' items; falls back gracefully.
    """
    if not locs:
        return [[] for _ in range(days)]


    coords: List[List[float]] = []
    for loc in locs:
        try:
            coords.append([float(loc.get("lat", 0.0)), float(loc.get("lon", 0.0))])
        except Exception:
            coords.append([0.0, 0.0])

    n_samples = len(coords)
    n_clusters = min(days, max(1, n_samples))
    labels = [0] * n_samples

    try:
        from sklearn.cluster import KMeans
        kmeans = KMeans(n_clusters=n_clusters, n_init=10, random_state=42).fit(np.array(coords, dtype=np.float32))
        labels = list(kmeans.labels_)
    except Exception as e:
        print(f"[WARN] KMeans failed, using simple fill: {e}")

    buckets: Dict[int, List[Dict[str, Any]]] = {}
    for loc, lab in zip(locs, labels):
        buckets.setdefault(int(lab), []).append(loc)

    remaining = locs.copy()
    result: List[List[Dict[str, Any]]] = []
    for k in sorted(buckets.keys()):
        day = sorted(buckets[k], key=lambda x: x.get("score", 0.0), reverse=True)[:options]
        for l in day:
            if l in remaining:
                remaining.remove(l)
        while len(day) < options and remaining:
            day.append(remaining.pop(0))
        result.append(day)

    while len(result) < days:
        day = []
        while len(day) < options and remaining:
            day.append(remaining.pop(0))
        result.append(day)

    return result



class UserPreferences(BaseModel):
    moods: List[str]
    budget: int
    interests: List[str]
    days: int
    options: int
    city: str | None = "Amman"



@app.get("/ping")
def ping():
    return {"ok": True}


@app.post("/recommend")
def recommend_trips(prefs: UserPreferences):
    """
    Returns: { "rec": List[List[location]], "weather_used": str }
    - rec[i] is the list of recommended locations for day i+1 (length <= options)
    """
    if MODEL is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    if not LOCATIONS:
        raise HTTPException(status_code=500, detail="No locations available")

    days = int(prefs.days)
    options = int(prefs.options)
    if days <= 0 or options <= 0:
        raise HTTPException(status_code=400, detail="days and options must be positive integers")

    try:
        per_slot = max(1, days * options)
        weather = get_current_weather(prefs.city or "Amman")
        user = {
            "mood": prefs.moods,
            "weather": weather,
            "budget": float(prefs.budget) / float(per_slot), 
            "interests": prefs.interests,
        }

        ranked = score_items_user(user, days * options)
        top: List[Dict[str, Any]] = []
        for loc, score in ranked[: days * options]:
            item = dict(loc)
            item["score"] = float(score)
            top.append(item)

        grouped = cluster_by_day(top, days, options)
        return {"rec": grouped, "weather_used": weather}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error building recommendations: {e}")

