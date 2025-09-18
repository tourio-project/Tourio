import requests
from bs4 import BeautifulSoup
import csv
import schedule
import time
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI
import uvicorn

# Firebase Setup
# Replace with path to service account JSON (from nasser)
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
events_collection = db.collection("trending_events")

#The scraping part
def scrape_calendar():
    print(f"[{datetime.now()}] Starting...")

    URL = "https://calendar.jo/"
    response = requests.get(URL)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    events = []

    for card in soup.select("div.ceventbox"):
        title = card.select_one("div.desc h4 a")
        date = card.select_one("span.datespan")
        location = card.select_one("div.eventbottom")

        events.append({
            "Title": title.get_text(strip=True) if title else "",
            "Date": date.get_text(strip=True) if date else "",
            "Location": location.get_text(strip=True) if location else ""
        })

    #Saves results to CSV
    with open("events.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["Title", "Date", "Location"])
        writer.writeheader()
        writer.writerows(events)

    print(f"[{datetime.now()}] Done! Scraped {len(events)} events. Saved to events.csv")


#Schedule it to run once every 24 hours for renewing events
schedule.every(24).hours.do(scrape_calendar)

#Runs immediately the first time
scrape_calendar()

#Keeps the script alive
while True:
    schedule.run_pending()
    time.sleep(60)  #checks every minute
