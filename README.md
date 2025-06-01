
# 🛠️ Admin App – Control Panel for ML_Textify (Flutter + Firestore + Base64)

The **Admin App** is a Flutter-based tool that serves as the backend control panel for the **ML_Textify** app. It enables admins to manage images and extracted text using **base64 encoding**, with data stored in **Firebase Firestore** (no Firebase Storage used). This keeps the app lightweight while still leveraging the power of Firebase's real-time database.

---

## 📌 Features

- 🖼️ **Base64 Image Handling** – Upload images as base64 strings (no storage bucket required)
- 🔍 **Text Extraction** – Perform OCR (on-device or remote)
- 📝 **Firestore Integration** – Store image data and extracted text in Firebase Firestore
- 📄 **Text Export** – Save extracted text as `.txt` or `.pdf`
- 📤 **Share Functionality** – Share text or PDFs via system share sheet
- 🧠 **Live Preview** – Real-time view of selected image and extracted text

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: Firebase Firestore
- **Image Handling**: `image_picker`, `dart:convert` (base64)
- **Text Recognition**: ML Kit (on-device) or custom logic
- **Export**: `path_provider`, `pdf`, `share_plus`

---

## 🚀 Getting Started

### 🔧 Prerequisites

- Flutter SDK installed
- Firebase project created
- Android Studio or VS Code

---

### ⚙️ Installation Steps

1. **Clone the Repository**

``bash
git clone https://github.com/yourusername/Admin_App.git
cd Admin_App
-- below are the snapshots
![Screenshot_2025-06-01-15-24-56-602_com example admin_app](https://github.com/user-attachments/assets/81ae8ec9-d116-491e-9452-14bc364045ae)
![Screenshot_2025-06-01-15-24-59-227_com example admin_app](https://github.com/user-attachments/assets/cc24afe9-f3b3-4035-ad39-874062c253d1)
![Screenshot_2025-06-01-15-25-02-402_com example admin_app](https://github.com/user-attachments/assets/3dcdc873-5188-48a7-9491-4aaf473bc401)
![Screenshot_2025-06-01-15-25-07-978_com example admin_app](https://github.com/user-attachments/assets/06ff0569-0f7b-4902-b113-92c56c8ed486)
![Screenshot_2025-06-01-15-25-30-616_com example admin_app](https://github.com/user-attachments/assets/aa33a482-e992-4768-9023-5da6b411d92a)
![Screenshot_2025-06-01-15-25-40-346_com example admin_app](https://github.com/user-attachments/assets/e0a64fab-baa8-4885-a548-7ac52d2b77ea)
