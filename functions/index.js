const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

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

    const response = await admin.messaging().sendMulticast(message);
    console.log("Notifications sent:", response.successCount);
    return null;
  }
);
