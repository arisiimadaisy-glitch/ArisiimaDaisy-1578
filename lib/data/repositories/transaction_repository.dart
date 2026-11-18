import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<List<Transaction>> getByUserId(String userId) async {
    final snapshot = await _userTransactions(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((document) {
      return Transaction.fromJson({
        ...document.data(),
        'id': document.id,
        'userId': userId,
      });
    }).toList();
  }

  Future<Transaction?> getById(String userId, String id) async {
    final document = await _userTransactions(userId).doc(id).get();
    final data = document.data();
    if (!document.exists || data == null) return null;

    return Transaction.fromJson({...data, 'id': document.id, 'userId': userId});
  }

  Future<Transaction> create(Transaction transaction) async {
    final document = _userTransactions(transaction.userId).doc();
    final savedTransaction = transaction.copyWith(id: document.id);
    await document.set(savedTransaction.toJson());
    return savedTransaction;
  }

  Future<void> update(Transaction transaction) async {
    await _userTransactions(transaction.userId)
        .doc(transaction.id)
        .update(transaction.toJson());
  }

  Future<void> delete(String userId, String id) async {
    await _userTransactions(userId).doc(id).delete();
  }
}
