# tensorflow>=2.12, numpy
import tensorflow as tf
import numpy as np
import firebase_admin
from AItrain import encode_loc,encode_user
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import requests
from sklearn.cluster import KMeans
from fastapi import HTTPException
if not firebase_admin._apps:
    cred = firebase_admin.credentials.Certificate("new tourio key python.json")
    firebase_admin.initialize_app(cred)
db = firebase_admin.firestore.client()
#loc_db = db.collection("Training_Locations").stream()
# Once we get a good database of actual locations we can use them instead of the training locations
loc_db = db.collection("Locations").stream()
LOCATIONS = []
for loc in loc_db:
    LOCATIONS.append(loc.to_dict())

model = tf.keras.models.load_model("TourioModel.keras")

app = FastAPI()

def prefilter(user,numlocs, budgetpadding = 1.1):
    kept = []
    for loc in LOCATIONS:
        if user["weather"] not in loc["weather_ok"]:
            continue
        if loc["cost"] > (user["budget"] * budgetpadding):
            continue
        kept.append(loc)
    return kept if len(kept) >= numlocs else LOCATIONS


def score_items_user(user,numlocs):
    uservec = encode_user(user)
    filtered = prefilter(user,numlocs)
    batch = []
    for loc in filtered:
        batch.append(np.concatenate([uservec,encode_loc(loc)]))
    batch = np.array(batch, dtype=np.float32)
    scores = model.predict(batch,verbose = 0).reshape(-1)
    rank = sorted(zip(filtered,scores), key = lambda t : t[1], reverse= True)
    return rank


def build_locs(user, days, options):
    ranked = score_items_user(user,days*options)
    locs = []
    for loc, score in ranked[:days*options]:
        loc_copy = loc.copy()
        loc_copy["score"] = float(score)
        locs.append(loc_copy)
    coords = np.array([[loc["lat"], loc["lon"]] for loc in locs])
    kmeans = KMeans(n_clusters=days, n_init="auto").fit(coords)
    labels = kmeans.labels_
    clustered = {}
    for loc, label in zip(locs, labels):
        clustered.setdefault(label, []).append(loc)
    remaining_locs = locs.copy()
    result = []
    for c in clustered:
        cluster_locs = sorted(clustered[c], key=lambda x: x["score"], reverse=True)[:options]
        for l in cluster_locs:
            if l in remaining_locs:
                remaining_locs.remove(l)
        while len(cluster_locs) < options and remaining_locs:
            cluster_locs.append(remaining_locs.pop(0))
        result.append(cluster_locs)

    return result


def get_current_weather(city="Amman"):
    API_KEY = "e6191c5044b20c7561af031c996b5250"
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"
    try:
        r = requests.get(url, timeout=5).json()
        if "weather" in r and len(r["weather"]) > 0:
            return r["weather"][0]["main"]
        else:
            print("Weather API response unexpected:", r)
            return "Clear"
    except Exception as e:
        print("Weather API failed:", e)
        return "Clear"

class UserPreferences(BaseModel):
    moods: List[str]
    budget: int
    interests: List[str]
    days : int
    options : int


@app.post("/recommend")
def recommend_trips(prefs: UserPreferences):
    days = prefs.days
    options = prefs.options
    try:
        locsscore = build_locs({"mood": prefs.moods, "weather": get_current_weather(), "budget":prefs.budget / (days*options), "interests" : prefs.interests}, days, options)
    except:
        raise HTTPException(status_code=500, detail=f"Error building recommendations!")
    return {"rec" : locsscore}
