from fastapi import FastAPI, BackgroundTasks   #added BackgroundTasks to run things in the background
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore, messaging
from datetime import datetime
from typing import Optional

# Firebase Setup
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# FastAPI App 
app = FastAPI()

# Contact model (for nested contacts)
class Contact(BaseModel):
    name: str
    phone: str
    relationship: str
    device_token: Optional[str] = None

# SOSRequest model
class SOSRequest(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    contacts: list[Contact]

def send_multicast(tokens: list[str], title: str, body: str, data_payload: dict):
    if not tokens:
        print("No device tokens to notify.")
        return {"success": 0, "failure": 0}

    message = messaging.MulticastMessage(
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data_payload or {}).items()},
        tokens=tokens,
    )

    response = messaging.send_multicast(message)
    print("Notification result:", response.success_count, "success,", response.failure_count, "failure")
    return {"success": response.success_count, "failure": response.failure_count}


@app.get("/")
def root():
    return {"message": "Hello Tourio!"}


@app.post("/register-token")
def register_token(user_id: str, device_token: str):
    try:
        user_ref = db.collection("users").document(user_id)
        user_ref.set({"fcm_tokens": firestore.ArrayUnion([device_token])}, merge=True)
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}

@app.post("/sos")
def trigger_sos(request: SOSRequest, background_tasks: BackgroundTasks):
    # Save SOS event
    sos_event = {
        "user_id": request.user_id,
        "latitude": request.latitude,
        "longitude": request.longitude,
        "timestamp": datetime.utcnow(),
        "contacts": [c.dict() for c in request.contacts]
    }
    doc_ref = db.collection("sos_events").add(sos_event)
    sos_id = doc_ref[1].id

    # Collect tokens from request contacts
    tokens = [c.device_token for c in request.contacts if c.device_token]

    # Send notifications in background (so response is fast)
    if tokens:
        title = "SOS Alert!!"
        body = f"User {request.user_id} needs help near {request.latitude:.4f},{request.longitude:.4f}"
        data_payload = {"sos_id": sos_id}
        background_tasks.add_task(send_multicast, tokens, title, body, data_payload)

    return {"status": "SOS triggered", "id": sos_id}
