/// Named routes used by Sale checkout navigation pop policy.
abstract final class SalePaymentRoutes {
  static const cartReview = 'sale_cart_review';
  static const paymentSheet = 'sale_payment_sheet';
  static const checkoutPage = 'sale_checkout_page';
  static const promptPay = 'sale_promptpay_payment';

  static bool isCheckoutShell(String? name) =>
      name == paymentSheet || name == checkoutPage || name == promptPay;

  static bool isCartReview(String? name) => name == cartReview;
}
