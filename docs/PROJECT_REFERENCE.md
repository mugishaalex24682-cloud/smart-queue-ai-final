# Smart Queue AI — Complete Project Reference Document

**Kabale University — Bachelor of Computer Science**
**BCS3101 — Basics of Machine Learning**
**Authors:** MUGISHA ALEX (2024/A/KCS/5461/F), AHURIRA LUCKY (2024/A/KCS/5197/G/F)
**Last updated:** 2 October 2026

---

## 1. Project Overview

**AI-Assisted Mobile Smart Queue Management System for Hospitals in Kabale, Uganda**

A full-stack machine learning application that:
- Predicts patient urgency using a trained Random Forest classifier
- Predicts waiting time using a trained Random Forest regressor
- Manages hospital queues in real time
- Provides three separate apps: Patient, Staff, Admin
- Sends push notifications to patients
- Books, views, and cancels appointments

---

## 2. Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.47 (Dart 3.13) |
| Backend | Python 3.13 + FastAPI |
| ML Library | scikit-learn 1.6.1 |
| Model Persistence | joblib |
| Database | Firebase Firestore |
| Authentication | Firebase Auth |
| Notifications | Firebase Cloud Messaging (FCM) |
| Backend Admin | firebase-admin (Python) |
| Server | uvicorn |
| Dev Environment | VS Code / PowerShell |

---

## 3. Project Structure

C:\Users\ALEX\SmartQueueAI\
- backend/ (FastAPI + ML models)
- frontend/ (Flutter app)

See Section 3 in the full document for detailed file tree.

---

## 4. Database Used — Firebase Firestore

Firebase Firestore — NoSQL document database hosted by Google, with real-time listeners.

### Collections

- users (Firebase Auth UID) — fcmToken, tokenUpdatedAt
- appointments — userId, department, doctor, date, timeSlot, reason, createdAt
- queue — userId, patientName, complaint, vitals, urgency, urgencyScore, status, joinedAt, calledAt
- staff — name, email, department, role, createdAt

### Firebase Project

- Project name: smart-queue-Kabale
- Project ID: smart-queue-kabale-181fa
- Project number: 290317007301
- Sender ID: 290317007301
- Firestore location: nam5 (United States)
- Auth provider: Email/Password

### VAPID Key

BP2D87Hio2fqqm3CnGrogEqg7-JGtvAsvmBz220rzp6_z0gatw6MtDx9rzZ9pSLbUanXpr2W6oIhjopEK436v70

---

## 5. Machine Learning Models

### 5.1 Urgency Classifier

- Task: Binary classification
- Target: is_urgent
- Dataset: MIMIC-IV-ED demo (207 usable records)
- Source: PhysioNet — https://doi.org/10.13026/5ntk-km72
- Model: Tuned Random Forest
- Hyperparameters: n_estimators=200, max_depth=3, min_samples_split=2
- CV F1: 0.7344
- Saved as: urgency_model.joblib

### 5.2 Waiting-Time Regressor

- Task: Regression
- Target: Waiting Time Triage (min)
- Dataset: Synthetic Emergency Healthcare Services (112 records)
- Source: Zenodo — https://doi.org/10.5281/zenodo.14270002
- Model: Tuned Random Forest Regressor
- Hyperparameters: n_estimators=200, max_depth=3, min_samples_split=2
- CV R²: 0.9256
- Saved as: waiting_time_model.joblib

---

## 6. How to Start the App

Two PowerShell windows required.

### Window 1 — Backend

cd C:\Users\ALEX\SmartQueueAI\backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000

Wait for:
- Firebase Admin initialized from file.
- Firebase Admin ready.
- Models loaded successfully.
- Application startup complete.

### Window 2 — Frontend

cd C:\Users\ALEX\SmartQueueAI\frontend
flutter run -d web-server --web-port=5000

Wait for: lib\main.dart is being served at http://localhost:5000

### Open in Chrome

http://localhost:5000

### Test Accounts

- Patient: test1@example.com / password123
- Staff: test1@example.com / password123 (Staff tab)
- Admin: test1@example.com / password123 (Admin tab)

### Stopping

- Backend: Ctrl + C
- Frontend: q then Enter

---

