class AppString {
  AppString._();

  // App Identity
  static const String appName = 'Infinity Wellness';
  static const String appSubtitle = 'by Infinity Water';

  // Navigation Shell Tabs
  static const String navHome = 'Home';
  static const String navFeed = 'Feed';
  static const String navMiniApps = 'Mini-Apps';
  static const String navWallet = 'Wallet';
  static const String navProfile = 'Profile';

  // Home Screen
  static const String homeGreeting = 'Hello, Alex';
  static const String homeSubtitle = 'Your daily wellness companion';
  static const String homeSnapshotTitle = 'Daily Wellness Snapshot';
  static const String homeHydrationLabel = 'Hydration Goal';
  static const String homeQuickLogButton = '+250 ml';
  static const String homeStreaksTitle = 'Active Streaks';
  static const String homePersonalStreak = 'Personal Streak';
  static const String homeSynergyStreak = '1-on-1 Synergy';
  static const String homePinnedMiniApps = 'Pinned Mini-Apps';
  static const String homeHealthTipTitle = "Today's Verified Tip";

  // Feed Screen
  static const String feedTitle = 'Wellness Feed';
  static const String feedSubtitle = 'Verified health news & myth-busting';
  static const String feedFilterAll = 'All';
  static const String feedFilterNews = 'Medical News';
  static const String feedFilterMyths = 'Myth vs. Fact';
  static const String feedFilterAnnouncements = 'Ecosystem';

  // Mini-App Store
  static const String storeTitle = 'Mini-App Store';
  static const String storeSubtitle = 'Explore dedicated wellness modules';
  static const String storeFeaturedBadge = 'FEATURED MODULE';
  static const String storeLaunchButton = 'Open Module';
  static const String storePinButton = 'Pin to Home';
  static const String storeUnpinButton = 'Unpin';

  // Profile Screen
  static const String profileTitle = 'My Profile';
  static const String profileSubtitle = 'Health metrics & account settings';
  static const String profileMetricsSection = 'Health Metrics';
  static const String profileWeightLabel = 'Weight';
  static const String profileHeightLabel = 'Height';
  static const String profileActivityLabel = 'Activity Level';
  static const String profileCalculatedGoalLabel = 'Daily Water Goal';
  static const String profilePartnerSection = '1-on-1 Synergy Partner';
  static const String profileSettingsSection = 'Settings & Preferences';

  // Wallet Strings (Retained)
  static const String walletMenuTitle = 'Wallet';
  static const String walletTitle = 'Loyalty Points Wallet';
  static const String walletDefaultPointName = 'Reward Points';
  static const String walletBalanceLabel = 'Available balance';
  static const String walletStatusTitle = 'Wallet Status';
  static const String walletActionsTitle = 'Wallet Actions';
  static const String walletActivateButton = 'Activate Wallet';
  static const String walletLoadingConfigMessage =
      'Loading loyalty system config...';
  static const String walletReadyToActivateMessage =
      'Activate your wallet by selecting your customer access ZIP file from this phone.';
  static const String walletSelectingAccessZipMessage =
      'Select your customer access ZIP file.';
  static const String walletAccessSelectionCanceled =
      'Wallet activation was canceled.';
  static const String walletPublicKeyCopied = 'Wallet public key copied.';
  static const String walletReceiveTitle = 'Receive';
  static const String walletSendTitle = 'Send';
  static const String walletHistoryTitle = 'History';
  static const String walletHistoryLink = 'History';
  static const String walletCustomerLabel = 'Wallet owner';
  static const String walletPublicKeyLabel = 'Wallet public key';
  static const String walletQrLabel = 'Scan to receive points';
  static const String walletAssetCodeLabel = 'Asset code';
  static const String walletBalanceValueLabel = 'Balance';
  static const String walletCopyPublicKey = 'Copy public key';
  static const String walletRefreshBalance = 'Refresh balance';
  static const String walletRecipientLabel = 'Recipient ID';
  static const String walletRecipientHint = 'Paste or scan recipient wallet ID';
  static const String walletRecipientReadonlyHint = 'Scanned recipient wallet';
  static const String walletAmountLabel = 'Amount';
  static const String walletAssetReadonlyLabel = 'Loyalty points asset';
  static const String walletScanQrTitle = 'Scan recipient QR';
  static const String walletScannerActive = 'Point the camera at a wallet QR.';
  static const String walletScannerOpening = 'Opening scanner...';
  static const String walletScannerUnavailable =
      'Camera scanner is not available. Paste the recipient ID below.';
  static const String walletScannerPermissionDenied =
      'Camera permission is required to scan QR codes.';
  static const String walletRecipientCaptured = 'Recipient ID captured.';
  static const String walletInvalidQr =
      'That QR does not contain a valid wallet ID.';
  static const String walletScanAgain = 'Scan again';
  static const String walletUnavailableValue = 'Unavailable';
  static const String walletActivateFirstMessage =
      'Activate your wallet before using this action.';
  static const String walletPasscodeTitle = 'Wallet passcode';
  static const String walletCreatePasscodeMessage =
      'Create a customer passcode to encrypt this wallet on this phone.';
  static const String walletUnlockPasscodeMessage =
      'Enter your customer passcode to unlock sending for this app session.';
  static const String walletPasscodeLabel = 'Passcode';
  static const String walletCancel = 'Cancel';
  static const String walletContinue = 'Continue';
  static const String walletUnlockButton = 'Unlock wallet';
  static const String walletReviewTitle = 'Review Send';
  static const String walletConfirmSend = 'Confirm send';
  static const String walletValidatingRecipient =
      'Checking recipient trustline...';
  static const String walletInvalidAmount =
      'Enter a valid amount greater than zero.';
  static const String walletSecretMissingMessage =
      'Reimport the access ZIP to encrypt this wallet for local sending.';
  static const String walletSendSuccess = 'Points sent successfully.';
  static const String walletSendFailure = 'Points could not be sent.';
  static const String walletNoHistory = 'No transaction history yet.';
  static const String walletTransactionSuccess = 'Success';
  static const String walletTransactionFailed = 'Failed';
  static const String walletTransactionHashLabel = 'Transaction hash';
  static const String walletErrorLabel = 'Error';
  static const String walletNetworkLabel = 'Network';
}
