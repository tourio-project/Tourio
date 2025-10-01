import tensorflow as tf
import numpy as np
import firebase_admin
from firebase_admin import firestore
from scipy.stats import spearmanr
from GenData import random_user

def hot(names, vocab):
    v = np.zeros(len(vocab), dtype=np.float32)
    for n in names:
        for i in range(len(vocab)):
            if vocab[i] == n:
                v[i] = 1
    return v

def encode_user(user):
    return np.concatenate([
        hot(user["mood"], MOODS),
        hot([user["weather"]], WEATHERS),
        np.array([min(user["budget"], MAX_BUDGET) / MAX_BUDGET], dtype=np.float32),
        hot(user["interests"], CAT)
    ]).astype(np.float32)

def encode_loc(loc):
    return np.concatenate([
        hot(loc["mood"], MOODS),
        hot(loc["weather_ok"], WEATHERS),
        np.array([min(loc["cost"], MAX_BUDGET) / MAX_BUDGET], dtype=np.float32),
        hot(loc["cat"], CAT)
    ]).astype(np.float32)


def match_score(user,loc):
    mood = set(user["mood"])
    weather = user["weather"]
    budget = user["budget"]
    interests = set(user["interests"])
    if len(mood) > 0:
        mood_score = len(mood.intersection(loc["mood"])) / len(mood)
    else:
        mood_score = 0
    weather_score = 1.0 if weather in loc["weather_ok"] else 0.2
    budget_score = 1.0 if budget >= loc["cost"] else 0.2
    if len(interests) > 0:
        interest_score = len(interests.intersection(loc["cat"])) / len(interests)
    else:
        interest_score = 0
    score = 0.35*mood_score + 0.1*weather_score + 0.2*budget_score + 0.35*interest_score
    return score

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

MOODS = ["Calm","Romantic","Adventurous","Spontaneous",
            "Festive","Casual","Exploratory","Tired",
            "Cozy","Hungry","Curious","Creative", "Bored"]
WEATHERS = ["Sunny", "Hot", "Raining","Cloudy","Cold","Snow","Humid"]
CAT = ["Food & Drink","Nature/Outdoors","Culture/History","Art",
        "Adventure","Shopping","Spirituality","Festivals",
        "Wellness","Local Life","Sports","Spa & Beauty"]
MAX_BUDGET = 300.0
if __name__ == "__main__":
    if not firebase_admin._apps:
        cred = firebase_admin.credentials.Certificate("new tourio key python.json")
        firebase_admin.initialize_app(cred)
    db =firestore.client()
    loc_db = db.collection("Training_Locations").stream()
    LOCATIONS = []
    for loc in loc_db:
        LOCATIONS.append(loc.to_dict())
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
    test_data,test_scores = build_dataset(1000)
    y_pred = model.predict(test_data, verbose=0).reshape(-1)
    corr,_ = spearmanr(test_scores, y_pred)
    if corr is None: 
        corr = 0.0
    print(f"Spearman correlation: {corr:.4f}")

    model.save("TourioModel.keras")


