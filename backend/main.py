# backend/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
import firebase_admin
from firebase_admin import credentials, firestore, messaging

app = FastAPI(
    title="Smart Queue ML API",
    description="API for Urgency Classification and Waiting-Time Prediction",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---- Initialize Firebase Admin SDK ----
# Supports two ways of providing credentials:
#   1. Environment variable FIREBASE_CREDENTIALS (JSON string) -- used on Render
#   2. Local file firebase-service-account.json -- used on PC

SERVICE_ACCOUNT_PATH = "firebase-service-account.json"

try:
    cred = None

    # Option 1: env var (Render)
    env_creds = os.environ.get("FIREBASE_CREDENTIALS")
    if env_creds:
        try:
            import json as _json
            cred_dict = _json.loads(env_creds)
            cred = credentials.Certificate(cred_dict)
            print("Firebase Admin initialized from environment variable.")
        except Exception as e:
            print(f"WARNING: Failed to parse FIREBASE_CREDENTIALS env var: {e}")

    # Option 2: local file (PC)
    if cred is None and os.path.exists(SERVICE_ACCOUNT_PATH):
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        print("Firebase Admin initialized from file.")

    # Initialize if we got credentials from either source
    if cred is not None:
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase Admin ready.")
    else:
        print("WARNING: No Firebase credentials available.")
        db = None
except Exception as e:
    print(f"WARNING: Could not initialize Firebase Admin: {e}")
    db = None

URGENCY_MODEL_PATH = "urgency_model.joblib"
WAIT_TIME_MODEL_PATH = "waiting_time_model.joblib"

try:
    urgency_model = joblib.load(URGENCY_MODEL_PATH)
    wait_time_model = joblib.load(WAIT_TIME_MODEL_PATH)
    print("Models loaded successfully.")
except Exception as e:
    print(f"Error loading models: {e}")
    urgency_model = None
    wait_time_model = None


class UrgencyInput(BaseModel):
    temperature: float
    heartrate: float
    resprate: float
    o2sat: float
    sbp: float
    dbp: float
    pain: float
    gender: str
    race: str
    arrival_transport: str


class WaitTimeInput(BaseModel):
    Patient_Type: int
    Resourse_Used: str
    Utilization_Percent: float
    Queue_Count_Before_Processing: int
    hour: int


@app.get("/")
def read_root():
    return {"message": "Smart Queue ML API is running."}


@app.post("/predict/urgency")
def predict_urgency(data: UrgencyInput):
    if urgency_model is None:
        raise HTTPException(status_code=500, detail="Urgency model not loaded.")

    input_df = pd.DataFrame([{
        "temperature": data.temperature,
        "heartrate": data.heartrate,
        "resprate": data.resprate,
        "o2sat": data.o2sat,
        "sbp": data.sbp,
        "dbp": data.dbp,
        "pain": data.pain,
        "gender": data.gender,
        "race": data.race,
        "arrival_transport": data.arrival_transport
    }])

    prediction = urgency_model.predict(input_df)[0]
    probability = urgency_model.predict_proba(input_df)[0][1]

    return {
        "prediction": int(prediction),
        "probability": float(probability),
        "label": "Urgent" if prediction == 1 else "Not Urgent"
    }


@app.post("/predict/wait-time")
def predict_wait_time(data: WaitTimeInput):
    if wait_time_model is None:
        raise HTTPException(status_code=500, detail="Wait-time model not loaded.")

    input_df = pd.DataFrame([{
        "Patient Type": data.Patient_Type,
        "Resourse Used": data.Resourse_Used,
        "Utilization %": data.Utilization_Percent,
        "Queue Count Before Processing": data.Queue_Count_Before_Processing,
        "hour": data.hour
    }])

    prediction = wait_time_model.predict(input_df)[0]

    return {
        "predicted_wait_time_minutes": round(float(prediction), 2)
    }



# ============================================================
# FCM Notification Endpoint
# ============================================================

class NotifyRequest(BaseModel):
    title: str
    body: str


@app.post("/notify/patient/{user_id}")
def notify_patient(user_id: str, payload: NotifyRequest):
    """Send a push notification to the given user's FCM token."""
    if db is None:
        raise HTTPException(status_code=500, detail="Firebase Admin not initialized.")

    # Look up the user's FCM token
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found.")

    token = user_doc.to_dict().get("fcmToken")
    if not token:
        raise HTTPException(status_code=404, detail="User has no FCM token.")

    # Send the message
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=payload.title,
                body=payload.body,
            ),
            token=token,
        )
        response = messaging.send(message)
        return {"status": "sent", "message_id": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send: {e}")

