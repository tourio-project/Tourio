import random
if __name__ == "__main__":
    import firebase_admin
    from firebase_admin import firestore
    if not firebase_admin._apps:
        cred = firebase_admin.credentials.Certificate("new tourio key python.json")
        firebase_admin.initialize_app(cred)
    db = firestore.client()

MOODS = ["Calm","Romantic","Adventurous","Spontaneous",
            "Festive","Casual","Exploratory","Tired",
            "Cozy","Hungry","Curious","Creative", "Bored"]
WEATHERS = [
    "Thunderstorm", "Drizzle", "Rain", "Snow",
    "Mist", "Smoke", "Haze", "Dust",
    "Sand", "Ash", "Squall", "Tornado",
    "Clear", "Clouds"
]
CAT = ["Food & Drink","Nature/Outdoors","Culture/History","Art",
        "Adventure","Shopping","Spirituality","Festivals",
        "Wellness","Local Life","Sports","Spa & Beauty"]
MAX_BUDGET = 300


def random_location(id):
    mood = random.sample(MOODS,random.randint(1,3))
    weather = random.sample(WEATHERS,random.randint(1,3))
    cost = random.randint(20,250)
    categories = random.sample(CAT, random.randint(1,3))
    lat = random.uniform(29.3711572359193,32.41564584687414)
    lon = random.uniform(35.61400818573995,36.340664462085215)
    return {"name": id,"mood": mood, "weather_ok": weather, "cost": cost, "cat": categories,"lat":lat,"lon":lon}

def generate_locs(n):
    for i in range(1,n+1):
        loc = random_location(i)
        db.collection("Training_Locations").document(str(i)).set(loc)
        print("Added location with ID: ",i)

def random_user():
    mood = random.sample(MOODS,random.randint(1,3))
    weather = random.choice(WEATHERS)
    budget = random.randint(20,250)
    interests = random.sample(CAT, random.randint(1,3))
    return {"mood": mood, "weather": weather, "budget": budget, "interests": interests}
