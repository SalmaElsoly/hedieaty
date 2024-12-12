import {
  onDocumentUpdated,
  Change,
  QueryDocumentSnapshot,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

interface Gift {
  status: "pending" | "pledged" | "purchased";
  name: string;
  ownerId: string;
  pledgerBy: string;
}

interface User {
  fcmToken?: string;
  name?: string;
}

export const notifyUserGiftHadPledged = onDocumentUpdated(
  "gifts/{giftId}",
  async (event: FirestoreEvent<Change<QueryDocumentSnapshot> | undefined>) => {
    const giftBefore = event?.data?.before.data() as Gift;
    const giftAfter = event?.data?.after.data() as Gift;

    if (!giftBefore || !giftAfter) {
      console.log("Gift data not found");
      return;
    }

    if (giftBefore.status === "pending" && giftAfter.status === "pledged") {
      try {
        const ownerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftBefore.ownerId)
          .get();
        const owner = ownerDoc.data() as User | undefined;
        if (!owner || !owner.fcmToken) {
          console.log("Owner's FCM token not found");
          return;
        }

        const pledgerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftAfter.pledgerBy)
          .get();
        const pledger = pledgerDoc.data() as User | undefined;
        if (!pledger) {
          console.log("Pledger data not found");
          return;
        }

        const message = {
          notification: {
            title: "Gift Pledged",
            body: `Your gift "${giftBefore.name}" has been pledged by ${
              pledger.name || "Anonymous"
            }`,
          },
          token: owner.fcmToken,
        };

        await admin.messaging().send(message);
        console.log(`Notification sent to ${owner.name}`);
        await admin.firestore().collection("notifications").add({
          userId: giftBefore.ownerId,
          message: message.notification.body,
        });
        console.log("Notification added to notifications collection");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }
  }
);
