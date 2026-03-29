🚀 CodeHive – Collaborative Coding & Execution Platform

CodeHive is a real-time collaborative code editor that allows multiple users to work together on code seamlessly. It is designed to provide a smooth coding experience with live synchronization, workspace management, and user-based interactions.

---

## 🚀 Current Status

- Version: v1.0
- Status: UI complete and fully responsive
- Core features implemented
- Real-time collaboration: in progress


## 🧠 Features

- 🧑‍💻 Real-time collaborative coding
- 📄 Create and delete documents
- 🔗 Share coding rooms with others
- 🚪 Join shared rooms
- ▶️ Code execution support
- 🗂️ Workspace management
- 🔐 User authentication system
- ⚡ Flutter-based responsive UI
- 🌐 Node.js + MongoDB backend
- 🎨 Clean and modern UI with custom theming
- 📱 Responsive design for mobile and desktop
---

## 🏗️ Project Structure

```
CodeHive/
├── CodeHive Frontend/   # Flutter application
├── CodeHive Backend/    # Node.js backend
```

---

## 🛠️ Tech Stack

### Frontend:

* Flutter
* Dart

### Backend:

* Node.js
* Express.js
* MongoDB (local / Atlas)
* Socket.io (for real-time communication)

---

## ⚙️ Installation & Setup

### 🔹 Clone the repository

```
git clone https://github.com/Gurjotsofficial/CodeHive.git
cd CodeHive
```

---

### 🔹 Backend Setup

```
cd "CodeHive Backend"
npm install
```

Create a `.env` file:

```
PORT=5000
DB_URL=your_mongodb_url
JWT_SECRET=your_secret_key
```

Run backend:

```
npm start
```

---

### 🔹 Frontend Setup

```
cd "../CodeHive Frontend"
flutter pub get
flutter run
```

---

## 🔐 Environment Variables

The backend uses environment variables for security.

Example (`.env.example`):

```
PORT=5000
DB_URL=your_database_url
JWT_SECRET=your_secret
```

---

## 🚀 Future Improvements

* 🌍 Deploy frontend and backend
* 🔒 Role-based access control
* 🧠 Conflict resolution (OT / CRDT)
* 💬 In-app chat system
* 📁 File system support
* 🎨 Better UI/UX

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repo and submit a pull request.

---

## 📄 License

This project is open-source and available under the MIT License.

---

## 👨‍💻 Author

**Gurjot Singh**
GitHub: https://github.com/Gurjotsofficial

---

⭐ If you like this project, give it a star!
