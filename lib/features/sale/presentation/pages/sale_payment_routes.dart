/// Named routes used by Sale checkout navigation pop policy.
abstract final class SalePaymentRoutes {
  static const cartReview = 'sale_cart_review';

  /// Full-page retail payment (replaces modal payment sheet).
  static const paymentPage = 'sale_payment_page';

  /// @nodoc Alias for [paymentPage] — older call sites / docs.
  static const paymentSheet = paymentPage;

  static const checkoutPage = 'sale_checkout_page';
  static const promptPay = 'sale_promptpay_payment';

  static bool isCheckoutShell(String? name) =>
      name == paymentPage ||
      name == paymentSheet ||
      name == checkoutPage ||
      name == promptPay;

  static bool isCartReview(String? name) => name == cartReview;

  static bool isPaymentPage(String? name) =>
      name == paymentPage || name == paymentSheet;
}
