import { Injectable } from '@nestjs/common';
import { FirebaseService } from 'src/firebase/firebase.service';

@Injectable()
export class FcmService {
    constructor(private readonly firebaseService: FirebaseService) { }

    async sendToTopic(topic: string, title: string, body: string, data: any = {}) {
        const admin = this.firebaseService.getAdmin();
        if (!admin) {
            console.error('Firebase Admin SDK not initialized');
            return;
        }

        try {
            const message = {
                notification: {
                    title,
                    body,
                },
                data,
                topic,
            };

            const response = await admin.messaging().send(message);
            console.log('Notification sent successfully:', response);
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    }
}
