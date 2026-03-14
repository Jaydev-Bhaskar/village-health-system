# Village Health Monitoring System - Complete Overview

## 📌 1. Project Overview & Current Status
The **Village Health Monitoring System** is a complete, production-ready ecosystem designed for medical college students visiting rural households to collect health data, perform medical screenings, and refer high-risk patients.

**Current Status:** **Ready for Deployment and Field Testing.**
*   **Android APK (Frontend):** Completely built, fully communicating with the backend APIs, rendering dynamically based on real-time data, and utilizing free OpenStreetMap tile servers (no Google API cost).
*   **Node.js Backend:** Fully functional on Render, utilizing MongoDB for data storage, handling Authentication (JWT), user management, visit tracking, and notifications.
*   **FastAPI ML Microservice:** Implemented and integrated. It calculates smart routing clusters and evaluates medical risk parameters (Hypertension, Diabetes, and Obesity) based on exact WHO guidelines.

---

## ✨ 2. Core Features

### 🧑‍🎓 Student App (Mobile App)
*   **Secure Login:** JWT-based authentication for assigned students.
*   **Dashboard:** View assigned houses, visits completed today, pending visits, and recent visit history.
*   **Live Map Integration:** Integrated with OpenStreetMap. Students can view assigned houses dynamically colored by risk (Red = High, Yellow = Moderate, Green = Low). The map auto-centers on their GPS location.
*   **GPS Visit Verification:** Ensures the student is actually at the coordinate of the house before allowing them to fill out the patient form.
*   **Comprehensive Health Screening Form:** 
    *   Basic Persona
    *   Family History
    *   Personal Health History (Diet, Sleep, Smoking, Alcohol)
    *   Female Health (Automatically hidden for males)
    *   Vitals (BP, Pulse, Blood Sugar)
    *   Pediatric Health (Automatically shows for patients < 12 years)
    *   Maternal Health (Automatically shows for pregnant females)
*   **Real-time Risk Calculation:** Vitals are evaluated against the ML microservice in real-time, instantly returning WHO-compliant diagnoses (e.g., *Stage 2 Hypertension*, *Obese class II*).
*   **Visit History:** Filter historical visits by 'Today', 'This Week', or 'High Risk'.

### 👨‍💼 Admin Dashboard (Mobile App / Backend)
*   **Global Architecture Overview:** View total houses, total students, total visits, and aggregate high-risk patient count.
*   **Bulk CSV Uploads:** Instantly upload massive CSV lists of Students and House Coordinates using the Admin dashboard.
*   **Smart Clustering (ML Integration):** Automatically divide hundreds of houses into geographic "clusters" using K-Means, assigning those optimized routes to medical students.
*   **Analytics reporting:** Track health demographics, Non-Communicable Disease (NCD) distributions, and risk heat maps via the backend aggregation pipelines.

---

## 🏥 3. Medical Guidelines & Thresholds (WHO Compliant)
The system's ML microservice and mobile frontend evaluate vitals based on the following standards:

**1. Body Mass Index (BMI):** Calculated automatically from Height and Weight.
*   `< 16.0`: Severe underweight
*   `16.0 - 16.99`: Moderate underweight
*   `17.0 - 18.49`: Mild underweight
*   `18.5 - 24.99`: Normal range
*   `25.0 - 29.99`: Pre-obese
*   `30.0 - 34.99`: Obese class I
*   `35.0 - 39.99`: Obese class II
*   `≥ 40`: Obese class III

**2. Hypertension (Blood Pressure):**
*   `< 120 / < 80`: Normal
*   `120-139 / 80-89`: Elevated / Pre Hypertension
*   `140-159 / 90-99`: Stage 1 Hypertension
*   `≥ 160 / ≥ 100`: Stage 2 Hypertension

**3. Diabetes (Blood Sugar):**
*   `< 140`: Normal
*   `140 - 199`: Prediabetes
*   `≥ 200`: Diabetes

---

## 🔄 4. How to Use & Standard Workflows

### Workflow A: System Administrator Setup
1.  **Register the Admin:** Create an initial Admin account via a POST request to `/api/auth/register` with `"role": "admin"`.
2.  **Login as Admin:** Open the Android APK and log in using the Admin credentials.
3.  **Upload Data:** Tap "Upload Students" and select the CSV file containing the medical student cohort. Next, tap "Upload Houses" and select the CSV file containing the target village house coordinates.
4.  **Run Clustering:** Tap "Run Clustering". The backend will send all houses to the ML Microservice, group them geographically, and automatically assign students to specific clusters.

### Workflow B: Student Field Visit
1.  **Login:** The student opens the app and logs in with their college credentials.
2.  **View Dashboard:** The dashboard shows them how many houses they must visit today.
3.  **Open Map:** They navigate to the Map tab, which plots their current location and drops colored pins on all the houses they are assigned to visit.
4.  **Verify & Start:** The student physically walks to the house. They tap the house on the map and tap "Start Visit". The app verifies their GPS matches the house coordinates to prevent fake data entries.
5.  **Data Collection:** The student goes through the 8-step screening form, inputting the patient's vitals and history.
6.  **Submit & Result:** Upon submission, the vitals are sent to the AI microservice. The patient's risk level is determined instantly, saved to MongoDB, and immediate App Notifications are fired if a High-Risk disease is found.

---

## ⚙️ 5. Technical Architecture & Setup Details

### A. Frontend (Flutter)
*   **Location:** `/frontend/`
*   **Packages used:** `provider`, `http`, `flutter_map` (Free OpenStreetMap tiles), `geolocator`, `shared_preferences`.
*   **Compilation Config:** Configured with `compileSdk 36`, `minSdk 24`, and requires Java 8 Core Library Desugaring for notifications to work properly in release mode.
*   **Build Command:** `flutter build apk --release`

### B. Backend (Node.js & Express)
*   **Location:** `/backend/`
*   **Database:** MongoDB Atlas (Mongoose ORM)
*   **Auth:** JWT (JSON Web Tokens) & `bcryptjs`
*   **Required `.env` Variables:**
    *   `PORT=3000`
    *   `MONGO_URI=mongodb+srv://...`
    *   `JWT_SECRET=supersecretkey`
    *   `JWT_EXPIRES_IN=30d`
    *   `ML_API_URL=https://your-ml-service.onrender.com`

### C. ML Microservice (Python & FastAPI)
*   **Location:** `/ml-service/`
*   **Algorithms Used:** Scikit-Learn `KMeans` for spatial clustering, deterministic algorithm trees for medical risk profiling.
*   **Endpoints:** `/api/v1/cluster-houses`, `/api/v1/risk-detection`
*   **Deployment:** Fully dockerized with a `Dockerfile` and `Procfile`. Ready for Render or Heroku. 

---

## 🚀 6. Next Steps for Production Deployment
1.  **Host the ML Service:** Deploy the `/ml-service` to Render.
2.  **Update Node.js `.env`:** Add the Render URL of your ML Service to the Node.js `.env` file (`ML_API_URL`).
3.  **Deploy Node.js Backend:** Deploy the Node.js backend to Render. Ensure your MongoDB Atlas network settings allow connections from anywhere (`0.0.0.0/0`).
4.  **Final APK Generation:** Verify the `ApiService.baseUrl` in the Flutter app points to your Node.js Render URL, and build the final `.apk`.
5.  **Distribute:** Send the `.apk` file to your medical students.
