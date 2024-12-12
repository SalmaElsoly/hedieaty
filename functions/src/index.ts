import * as admin from "firebase-admin";
import * as fcm from "./fcm/notifications";
import * as jobs from "./cron-jobs/eventStatusChanger";

admin.initializeApp();

exports.notifyUserGiftHadPledged = fcm.notifyUserGiftHadPledged;
exports.eventStatusChangerCron = jobs.eventStatusChangerCron;
exports.onNewEventCreated = jobs.onNewEventCreated;

