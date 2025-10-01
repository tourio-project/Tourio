# tensorflow>=2.12, numpy
import tensorflow as tf
import numpy as np
import firebase_admin
from GenData import random_user
from AItrain import encode_loc,encode_user

if not firebase_admin._apps:
    cred = firebase_admin.credentials.Certificate("new tourio key python.json")
    firebase_admin.initialize_app(cred)
db = firebase_admin.firestore.client()
loc_db = db.collection("Training_Locations").stream()
# Once we get a good database of actual locations we can use them instead of the training locations
#loc_db = db.collection("Locations").stream()
LOCATIONS = []
for loc in loc_db:
    LOCATIONS.append(loc.to_dict())

model = tf.keras.models.load_model("TourioModel.keras")

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
    ind = 0
    for d in range(days):
        locs.append({
            "day": d+1,
            "options": []
        })
        for i in range(options):
            x = ranked[ind]
            ind+=1
            y = {"name": x[0]["name"], "score": float(x[1]), "cost": x[0]["cost"], "weather_ok": x[0]["weather_ok"], "cat": x[0]["cat"], "mood":x[0]["mood"]}
            locs[d]["options"].append(y)
    return locs

def demonstration(user,days = 2, options = 3):
    locs = build_locs(user,days,options)
    print("\nUser Prefrences:",user)
    for day in locs:
        print("Day ",day["day"],":" , sep = "")
        for option in day["options"]:
            print("\t- ",option["name"],", Cost: ~", option["cost"]," JD, Mood: ",option["mood"],", Acceptable Weather: ", option["weather_ok"], ", Categories: ", option["cat"], "\n\t - Score: ", option["score"], sep = "")
    
demonstration(random_user())
demonstration(random_user())
demonstration(random_user())


# TO DO:
 
# BUDGET OF EACH LOCATION (USER) WILL BE CALCULATED BY TOTAL BUDGET / DAYS*USEDOPTIONS
# GROUP THE FINAL DAYS*OPTIONS LOCATIONS BY THEIR DISTANCES FROM EACH OTHER INTO DAYS
# THEN HAVE THE DAY ORDER (1,2,3,...) BE DETERMINED BY A LOGICAL ORDER OF LIMITING DISTANCE TRAVELLED
# SO YOU DONT GO FROM AQABA TO IRBID TO AMMAN
# BUT RATHER AQABA TO AMMAN TO IRBID
