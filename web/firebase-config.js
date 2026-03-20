// Firebase configuration for web
const firebaseConfig = {
  apiKey: "AIzaSyCDrcIlZ-rY7-Cn0YI4LqRTwLT2KiEx0co",
  authDomain: "fro-vy.firebaseapp.com",
  projectId: "fro-vy",
  storageBucket: "fro-vy.firebasestorage.app",
  messagingSenderId: "1014519853798",
  appId: "1:1014519853798:web:04579a46bc090469d38127",
  measurementId: "G-EVE61MT6Y5"
};

// Initialize Firebase (only if not already initialized)
if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}