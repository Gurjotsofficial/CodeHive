# 🚀 CodeHive – Collaborative Code Editor

CodeHive is a real-time collaborative code editor that allows multiple users to work together on code seamlessly. It is designed to provide a smooth coding experience with live synchronization, workspace management, and user-based interactions.

---

## 🧠 Features

* 🧑‍💻 Real-time collaborative editing (multiple users)
* 📡 Live code synchronization using sockets
* 🗂️ Workspace creation and management
* 📄 Document-based code editing
* 🔐 User authentication system
* ⚡ Fast and responsive UI built with Flutter
* 🌐 Backend powered by Node.js and MongoDB

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
