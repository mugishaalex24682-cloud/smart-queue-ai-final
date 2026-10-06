# Smart Queue AI

**AI-Assisted Mobile Smart Queue Management System for Hospitals in Kabale, Uganda**

Full-stack machine learning application for hospital patient flow, urgency classification, and waiting-time prediction.

## Authors

- MUGISHA ALEX — 2024/A/KCS/5461/F
- AHURIRA LUCKY — 2024/A/KCS/5197/G/F

Kabale University — Bachelor of Computer Science
Course: BCS3101 — Basics of Machine Learning
Academic Year: 2025/2026

## Features

Patient App: register/login, join queue, AI urgency classification, real-time position, push notifications, book appointments.

Staff Dashboard: live queue, call next patient, ML wait-time prediction.

Admin Dashboard: live stats, patient list, appointment analytics, staff management.

## Structure

- backend/   FastAPI + ML models
- frontend/  Flutter app
- docs/      Project documentation

## Setup

Backend:
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000

Frontend:
cd frontend
flutter pub get
flutter run -d web-server --web-port=5000

Open http://localhost:5000

## Data Sources

- MIMIC-IV-ED: PhysioNet. https://doi.org/10.13026/5ntk-km72
- Synthetic Emergency Healthcare Services: Zenodo. https://doi.org/10.5281/zenodo.14270002
