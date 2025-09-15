# tensorflow>=2.12, numpy
import tensorflow as tf
import numpy as np
import random

random.seed(42)
np.random.seed(42)
tf.random.set_seed(42)


MOODS = set()
WEATHERS =set()
CAT =set()
MAX_BUDGET = 300.0
LOCATIONS = [
    {"name":"Wadi Rum Adventure", "primary_mood":"adventurous", "cost":150, "weather_ok":["sunny","mild"], "cat":["hiking","nature"]},
    {"name":"Dead Sea Relax",     "primary_mood":"relaxed",     "cost":100, "weather_ok":["sunny","hot"], "cat":["beach"]},
    {"name":"Petra Heritage",     "primary_mood":"cultural",    "cost":200, "weather_ok":["sunny","mild"], "cat":["history","hiking","nature"]},
    {"name":"Amman Food Crawl",   "primary_mood":"relaxed",     "cost":80,  "weather_ok":["sunny","mild","rainy","hot"], "cat":["food","shopping"]},
    {"name":"Jerash Ruins",       "primary_mood":"cultural",    "cost":120, "weather_ok":["mild","sunny"], "cat":["history","nature"]},
    {"name":"Ajloun Forest Walk", "primary_mood":"adventurous", "cost":70,  "weather_ok":["mild","rainy"], "cat":["nature","hiking"]},
    {"name":"Aqaba Beach Day",    "primary_mood":"relaxed",     "cost":180, "weather_ok":["sunny","hot"], "cat":["beach","food"]},
    {"name":"Wadi Mujib Siq",     "primary_mood":"adventurous", "cost":90,  "weather_ok":["sunny","hot"], "cat":["hiking","nature"]},
    {"name":"Royal Auto Museum",  "primary_mood":"cultural",    "cost":60,  "weather_ok":["sunny","mild","rainy","hot"], "cat":["history"]},
    {"name":"Boulevard + Coffee", "primary_mood":"romantic",    "cost":50,  "weather_ok":["sunny","mild","rainy","hot"], "cat":["food","shopping"]},
    {"name":"King Abdullah Mosque","primary_mood":"cultural",   "cost":20,  "weather_ok":["sunny","mild","rainy","hot"], "cat":["history"]},
    {"name":"Rainbow Street",     "primary_mood":"relaxed",     "cost":40,  "weather_ok":["sunny","mild","rainy","hot"], "cat":["food","shopping"]},
]



for i in LOCATIONS:
    MOODS.add(i["primary_mood"])
    for j in i["weather_ok"]:
        WEATHERS.add(j)
    for j in i["cat"]:
        CAT.add(j)
MOODS = list(MOODS)
WEATHERS = list(WEATHERS)
CAT = list(CAT)
def hot(names, vocab):
    v = np.zeros(len(vocab), dtype=np.float32)
    for n in names:
        for i in range(len(vocab)):
            if vocab[i] == n:
                v[i] = 1
    return v

def encode_user(user):
    return np.concatenate([
        hot([user["mood"]], MOODS),
        hot([user["weather"]], WEATHERS),
        np.array([min(user["budget"], MAX_BUDGET) / MAX_BUDGET], dtype=np.float32),
        hot(user["interests"], CAT)
    ]).astype(np.float32)

def encode_loc(loc):
    return np.concatenate([
        hot([loc["primary_mood"]], MOODS),
        hot(loc["weather_ok"], WEATHERS),
        np.array([min(loc["cost"], MAX_BUDGET) / MAX_BUDGET], dtype=np.float32),
        hot(loc["cat"], CAT)
    ]).astype(np.float32)

def match_score(user,loc):
    mood = user["mood"]
    weather = user["weather"]
    budget = user["budget"]
    interests = set(user["interests"])
    mood_score = 1.0 if loc["primary_mood"] == mood else 0.2 
    weather_score = 1.0 if weather in loc["weather_ok"] else 0.2
    budget_score = 1.0 if budget >= loc["cost"] else 0.1
    if len(interests) > 0:
        interest_score = len(interests.intersection(loc["cat"])) / len(interests)
    else:
        interest_score = 0
    score = 0.3*mood_score + 0.2*weather_score + 0.2*budget_score + 0.3*interest_score
    return score

