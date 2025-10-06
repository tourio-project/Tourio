 # Tourio

Tourio is a smart travel companion application that helps users plan and manage their trips. It combines AI-based planning, live data, and safety features to create a smooth and reliable travel experience.

---

## Features

- **AI Mood-Based Trip Planner**  


- **Trending Now (Backend: Mira)**  
  Automatically scrapes upcoming events from [calendar.jo](https://calendar.jo) every 24 hours.  
  The data is stored in Firebase Firestore and served through a FastAPI endpoint (`/trending`) for the frontend to fetch and display real-time event data.

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
```
</details>
---

## Design
[![Figma Design](https://img.shields.io/badge/Figma-Design-blue?logo=figma)](https://www.figma.com/file/Zaen0sR7mtfpdEhu1beEey/Tourio?type=design&node-id=0%3A1&mode=design&t=sjqqiXtqNg2a94RO-1)


## Developers

| Name            | Role / Contributions |
|-----------------|----------------------|
| **Mira Diab**   | Backend (Trending Now, Emergency Service) & UI Design (Figma) |
| **Mayar Hasan** | UI Design (Figma), Frontend–Backend Integration |
| **Nasser**      | Database |
| **Omar Salman** | Data Generation, Backend (AI Mood-Based Trip Planner) |
| **Marwan Shashtari** | Frontend |

