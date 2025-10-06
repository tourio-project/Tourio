 # **Tourio**

Tourio is a smart travel companion application that helps users plan and manage their trips. It combines AI-based planning, live data, and safety features to create a smooth and reliable travel experience.

## Design
[![Figma Design](https://img.shields.io/badge/Figma-Design-blue?logo=figma)](https://www.figma.com/file/Zaen0sR7mtfpdEhu1beEey/Tourio?type=design&node-id=0%3A1&mode=design&t=sjqqiXtqNg2a94RO-1)

## Features

- **AI Mood-Based Trip Planner**

  AI Based trip planner that uses the users mood/s, interests, budget, and the weather to plan a viable trip which pioritizes user experience
  Used a Tensorflow based Neural Network to score how good a certian location would be for the use
  Uses location based clustering to cluster together close areas so each potential option isnt too far from the others 


- **Trending Now**  
  Automatically scrapes upcoming events from [calendar.jo](https://calendar.jo) every 24 hours.  
  The data is stored in Firebase Firestore and served through a FastAPI endpoint (`/trending`) for the frontend to fetch and display real-time event data.

- **Emergency Assistant & Safety Alerts**  
  Offers one-tap SOS functionality and auto-translated emergency phrases for traveler safety.


## Setup & Integration Instructions

<details>
<summary><b>AI Mood-Based Trip Planner</b></summary>

**Backend:** `ai-planner-service`  

**Setup Steps:**
1. Navigate to the Project Directory and Activate the Virtual Environment:

```bash
cd /Users/mayaryasein/Downloads/tourio_clean
source backend_api/.venv-api/bin/activate
```
2. Point to your actual Firebase key (the file is inside backend_api/):

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/backend_api/new_tourio_key_python.json"
```

3. Tell the API where the model file is:

```bash
export TOURIO_MODEL_PATH="$(pwd)/backend_api/TourioModel.keras"
```

4. Make sure we read from the right Firestore collection:

```bash
export TOURIO_LOC_COLLECTION="Locations"
```

5. Start the API on the port you’re using:
```bash
uvicorn backend_api.app:app --host 0.0.0.0 --port 8130 --reload
```

You might have to change the port number, then open this link with the correct port:
http://127.0.0.1:8127/docs#/

If you change the port number, make sure to also update the URL in:
lib/services/api.dart


</details>

<details>
<summary><b>Trending Now</b></summary>

**Backend:** `trending-service`  


**To activate the scraper, run the following commands in your terminal:**
```bash
cd "/Users/mayaryasein/Downloads/tourio_clean/backend_api"
source backend_api/.venv-api/bin/activate
pip install -r backend_api/requirements.txt   # (Run once)
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/backend_api/new_tourio_key_python.json"
uvicorn backend_api.Event_Scraper:app --host 0.0.0.0 --port 8000 --reload
```
</details>



## Developers

| Name            | Role / Contributions |
|-----------------|----------------------|
| **Mira Diab**   | Backend (Trending Now, Emergency Service), UI Design (Figma), Documentation |
| **Mayar Hasan** | UI Design (Figma), Frontend, Frontend–Backend Integration |
| **Nasser Zalloum** | Database |
| **Omar Salman** | Data Generation, Backend (AI Mood-Based Trip Planner) |
| **Marwan Shashtari** | Frontend |

