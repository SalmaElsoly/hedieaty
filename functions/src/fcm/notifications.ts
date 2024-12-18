import {
  onDocumentUpdated,
  Change,
  QueryDocumentSnapshot,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";

interface Gift {
  status: "unpledged" | "pledged" | "purchased";
  name: string;
  ownerId: string;
  pledgedBy: string;
  deadline: string;
}

interface User {
  fcmToken?: string;
  username?: string;
}

export const notifyUserGiftHadPledged = onDocumentUpdated(
  {
    document: "gifts/{giftId}",
    region: "europe-west6",
  },
  async (event: FirestoreEvent<Change<QueryDocumentSnapshot> | undefined>)
    : Promise<void> => {
    const giftBefore = event?.data?.before?.data() as Gift;
    const giftAfter = event?.data?.after?.data() as Gift;

    logger.info("Gift status changed from " + giftBefore?.status +
        " to " + giftAfter?.status);

    if (!giftBefore || !giftAfter) {
      console.log("Gift data not found");
      logger.error("Gift data not found");
      return;
    }

    // Handle status change from 'pending' to 'pledged'
    if (giftBefore.status == "unpledged" && giftAfter.status == "pledged") {
      try {
        const ownerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftBefore.ownerId)
          .get();
        const owner = ownerDoc.data() as User | undefined;
        if (!owner || !owner.fcmToken) {
          console.log("Owner's FCM token not found");
          logger.error("Owner's FCM token not found");
          return;
        }

        const pledgerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftAfter.pledgedBy)
          .get();
        const pledger = pledgerDoc.data() as User | undefined;
        if (!pledger) {
          console.log("Pledger data not found");
          logger.error("Pledger data not found");
          return;
        }

        const message = {
          notification: {
            title: "Gift Pledged",
            body: `Your gift "${giftBefore.name}" has been pledged by ${
              pledger.username || "Anonymous"
            }`,
          },
          token: owner.fcmToken,
        };

        await admin.messaging().send(message);
        console.log(`Notification sent to ${owner.username || "Owner"}`);
        logger.info(`Notification sent to ${owner.username || "Owner"}`);

        await admin.firestore().collection("notifications").add({
          userId: giftBefore.ownerId,
          message: message.notification.body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log("Notification added to the notifications collection");
        logger.info("Notification added to the notifications collection");
      } catch (error) {
        console.error("Error sending 'pledged' notification:", error);
        logger.error("Error sending 'pledged' notification:", error);
      }
    }

    // Handle status change from 'pledged' to 'purchased'
    if (giftBefore.status == "pledged" && giftAfter.status == "purchased") {
      try {
        const ownerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftBefore.ownerId)
          .get();

        const pledgerDoc = await admin
          .firestore()
          .collection("users")
          .doc(giftAfter.pledgedBy)
          .get();
        const pledger = pledgerDoc.data() as User | undefined;
        const owner = ownerDoc.data() as User | undefined;
        if (!owner || !owner.fcmToken) {
          console.log("Owner's FCM token not found");
          logger.error("Owner's FCM token not found");
          return;
        }

        const message = {
          notification: {
            title: "Gift Purchased",
            body: `Your gift "${giftBefore.name}" has been purchased
            by ${pledger?.username || "Anonymous"}`,
          },
          token: owner.fcmToken,
        };

        await admin.messaging().send(message);
        console.log(`Notification sent to ${owner.username || "Owner"}`);
        logger.info(`Notification sent to ${owner.username || "Owner"}`);

        await admin.firestore().collection("notifications").add({
          userId: giftBefore.ownerId,
          message: message.notification.body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log("Notification added to the notifications collection");
        logger.info("Notification added to the notifications collection");
      } catch (error) {
        console.error("Error sending 'purchased' notification:", error);
        logger.error("Error sending 'purchased' notification:", error);
      }
    }
  }
);


export const giftDeadlineNotify = functions.scheduler.onSchedule(
  "every 24 hours",
  async () => {
    console.log("Function triggered at: ", new Date().getUTCDate());
    logger.info("Function triggered at: ", new Date().getUTCDate());
    const giftsSnapshot = await admin.firestore().collection("gifts").get();
    const gifts = giftsSnapshot.docs.map(
      (doc) => ({id: doc.id, ...(doc.data() as Gift)}));
    console.log("Found gifts: ", gifts.length);
    const options: Intl.DateTimeFormatOptions = {
      timeZone: "Africa/Cairo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    };
    const formattedDate = new Intl.DateTimeFormat("en-GB", options).format(
      new Date()
    );

    const [dayEgy, monthEgy, yearEgy] = formattedDate.split("/").map(Number);
    const egyptDate = new Date(yearEgy, monthEgy - 1, dayEgy);

    for (const gift of gifts) {
      const [day, month, year] = gift.deadline.split("-").map(Number);
      const eventDate = new Date(year, month - 1, day);
      eventDate.setHours(0, 0, 0, 0);
      if (
        eventDate.getTime() == egyptDate.getTime() + 24 * 60 * 60 * 1000 &&
        gift.status === "pledged"
      ) {
        const pledger = await admin
          .firestore()
          .collection("users")
          .doc(gift.pledgedBy)
          .get();
        const pledgerData = pledger.data() as User | undefined;
        if (!pledgerData || !pledgerData.fcmToken) {
          console.log("Pledger's FCM token not found");
          logger.error("Pledger's FCM token not found");
          return;
        }

        const message = {
          notification: {
            title: "Gift Deadline",
            body: ` Gift "${gift.name}" found in your pledged gifts due 
            tomorrow hurry up to purchase it`,
          },
          token: pledgerData.fcmToken,
        };

        await admin.messaging().send(message);
        console.log(`Notification sent to ${pledgerData.username || "Owner"}`);
        logger.info(`Notification sent to ${pledgerData.username || "Owner"}`);
        await admin.firestore().collection("notifications").add({
          userId: gift.pledgedBy,
          message: message.notification.body,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log("Notification added to the notifications collection");
        logger.info("Notification added to the notifications collection");
      }
    }
  }
);


