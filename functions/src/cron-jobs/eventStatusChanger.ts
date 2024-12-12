import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {QueryDocumentSnapshot} from "firebase-admin/firestore";

interface Event {
  id: string;
  date: Date;
  status: "upcoming" | "current" | "past";
}

export const eventStatusChangerCron = functions.scheduler.onSchedule(
  "every 1 hours",
  async () => {
    console.log("Function triggered at: ", new Date().getUTCDate());

    const eventsSnapshot = await admin.firestore().collection("events").get();
    const events = eventsSnapshot.docs.map((doc) => doc.data() as Event);

    events.forEach((event) => {
      const eventDate = new Date(event.date);
      const currentDate = new Date();

      if (eventDate < currentDate) {
        admin
          .firestore()
          .collection("events")
          .doc(event.id)
          .update({status: "past"});
      } else if (eventDate == currentDate) {
        admin
          .firestore()
          .collection("events")
          .doc(event.id)
          .update({status: "current"});
      }
    });
  }
);

export const onNewEventCreated = functions.firestore.onDocumentCreated(
  "events/{eventId}",
  async (
    event: functions.firestore.FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<void> => {
    const eventUpdated = event?.data?.data() as Event;
    const eventDate = new Date(eventUpdated.date);
    const currentDate = new Date();
    if (eventDate == currentDate) {
      admin
        .firestore()
        .collection("events")
        .doc(eventUpdated.id)
        .update({status: "current"});
    }
  }
);
