import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_skip/data/models/receipt_model.dart';
import 'package:line_skip/data/repositories/receipt_repository.dart';

/// Repository Provider
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository();
});

/// Receipts fetch provider
final receiptsProvider = FutureProvider.family<List<ReceiptModel>, String>((
  ref,
  userId,
) async {
  final repo = ref.read(receiptRepositoryProvider);
  return repo.fetchReceipts(userId);
});

/// Notifier for saving receipts
class ReceiptNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final ReceiptRepository _repository;

  ReceiptNotifier(this.ref, this._repository) : super(const AsyncData(null));

  Future<void> saveReceipt(ReceiptModel receipt) async {
    state = const AsyncLoading();
    try {
      await _repository.addReceipt(receipt);
      state = const AsyncData(null);

      // Invalidate the receiptsProvider for this user
      ref.invalidate(receiptsProvider(receipt.userId));

      dev.log('Receipt saved successfully', name: 'Receipt');
    } catch (error, stack) {
      state = AsyncError(error, stack);
      dev.log('Error saving receipt: $error', name: 'Receipt');
    }
  }
}

/// Provider for saving receipts
final receiptProvider =
    StateNotifierProvider<ReceiptNotifier, AsyncValue<void>>((ref) {
      final repository = ref.read(receiptRepositoryProvider);
      return ReceiptNotifier(ref, repository);
    });
