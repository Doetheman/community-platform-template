import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_community_app/features/feed/data/models/feed_post_model.dart';

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
}
