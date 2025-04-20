import * as admin from 'firebase-admin';
// import * as path from 'path';

// const serviceAccount = require(path.join(__dirname, './serviceAccountKey.json'));

const firebasePrivateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert({
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: firebasePrivateKey,
            projectId: process.env.FIREBASE_PROJECT_ID,
        })
    });
}

export default admin;