import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool notificationsEnabled;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid:                   doc.id,
      email:                 data['email']               ?? '',
      displayName:           data['displayName']         ?? '',
      createdAt:             (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationsEnabled:  data['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email':                email,
      'displayName':          displayName,
      'createdAt':            FieldValue.serverTimestamp(),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserProfile copyWith({bool? notificationsEnabled}) {
    return UserProfile(
      uid:                  uid,
      email:                email,
      displayName:          displayName,
      createdAt:            createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
