import requests
from bs4 import BeautifulSoup
import schedule
import time
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI
import uvicorn


# FIREBASE SETUP:
# This part connects our Python app to Firebase Firestore,
# which is the database we are using to store the scraped events.
# We use a "firebase-key.json" file (the secret key we got from Firebase)
# to authenticate securely and then create a reference to a collection
# called "trending_events" where all the event data will go.
cred = credentials.Certificate("new_tourio_key_python.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
events_collection = db.collection("trending_events")


# SCRAPER:
# This function visits calendar.jo, downloads the webpage,
# and uses BeautifulSoup to find the event title, date, and location.
# Then, for each event, it saves the details into Firestore.
def scrape_calendar():
    print(f"[{datetime.now()}] Starting...")

    URL = "https://calendar.jo/"
    response = requests.get(URL)
    response.raise_for_status()  # stops the code if the site is unreachable

    soup = BeautifulSoup(response.text, "html.parser")
    events = []

    # Each event is inside a "ceventbox" div on the site
    for card in soup.select("div.ceventbox"):
        title = card.select_one("div.desc h4 a")
        date = card.select_one("span.datespan")
        location = card.select_one("div.eventbottom")

        # Clean up the text and prepare the event data
        event_data = {
            "Title": title.get_text(strip=True) if title else "",
            "Date": date.get_text(strip=True) if date else "",
            "Location": location.get_text(strip=True) if location else ""
        }
        events.append(event_data)

        # Use a unique ID (Title + Date) so if the event already exists, it gets updated
        doc_id = f"{event_data['Title']}_{event_data['Date']}"
        events_collection.document(doc_id).set(event_data)

    print(f"[{datetime.now()}] Done! Scraped {len(events)} events. Saved to Firebase")


# FASTAPI ENDPOINT:
# FastAPI lets us easily create an API for our data.
# This endpoint (/trending) will let anyone (like the frontend team)
# fetch all the events stored in Firestore as JSON.
app = FastAPI()

@app.get("/trending")
def get_trending():
    docs = events_collection.stream()
    events = [doc.to_dict() for doc in docs]
    return {"events": events}


# SCHEDULER:
# We want our scraper to run every 24 hours automatically,
# so the events in our database always stay fresh.
# The first run happens immediately when the script starts,
# and then the scheduler keeps it going in the background.
schedule.every(24).hours.do(scrape_calendar)
scrape_calendar()  # run once on startup

def run_scheduler():
    while True:
        schedule.run_pending()
        time.sleep(60)


# MAIN:
# "entry point" of the app.
# When we run this file with `python scraper.py`, this part executes:
# - Start the scheduler in a separate thread (so scraping runs in background)
# - Start the FastAPI server (so frontend/devs can call the /trending endpoint)
if __name__ == "__main__":
    import threading
    threading.Thread(target=run_scheduler, daemon=True).start()
    uvicorn.run(app, host="0.0.0.0", port=8000)
    