def random_user():
    mood = random.choice(MOODS)
    weather = random.choice(WEATHERS)
    budget = random.randint(20,250)
    interests = random.sample(CAT, random.randint(1,3))
    return {"mood": mood, "weather": weather, "budget": budget, "interests": interests}

def build_dataset(num = 4000):
    loc_user = []
    scores = []
    for i in range(num):
        user = random_user()
        user_vec = encode_user(user)
        for loc in LOCATIONS:
            loc_vec = encode_loc(loc)
            score = match_score(user,loc)
            loc_user.append(np.concatenate([user_vec,loc_vec]))
            if score >= 0.97:
                score -= np.random.normal(0,0.015)
            else:
                score += np.random.normal(0,0.015)
            scores.append(score)
        
    return np.array(loc_user,dtype = np.float32), np.array(scores,dtype = np.float32)

loc_user,scores = build_dataset() 



indicies = np.arange(len(scores))
np.random.shuffle(indicies)
split = int(0.9*len(scores))
loc_user_train,scores_train = loc_user[indicies[:split]] , scores[indicies[:split]]
loc_user_val,scores_val = loc_user[indicies[split:]] , scores[indicies[split:]]

model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(loc_user.shape[1],)),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])
model.compile(optimizer='adam', loss='mse', metrics=['mae'])
history = model.fit(loc_user_train,scores_train, validation_data=(loc_user_val,scores_val), epochs=10, batch_size=256, verbose=0)

def prefilter(user, budgetpadding = 1.1):
    kept = []
    for loc in LOCATIONS:
        if user["weather"] not in loc["weather_ok"]:
            continue
        if loc["cost"] > (user["budget"] * budgetpadding):
            continue
        kept.append(loc)
    return kept if kept else LOCATIONS


def score_items_user(user):
    uservec = encode_user(user)
    filtered = prefilter(user)
    batch = []
    for loc in filtered:
        batch.append(np.concatenate([uservec,encode_loc(loc)]))
    batch = np.array(batch, dtype=np.float32)
    scores = model.predict(batch,verbose = 0).reshape(-1)
    rank = sorted(zip(filtered,scores), key = lambda t : t[1], reverse= True)
    return rank



def build_locs(user, days, options):
    ranked = score_items_user(user)
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
            y = {"name": x[0]["name"], "score": float(x[1]), "cost": x[0]["cost"], "weather_ok": x[0]["weather_ok"], "cat": x[0]["cat"], "mood":x[0]["primary_mood"]}
            locs[d]["options"].append(y)
    return locs

def demonstration(user,days = 2, options = 3):
    locs = build_locs(user,days,options)
    print("\nUser Prefrences:",user)
    for day in locs:
        print("Day ",day["day"],":" , sep = "")
        for option in day["options"]:
            print("\t- ",option["name"],", Cost: ~", option["cost"]," JD, Mood: ",option["mood"],", Acceptable Weather: ", option["weather_ok"], ", Categories: ", option["cat"], "\n\t - Score: ", option["score"], sep = "")
    
demonstration({"mood":"adventurous","weather":"sunny","budget":120,"interests":["hiking","nature"]})
demonstration({"mood":"relaxed","weather":"hot","budget":90,"interests":["food","beach"]})
demonstration({"mood":"cultural","weather":"mild","budget":70,"interests":["history","food"]})


# TO DO:
 
# BUDGET OF EACH LOCATION (USER) WILL BE CALCULATED BY TOTAL BUDGET / DAYS*USEDOPTIONS
# GROUP THE FINAL DAYS*OPTIONS LOCATIONS BY THEIR DISTANCES FROM EACH OTHER INTO DAYS
# THEN HAVE THE DAY ORDER (1,2,3,...) BE DETERMINED BY A LOGICAL ORDER OF LIMITING DISTANCE TRAVELLED
# SO YOU DONT GO FROM AQABA TO IRBID TO AMMAN
# BUT RATHER AQABA TO AMMAN TO IRBID
