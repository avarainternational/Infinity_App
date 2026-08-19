class Routes {
  Routes._();

  // Super App Native Shell
  static const shell = '/shell';
  static const home = '/home';
  static const feed = '/feed';
  static const miniAppStore = '/mini-app-store';
  static const profile = '/profile';

  // Legacy alias for compatibility
  static const profileScreen = '/profile-screen';

  // Wallet Routes (Retained)
  static const wallet = '/wallet';
  static const walletReceive = '/wallet/receive';
  static const walletSend = '/wallet/send';
  static const walletSendScan = '/wallet/send/scan';
  static const walletSendReview = '/wallet/send/review';
  static const walletHistory = '/wallet/history';
}
