const fs = require('fs');
const p = 'lib/features/sale/presentation/widgets/cart/cart_bottom_bar.dart';
let t = fs.readFileSync(p, 'utf8').replace(/
/g, '
');

// Empty state simple replace
t = t.replace('Icons.receipt_long_outlined', 'Icons.shopping_cart_outlined');
t = t.replace(
  /size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Flexible(/,
  'size: 22,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded('
);
// Add badge after empty text - find empty ValueKey block end
const emptyEnd = t.indexOf("ValueKey('empty')");
console.log('empty marker', emptyEnd);
fs.writeFileSync(p, t);
console.log('step1', t.includes('shopping_cart_outlined'));