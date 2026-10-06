// web/firebase-messaging-sw.js
//
// Firebase Cloud Messaging service worker for web.
// Handles notifications when the browser tab is not in focus.

importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCAPmha2eGSU54PXOaYSK_hoUYy9-dcjNE",
  authDomain: "smart-queue-kabale-181fa.firebaseapp.com",
  projectId: "smart-queue-kabale-181fa",
  storageBucket: "smart-queue-kabale-181fa.firebasestorage.app",
  messagingSenderId: "290317007301",
  appId: "1:290317007301:web:01c809ff9191c44ae833ac",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);

  const title = payload.notification?.title || "Smart Queue AI";
  const body = payload.notification?.body || "You have a notification.";

  self.registration.showNotification(title, {
    body: body,
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data || {},
  });
});

// Handle notification click — open the app
self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      // If a tab is already open, focus it
      for (const client of clientList) {
        if ("focus" in client) {
          return client.focus();
        }
      }
      // Otherwise open a new tab
      if (clients.openWindow) {
        return clients.openWindow("/");
      }
    })
  );
});
