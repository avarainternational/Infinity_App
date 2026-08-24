import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/core/config/loyalty_system_config.dart';
import 'package:infinity_wellness/app/features/shell/controller/shell_controller.dart';
import 'package:infinity_wellness/app/features/wallet/controller/wallet_controller.dart';
import 'package:infinity_wellness/app/features/wallet/model/customer_wallet_access.dart';
import 'package:infinity_wellness/app/features/wallet/model/wallet_transaction_history_model.dart';
import 'package:infinity_wellness/app/features/wallet/screen/wallet_screen.dart';
import 'package:infinity_wellness/app/features/wallet/service/customer_access_import_service.dart';
import 'package:infinity_wellness/app/features/wallet/service/recipient_validation_service.dart';
import 'package:infinity_wellness/app/features/wallet/service/wallet_activation_storage_service.dart';
import 'package:infinity_wellness/app/features/wallet/service/wallet_transaction_history_service.dart';
import 'package:infinity_wellness/app/features/wallet/service/wallet_unlock_service.dart';
import 'package:infinity_wellness/app/features/wallet/utility/loyalty_points_result.dart';
import 'package:infinity_wellness/app/features/wallet/utility/loyalty_points_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('WalletController openSendScan activates Send tab directly', () {
    final sdk = _FakeLoyaltyPointsSdk();
    final controller = _buildController(sdk);
    Get.put<WalletController>(controller);

    expect(controller.rewardsMode.value, 0);

    controller.openSendScan();

    expect(controller.rewardsMode.value, 1);
    controller.onClose();
  });

  test('WalletController normalizes and validates public keys', () {
    final sdk = _FakeLoyaltyPointsSdk();
    final controller = _buildController(sdk);

    expect(
      controller.normalizeWalletPublicKey(' $_validRecipientPublicKey '),
      _validRecipientPublicKey,
    );
    expect(controller.normalizeWalletPublicKey('invalid_key_data'), isNull);

    controller.onClose();
  });

  testWidgets('WalletScreen renders Receive tab and switches to Send inline scanner', (
    tester,
  ) async {
    final sdk = _FakeLoyaltyPointsSdk();
    final controller = _buildController(sdk);
    Get.put<WalletController>(controller);
    Get.put<ShellController>(ShellController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: WalletScreen(),
        ),
      ),
    );
    await tester.pump();

    // Default mode is Receive: shows QR code / Reward ID
    expect(find.text('Transfer & Receive'), findsOneWidget);
    expect(find.text('Your Reward ID'), findsOneWidget);

    // Switch to Send tab
    controller.rewardsMode.value = 1;
    await tester.pump();

    // In Send mode: shows camera viewfinder and paste from clipboard helper
    expect(find.text('Paste from clipboard to send'), findsOneWidget);
    expect(find.text('Have a Copied ID?'), findsOneWidget);

    controller.onClose();
  });
}

WalletController _buildController(LoyaltyPointsSdk sdk) {
  final controller = WalletController(
    importService: CustomerAccessImportService(),
    storageService: WalletActivationStorageService(),
    unlockService: WalletUnlockService(),
    recipientValidationService: RecipientValidationService(),
    historyService: _FakeWalletTransactionHistoryService(),
    loyaltyPointsSdk: sdk,
    enableSnackbars: false,
    autoLoadConfig: false,
  );
  controller.config.value = _config;
  controller.walletAccess.value = _walletAccess;
  controller.walletState.value = WalletState.activated;
  return controller;
}

const _config = LoyaltySystemConfig(
  merchantName: 'Skino',
  pointName: 'Quick Pay Points',
  assetCode: 'SKINO',
  totalSupply: 1000000,
  issuerPublicKey: _issuerPublicKey,
  distributorPublicKey: _distributorPublicKey,
  networkName: 'TESTNET',
  horizonUrl: 'https://horizon-testnet.stellar.org',
  nownodeApiKey: 'test-key',
  importSource: 'test',
  packageVersion: 'test',
);

const _walletAccess = CustomerWalletAccess(
  customerName: 'Test Customer',
  customerId: 'C-001',
  phone: '+959000000000',
  publicKey: _senderPublicKey,
  assetCode: 'SKINO',
);

const _senderPublicKey =
    'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWHF';
const _validRecipientPublicKey =
    'GBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBWHF';
const _issuerPublicKey =
    'GCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCWHF';
const _distributorPublicKey =
    'GDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDWHF';

class _FakeLoyaltyPointsSdk implements LoyaltyPointsSdk {
  _FakeLoyaltyPointsSdk();

  @override
  Future<LoyaltyBalanceResult> checkBalance() async {
    return const LoyaltyBalanceResult(balance: '500', assetCode: 'SKINO');
  }

  @override
  Future<LoyaltySendResult> send({
    required String recipient,
    required String amount,
  }) async {
    return const LoyaltySendResult(
      transactionHash: 'hash_test',
      updatedBalance: '400',
    );
  }
}

class _FakeWalletTransactionHistoryService
    extends WalletTransactionHistoryService {
  final List<WalletTransactionHistoryModel> records =
      <WalletTransactionHistoryModel>[];

  @override
  Future<List<WalletTransactionHistoryModel>> loadHistory() async {
    return List<WalletTransactionHistoryModel>.of(records);
  }

  @override
  Future<void> saveRecord(WalletTransactionHistoryModel record) async {
    records.add(record);
  }
}
