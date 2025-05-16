import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/feed/data/models/feed_post_model.dart';
import 'package:white_label_community_app/features/feed/data/models/comment_model.dart';

class FeedRemoteDataSource {
  final FirebaseFirestore firestore;

  FeedRemoteDataSource(this.firestore);

  Stream<List<FeedPostModel>> getFeed() {
    return firestore
        .collection('feed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return FeedPostModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> createPost(FeedPostModel model) async {
    await firestore.collection('feed').add(model.toJson());
  }

  Future<void> deletePost(String id) async {
    await firestore.collection('feed').doc(id).delete();
  }

  Future<void> toggleLike(String postId, String userId) async {
    final postRef = firestore.collection('feed').doc(postId);

    return firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final post = FeedPostModel.fromJson(postDoc.data()!, postDoc.id);
      final likes = List<String>.from(post.likes);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(postRef, {'likes': likes});
    });
  }

  Future<void> toggleReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    final postRef = firestore.collection('feed').doc(postId);

    return firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final post = FeedPostModel.fromJson(postDoc.data()!, postDoc.id);
      final reactions = Map<String, List<String>>.from(post.reactions);

      // Get or create the list of users for this emoji
      final users = reactions[emoji] ?? [];

      if (users.contains(userId)) {
        // Remove reaction
        users.remove(userId);
        if (users.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = users;
        }
      } else {
        // Add reaction
        users.add(userId);
        reactions[emoji] = users;
      }

      transaction.update(postRef, {'reactions': reactions});
    });
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return firestore
        .collection('feed')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CommentModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final commentRef =
        firestore.collection('feed').doc(postId).collection('comments').doc();

    await commentRef.set({...comment.toJson(), 'id': commentRef.id});

    // Update comment count in the post
    await firestore.collection('feed').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await firestore
        .collection('feed')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    // Update comment count in the post
    await firestore.collection('feed').doc(postId).update({
      'commentsCount': FieldValue.increment(-1),
    });
  }

  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    String userId,
  ) async {
    final commentRef = firestore
        .collection('feed')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    return firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }

      final comment = CommentModel.fromJson(commentDoc.data()!, commentDoc.id);
      final likes = List<String>.from(comment.likes);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(commentRef, {'likes': likes});
    });
  }
}
