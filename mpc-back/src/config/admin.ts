import serviceAccount from "../firebase_admin.json";
import admin from "firebase-admin";

const firebaseAdmin = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export default firebaseAdmin;
