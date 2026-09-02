import 'package:promsell_pos_ce/features/sale/domain/entities/kitchen_ticket.dart';

abstract class KitchenRepository {
  Future<KitchenTicket> fireUnfiredLines(String cartId);
}
