import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

class _MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

class _MockGenerateBarcode extends Mock implements GenerateBarcode {}

void main() {
  late _MockSettingsLocalDatasource mockStorage;
  late _MockGenerateBarcode mockGenerateBarcode;

  setUp(() {
    mockStorage = _MockSettingsLocalDatasource();
    mockGenerateBarcode = _MockGenerateBarcode();
    when(() => mockStorage.getString(any())).thenAnswer((_) async => null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});
  });

  group('ProductFormCubit', () {
    test('initial state is idle with empty draft', () {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      expect(cubit.state.status, ProductFormStatus.idle);
      expect(cubit.state.draft, const ProductDraft());
      expect(cubit.state.isDirty, isFalse);
      cubit.close();
    });

    test('syncDraftFromControllers updates draft with all fields', () {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      cubit.syncDraftFromControllers(
        name: 'Coffee',
        price: '50.00',
        stock: '10',
        sku: 'CF-001',
        barcode: '1234567890',
        cost: '30.00',
        categoryId: 'cat-1',
        categoryName: 'Drinks',
        imagePath: '/path/to/img.jpg',
        imageThumbnailPath: '/path/to/thumb.jpg',
        trackStock: true,
        isActive: false,
      );

      expect(cubit.state.draft.name, 'Coffee');
      expect(cubit.state.draft.price, '50.00');
      expect(cubit.state.draft.stock, '10');
      expect(cubit.state.draft.sku, 'CF-001');
      expect(cubit.state.draft.barcode, '1234567890');
      expect(cubit.state.draft.cost, '30.00');
      expect(cubit.state.draft.categoryId, 'cat-1');
      expect(cubit.state.draft.categoryName, 'Drinks');
      expect(cubit.state.draft.imagePath, '/path/to/img.jpg');
      expect(cubit.state.draft.imageThumbnailPath, '/path/to/thumb.jpg');
      expect(cubit.state.draft.trackStock, isTrue);
      expect(cubit.state.draft.isActive, isFalse);
      expect(cubit.state.isDirty, isTrue);
      cubit.close();
    });

    test('saveDraftToStorage persists draft as JSON', () async {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      cubit.syncDraftFromControllers(
        name: 'Test',
        price: '10.00',
        stock: '5',
        sku: '',
        barcode: '',
        cost: '',
        trackStock: true,
      );

      await cubit.saveDraftToStorage();

      verify(
        () => mockStorage.setString(any(), any(that: isNotEmpty)),
      ).called(1);
      cubit.close();
    });

    test('saveDraftToStorage does nothing when not dirty', () async {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      await cubit.saveDraftToStorage();

      verifyNever(() => mockStorage.setString(any(), any()));
      cubit.close();
    });

    test('saveDraftToStorage does nothing when submitted', () async {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      cubit.syncDraftFromControllers(
        name: 'Test',
        price: '10.00',
        stock: '5',
        sku: '',
        barcode: '',
        cost: '',
        trackStock: true,
      );
      cubit.setSubmitted();

      await cubit.saveDraftToStorage();

      verifyNever(() => mockStorage.setString(any(), any()));
      cubit.close();
    });

    test('clearDraft writes empty string to storage', () async {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      await cubit.clearDraft();

      verify(() => mockStorage.setString(any(), '')).called(1);
      cubit.close();
    });

    test('generateBarcode updates draft barcode', () async {
      when(
        () => mockGenerateBarcode(
          prefix: any(named: 'prefix'),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => 'GEN123456');

      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      await cubit.generateBarcode();

      expect(cubit.state.draft.barcode, 'GEN123456');
      expect(cubit.state.isDirty, isTrue);
      cubit.close();
    });

    test('generateBarcode handles errors and rethrows', () async {
      when(
        () => mockGenerateBarcode(
          prefix: any(named: 'prefix'),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenThrow(Exception('Failed'));

      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);

      expect(() => cubit.generateBarcode(), throwsA(isA<Exception>()));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.isDirty, isFalse);
      cubit.close();
    });

    test('restoreDraft sets draft and marks dirty', () {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      const draft = ProductDraft(name: 'Restored', price: '20.00');
      cubit.restoreDraft(draft);

      expect(cubit.state.draft, draft);
      expect(cubit.state.isDirty, isTrue);
      cubit.close();
    });

    test('reset returns to initial state', () {
      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      cubit.syncDraftFromControllers(
        name: 'Test',
        price: '10.00',
        stock: '5',
        sku: '',
        barcode: '',
        cost: '',
        trackStock: true,
      );
      cubit.reset();

      expect(cubit.state.draft, const ProductDraft());
      expect(cubit.state.isDirty, isFalse);
      expect(cubit.state.status, ProductFormStatus.idle);
      cubit.close();
    });

    test('loads draft from storage on construction', () async {
      final draftJson = jsonEncode(
        const ProductDraft(name: 'Saved', price: '15.00').toJson(),
      );
      when(
        () => mockStorage.getString(any()),
      ).thenAnswer((_) async => draftJson);

      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.draft.name, 'Saved');
      expect(cubit.state.draft.price, '15.00');
      expect(cubit.state.isDirty, isTrue);
      cubit.close();
    });

    test('does not emit draft when storage returns empty', () async {
      when(() => mockStorage.getString(any())).thenAnswer((_) async => '');

      final cubit = ProductFormCubit(mockStorage, mockGenerateBarcode);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.draft, const ProductDraft());
      expect(cubit.state.isDirty, isFalse);
      cubit.close();
    });
  });
}