## 7. Backend API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | / | Health check |
| POST | /predict/urgency | Urgency classification |
| POST | /predict/wait-time | Waiting-time prediction |
| POST | /notify/patient/{user_id} | Send FCM push |

Interactive docs: http://localhost:8000/docs

---

## 8. Cloud Deployment Attempts

| Platform | Status | Reason |
|----------|--------|--------|
| Render | Blocked | Requires credit card |
| Railway | Trial only | $5 credit expires in 30 days |
| Fly.io | Not free | Free tier deprecated Oct 2024 |
| Koyeb | Unavailable | Being acquired by Mistral AI |
| PythonAnywhere | Complex | Beta ASGI only |

Outcome: Backend runs on local PC. Cloud deployment deferred to future work.

Links:
- Render: https://dashboard.render.com
- Railway: https://railway.com/dashboard
- Koyeb: https://app.koyeb.com
- Fly.io: https://fly.io
- PythonAnywhere: https://www.pythonanywhere.com

---

## 9. Mobile APK

### Build

cd C:\Users\ALEX\SmartQueueAI\frontend
flutter clean
flutter pub get
flutter build apk --release

Output: build\app\outputs\flutter-apk\app-release.apk (~52 MB)

### Install on Phone

1. Copy APK to phone
2. Open Files app → tap APK
3. Allow unknown sources
4. Install

### Limitations

Phone APK requires PC backend. Same non-isolated WiFi needed.

---

## 10. GitHub Repositories

- Backend: https://github.com/mugishaalex24682-cloud/smart-queue-backend
- Frontend/Project: https://github.com/mugishaalex24682-cloud/Final_year_project

Personal Access Token: [REDACTED FOR SECURITY - see local notes]

---

## 11. Project Credentials Summary

| Item | Value |
|------|-------|
| GitHub account | mugishaalex24682-cloud |
| GitHub email | mugishaalex24682@gmail.com |
| GitHub password | Alex@24682 |
| GitHub token | [REDACTED - stored in local notes] |
| Firebase console | https://console.firebase.google.com |
| Firebase project | smart-queue-kabale-181fa |
| Test patient | test1@example.com / password123 |
| Faculty email | ak2.acleophas@gmail.com |

---

## 12. Complete vs Deferred

### Complete

- Two ML models trained and evaluated
- FastAPI backend serving both models
- Full Flutter app with 3 roles
- Firebase Auth + Firestore + FCM
- Real-time queue management
- Push notifications
- Appointment booking and cancellation
- Staff and Admin dashboards
- Working APK on phone
- Backend on GitHub

### Deferred

- Cloud deployment (all free tiers blocked)
- Phone APK working from any network
- Role-based Firestore security
- Cost-sensitive learning
- Larger training datasets

---

## 13. Next Steps

1. Invite partner to GitHub repos
2. Coordinate commits for collaboration
3. Screenshots of every screen
4. Update final-year report
5. Build presentation slides (15-20)
6. Practice demo (7-10 min)
7. Submit to ak2.acleophas@gmail.com

---

## 14. Troubleshooting

| Problem | Fix |
|---------|-----|
| flutter not recognized | Reopen PowerShell |
| uvicorn not recognized | pip install -r requirements.txt |
| Port 8000 in use | Get-NetTCPConnection -LocalPort 8000 then Stop-Process |
| Port 5000 in use | Get-NetTCPConnection -LocalPort 5000 then Stop-Process |
| Models not loading | Check .joblib files in backend/ |
| CORS error | Check CORSMiddleware in main.py |
| Firebase permission | Check Firestore rules |
| APK cannot reach backend | Same non-isolated network needed |

---

## 15. References

- MIMIC-IV-ED: Johnson, A., Bulgarelli, L., Pollard, T., et al. (2023). PhysioNet. https://doi.org/10.13026/5ntk-km72
- Synthetic Emergency Healthcare Services: Ferreira, M. (2024). Zenodo. https://doi.org/10.5281/zenodo.14270002
- scikit-learn: Pedregosa et al. (2011). Journal of Machine Learning Research, 12, 2825-2830.
- seaborn: Waskom, M. (2021). Journal of Open Source Software, 6(60), 3021.
- Firebase: https://firebase.google.com/docs
- FastAPI: https://fastapi.tiangolo.com
- Flutter: https://docs.flutter.dev

---

End of document.
