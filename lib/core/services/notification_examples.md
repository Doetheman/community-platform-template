# Push Notification Examples with Deep Links

These examples demonstrate how to format your FCM payloads to include deep linking information.

## Event Notification Example

```json
{
  "notification": {
    "title": "New Event: Flutter Meetup",
    "body": "Join us for a Flutter Meetup this Friday at 6 PM"
  },
  "data": {
    "screen_type": "event",
    "item_id": "event123",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Payment Success Notification Example

```json
{
  "notification": {
    "title": "Payment Successful",
    "body": "Your payment for Flutter Conference has been processed successfully"
  },
  "data": {
    "screen_type": "payment",
    "item_id": "event456",
    "status": "success",
    "session_id": "pay_123456",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Payment Failure Notification Example

```json
{
  "notification": {
    "title": "Payment Failed",
    "body": "Your payment for Flutter Conference could not be processed"
  },
  "data": {
    "screen_type": "payment",
    "item_id": "event456",
    "status": "failed",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Stripe Payment Success Notification Example

```json
{
  "notification": {
    "title": "Payment Confirmed",
    "body": "Your ticket purchase was successful. You're all set for the event!"
  },
  "data": {
    "screen_type": "payment",
    "item_id": "event789",
    "status": "success",
    "session_id": "cs_test_123456789",
    "return_to_event": "true",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Direct Route Navigation Example

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message in your inbox"
  },
  "data": {
    "route": "/messages/123",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Notification Screen Navigation Example

```json
{
  "notification": {
    "title": "Activity Update",
    "body": "You have 5 new notifications"
  },
  "data": {
    "screen_type": "notification",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Profile Update Notification Example

```json
{
  "notification": {
    "title": "Profile Update",
    "body": "Your profile has been updated successfully"
  },
  "data": {
    "screen_type": "profile",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

## Server-Side Code Example (Node.js)

```javascript
const admin = require("firebase-admin");
admin.initializeApp();

async function sendNotificationWithDeepLink(token, title, body, data) {
  const message = {
    notification: {
      title,
      body,
    },
    data: {
      ...data,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
    return response;
  } catch (error) {
    console.error("Error sending message:", error);
    throw error;
  }
}

// Example usage for payment success:
sendNotificationWithDeepLink(
  "USER_FCM_TOKEN",
  "Payment Successful",
  "Your payment for Event XYZ has been confirmed!",
  {
    screen_type: "payment",
    item_id: "event123",
    status: "success",
    session_id: "cs_test_123456789",
    return_to_event: "true",
  }
);
```

## Firebase Cloud Function for Stripe Webhook Example

```javascript
// This example shows how to send a notification when a Stripe payment succeeds
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  const sig = req.headers["stripe-signature"];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    console.log(`Webhook Error: ${err.message}`);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the checkout.session.completed event
  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const metadata = session.metadata;
    const eventId = metadata.eventId;
    const userId = metadata.userId;

    // Get user's FCM token from Firestore
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();
    const fcmToken = userDoc.data().fcmToken;

    if (fcmToken) {
      // Send notification with deep link
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: "Payment Successful",
          body: "Your ticket purchase was successful. You're all set for the event!",
        },
        data: {
          screen_type: "payment",
          item_id: eventId,
          status: "success",
          session_id: session.id,
          return_to_event: "true",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    }

    // Update the payment status in Firestore
    await admin
      .firestore()
      .collection("payments")
      .doc(session.id)
      .set({
        userId: userId,
        eventId: eventId,
        status: "completed",
        amount: session.amount_total / 100,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
  }

  res.status(200).send({ received: true });
});
```
