const express = require('express');
const app = express();
const cors = require("cors");
const http = require('http');
const {Server} = require('socket.io')

const server = http.createServer(app);
const io = new Server(server, {
    cors : {
        origin: "*"
    },
}); 

// fetch Port
require('dotenv').config();
// const PORT = process.env.PORT || 5000;
const PORT = process.env.PORT;
// console.log(PORT);
// Body Parser
app.use(express.json());
// app.use(express.urlencoded({ extended: true }));
app.use(cors());

// Importing router
const authRoutes  = require('./routes/routes');

// mounting the path
app.use('/api/v1', authRoutes);

const documentUsers = {};
// Setting connection and disconnection responses
io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

    socket.on("joinDocument", ({documentId, username}) => {
        socket.join(documentId);

         if (!documentUsers[documentId]) {
                documentUsers[documentId] = [];
            }

            documentUsers[documentId].push({
                socketId: socket.id,
                username: username
            });

            const users = documentUsers[documentId].map(u => u.username);
        console.log(`${username} : ${socket.id} joined document ${documentId}`);

        // const room = io.sockets.adapter.rooms.get(documentId);
        // const count = room ? room.size : 0;

        io.to(documentId).emit("presenceUpdate", users);
    });

    socket.on("codeChange", ({ documentId, content }) => {
    socket.to(documentId).emit("codeChange", content);
    });

       socket.on("disconnecting", () => {
        socket.rooms.forEach((room) => {

            if (room !== socket.id && documentUsers[room]) {

            documentUsers[room] =
                documentUsers[room].filter(
                user => user.socketId !== socket.id
                );

            const users =
                documentUsers[room].map(u => u.username);

            io.to(room).emit("presenceUpdate", users);

        }
        });
        });
        
        // keep your logging if you want
        socket.on("disconnect", () => {
            console.log("User disconnected:", socket.id);
        });

        socket.on("leaveDocument", (documentId) => {
        socket.leave(documentId);
        console.log(`User ${documentId} left the room`);

        if (documentUsers[documentId]) {
            documentUsers[documentId] = documentUsers[documentId].filter(user => user.socketId !== socket.id);
            const users = documentUsers[documentId].map(u => u.username);
            io.to(documentId).emit("presenceUpdate", users);
        }
        
        });

});

// Activate Server
server.listen(PORT, () => {
    console.log(`Server started at port no. ${PORT}`);
})

// Importing Database connection function
const dbConnect = require('./config/database');
dbConnect();

app.get('/', (req,res) => {
    res.send('<h1>Collabrative Code Editor</h1>');
})