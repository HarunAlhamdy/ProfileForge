import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/data/portfolio_firestore_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final portfolioFirestoreProvider = Provider<PortfolioFirestoreService>((ref) {
  return PortfolioFirestoreService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});
