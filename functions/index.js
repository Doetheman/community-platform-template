const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const envFile = process.env.NODE_ENV === "production" ? ".env.prod" : ".env";
require("dotenv").config({ path: envFile });
const express = require("express");
const bodyParser = require("body-parser");
const { FieldValue } = require("firebase-admin/firestore");

admin.initializeApp();
let deepLinkDomain;
let stripeSecret;
let stripeWebhookSecret;
const isProd = process.env.NODE_ENV === "production";
if (isProd) {
  console.log("Production environment detected");
  const { success_url, cancel_url } = functions.config().stripe;
} else {
  console.log("Development environment detected");
  stripeSecret = process.env.STRIPE_SECRET_KEY;
  deepLinkDomain = process.env.DEEP_LINK_DOMAIN;
  stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
}
const stripe = require("stripe")(stripeSecret);
const stripeApp = express();
// ⚠️ Use raw body parser for Stripe signature verification
stripeApp.use(bodyParser.raw({ type: "application/json" }));

exports.sendFeedNotification = onDocumentCreated(
  "feed/{postId}",
  async (event) => {
    const newPost = event.data.data();
    const authorId = newPost.authorId;

    const usersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const tokens = [];

    // Avoid notifying the author themselves
    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      // if (data.uid !== authorId && data.fcmToken) {
      //   tokens.push(data.fcmToken);
      // }
    });

    if (tokens.length === 0) return null;

    const message = {
      notification: {
        title: "New Post in the Community!",
        body: `${newPost.content.substring(0, 50)}...`,
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Notifications sent:", response.successCount);
    return null;
  }
);

exports.createCheckoutSession = functions.https.onCall(
  async (data, context) => {
    const { eventId, amount, eventTitle } = data.data;
    let uid;
    if (!context.auth) {
      uid = data.auth.uid;
    } else {
      uid = context.auth?.uid;
    }

    if (!uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User not authenticated"
      );
    }

    const event = await admin
      .firestore()
      .collection("events")
      .doc(eventId)
      .get();
    if (!event.exists) {
      throw new functions.https.HttpsError("not-found", "Event not found");
    }
    const eventData = event.data();
    if (!eventData.isPaid) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Event is not paid"
      );
    }

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: eventTitle,
            },
            unit_amount: amount, // in cents
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: `https://${deepLinkDomain}/payment-success`,
      cancel_url: `https://${deepLinkDomain}/payment-cancel`,
      metadata: { eventId, amount, eventTitle, uid },
    });

    return { sessionId: session.id, sessionUrl: session.url };
  }
);

exports.stripeWebhook = onRequest(
  {
    cors: true,
    region: "us-central1",
    rawBody: true,
  },
  async (req, res) => {
    const sig = req.headers["stripe-signature"];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        stripeWebhookSecret
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // ✅ Process event
    if (event.type === "checkout.session.completed") {
      const session = event.data.object;

      const uid = session.metadata.uid;
      const eventId = session.metadata.eventId;
      try {
        await admin
          .firestore()
          .collection("events")
          .doc(eventId)
          .collection("rsvps")
          .doc(uid)
          .set({
            uid,
            response: "yes",
            paid: true,
            timestamp: FieldValue.serverTimestamp(),
          });
      } catch (error) {
        console.error("Error setting rsvp:", error);
      }
    }

    res.json({ received: true });
  }
);
