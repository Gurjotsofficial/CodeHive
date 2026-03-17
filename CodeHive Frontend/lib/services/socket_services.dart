import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      'http://localhost:4000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      debugPrint("Connected to server");
    });

    socket.onDisconnect((_) {
      socket.off("codeChange"); // remove listener
      socket.disconnect();
      socket.dispose(); // completely clean socket
      debugPrint("Disconnected from server");
    });
  }

  void joinDocument(String documentId, String username) {
  socket.emit("joinDocument", {
    "documentId": documentId,
    "username": username,
  });
}
  void listenCodeChange(Function(String) onChange) {
  socket.off("codeChange"); // remove old listeners first
  socket.on("codeChange", (content) {
      onChange(content);
    });
  }

  void emitCodeChange(String documentId, String content) {
    socket.emit("codeChange", {
      "documentId": documentId,
      "content": content,
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void listenPresence(Function(List<String>) onUpdate) {
  socket.on("presenceUpdate", (users) {
    onUpdate(List<String>.from(users));
  });
  }

  void leaveDocument(String documentId) {
  socket.emit("leaveDocument", documentId);
  }

}