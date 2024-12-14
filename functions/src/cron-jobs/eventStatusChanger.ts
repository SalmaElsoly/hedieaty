import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {QueryDocumentSnapshot} from "firebase-admin/firestore";

interface Event {
  id: string;
  date: string;
  status: "upcoming" | "current" | "past";
}

export const eventStatusChangerCron = functions.scheduler.onSchedule(
  "every 1 hours",
  async () => {
    console.log("Function triggered at: ", new Date().getUTCDate());

    const eventsSnapshot = await admin.firestore().collection("events").get();
    const events = eventsSnapshot.docs.map(
      (doc) => ({id: doc.id, ...doc.data()} as Event)
    );
    console.log("Found events: ", events.length);

    const options: Intl.DateTimeFormatOptions = {
      timeZone: "Africa/Cairo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    };
    const formattedDate = new Intl.DateTimeFormat("en-GB", options).format(
      new Date()
    ); // "14/12/2024"
    const [day, month, year] = formattedDate.split("/").map(Number);
    const egyptDate = new Date(year, month - 1, day); // Convert to Date object

    events.forEach((event) => {
      // Parse the date string in the format "DD-MM-YYYY"
      const [day, month, year] = event.date.split("-").map(Number);
      const eventDate = new Date(year, month - 1, day); // Month is 0-indexed

      eventDate.setHours(0, 0, 0, 0);
      console.log(`Processing event ${event.id}, date: ${event.date}`);

      if (eventDate.getTime() < egyptDate.getTime()) {
        console.log(`Event ${event.id} is past, updating status`);
        admin
          .firestore()
          .collection("events")
          .doc(event.id)
          .update({status: "past"});
      } else if (eventDate.getTime() == egyptDate.getTime()) {
        console.log(`Event ${event.id} is current, updating status`);
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
  {
    document: "events/{eventId}",
    region: "europe-west6",
  },
  async (
    event: functions.firestore.FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<void> => {
    console.log("New event created trigger started");
    const eventData = event.data?.data();
    const eventId = event.data?.id;
    const eventUpdated = {id: eventId, ...eventData} as Event;

    console.log("Event data:", eventUpdated);

    const [day, month, year] = eventUpdated.date.split("-").map(Number);
    const eventDate = new Date(year, month - 1, day);

    const options: Intl.DateTimeFormatOptions = {
      timeZone: "Africa/Cairo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    };
    const formattedDate = new Intl.DateTimeFormat("en-GB", options).format(
      new Date()
    ); // "14/12/2024"
    const [dayEgy, monthEgy, yearEgy] = formattedDate.split("/").map(Number);
    const egyptDate = new Date(yearEgy, monthEgy - 1, dayEgy);

    console.log(`Event date: ${eventDate}, Current date: ${egyptDate}`);

    egyptDate.setHours(0, 0, 0, 0);
    eventDate.setHours(0, 0, 0, 0);

    if (eventDate.getTime() == egyptDate.getTime()) {
      console.log(`Event ${eventUpdated.id} is current, updating status`);
      admin
        .firestore()
        .collection("events")
        .doc(eventUpdated.id)
        .update({status: "current"});
    }
  }
);
