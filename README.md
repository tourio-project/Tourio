# Tourio

Tourio is a smart travel companion application that helps users plan and manage their trips. It combines AI-based planning, live data, and safety features to create a smooth and reliable travel experience.

---

## Features

- **AI Mood-Based Trip Planner**  
  AI-driven itinerary generation based on mood, preferences, and live weather data.

- **Trending Now (Backend: Mira)**  
  Automatically scrapes upcoming events from [calendar.jo](https://calendar.jo) every 24 hours.  
  The data is stored in Firebase Firestore and served through a FastAPI endpoint (`/trending`) for the frontend to fetch and display real-time event data.

- **Integrated Public Transport**  
  Provides live transport information and AI-powered route suggestions for efficient travel planning.

- **Emergency Assistant & Safety Alerts**  
  Offers one-tap SOS functionality and auto-translated emergency phrases for traveler safety.

---

## Setup & Integration Instructions

<details>
<summary><b>AI Mood-Based Trip Planner</b></summary>

**Backend:** `ai-planner-service`  
**Frontend:** Flutter  

**Setup Steps:**
1. Run the FastAPI backend on port `8000`.  
2. Add your OpenWeatherMap API key to the `.env` file.  
3. In Flutter, call the `/plan-trip` endpoint to retrieve AI-generated itineraries.

</details>

---

<details>
<summary><b>Trending Now (Mira)</b></summary>

**Backend:** `trending-service`  
**Purpose:** Scrapes event data from [calendar.jo](https://calendar.jo) every 24 hours and serves it via `/trending`.  

**To activate the scraper, run the following commands in your terminal:**
```bash
cd "/Users/mayaryasein/Downloads/tourio_clean/backend_api"
source backend_api/.venv-api/bin/activate
pip install -r backend_api/requirements.txt   # (Run once)
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/backend_api/new_tourio_key_python.json"
uvicorn backend_api.Event_Scraper:app --host 0.0.0.0 --port 8000 --reload
