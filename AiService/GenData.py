import random
import firebase_admin
from firebase_admin import credentials,firestore
cred = credentials.Certificate("new tourio key python.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


MOODS = ["Calm","Romantic","Adventurous","Spontaneous",
         "Festive","Casual","Exploratory","Tired",
         "Cozy","Hungry","Curious","Creative", "Bored"]
WEATHERS = ["Sunny", "Hot", "Raining","Cloudy","Cold","Snow","Humid"]
CAT = ["Food & Drink","Nature/Outdoors","Culture/History","Art",
       "Adventure","Shopping","Spirituality","Festivals",
       "Wellness","Local Life","Sports","Spa & Beauty"]
MAX_BUDGET = 300


def generate_rand_location(id):
    mood = random.sample(MOODS,random.randint(1,3))
    weather = random.choice(WEATHERS)
    cost = random.randint(20,250)
    categories = random.sample(CAT, random.randint(1,3))
    lat = random.uniform(29.3711572359193,32.41564584687414)
    lon = random.uniform(35.61400818573995,36.340664462085215)
    return {"name": id,"mood": mood, "weather_ok": weather, "cost": cost, "cat": categories,"lat":lat,"lon":lon}


for i in range(1,101):
    loc = generate_rand_location(i)
    db.collection("Locations").document(str(i)).set(loc)
    print("Added document with ID: ",i)

