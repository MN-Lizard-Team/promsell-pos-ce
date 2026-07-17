import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser_impl.dart';

void main() {
  const parser = CsvProductParser();

  group('CsvProductParser', () {
    test('parses valid CSV with all fields', () {
      const csv =
          'name,sku,barcode,price,cost,stock,category\n'
          'Coffee,C001,123456,50.0,30.0,10,Drinks\n'
          'Tea,C002,789012,40.0,20.0,5,Drinks\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows.length, 2);
      expect(result.rows[0].name, 'Coffee');
      expect(result.rows[0].sku, 'C001');
      expect(result.rows[0].barcode, '123456');
      expect(result.rows[0].price, 50.0);
      expect(result.rows[0].cost, 30.0);
      expect(result.rows[0].stock, 10);
      expect(result.rows[0].categoryName, 'Drinks');
    });

    test('parses CSV with only required fields (name, price)', () {
      const csv = 'name,price\nCoffee,50.0\nTea,40.0\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows.length, 2);
      expect(result.rows[0].name, 'Coffee');
      expect(result.rows[0].price, 50.0);
      expect(result.rows[0].sku, isNull);
      expect(result.rows[0].barcode, isNull);
    });

    test('returns csvNoData for empty CSV', () {
      const csv = 'name,price\n';
      final result = parser.parse(csv);

      expect(result.isValid, false);
      expect(result.error, 'csvNoData');
    });

    test('returns csvInvalidFormat when name column missing', () {
      const csv = 'sku,price\nC001,50.0\n';
      final result = parser.parse(csv);

      expect(result.isValid, false);
      expect(result.error, 'csvInvalidFormat');
    });

    test('returns csvInvalidFormat when price column missing', () {
      const csv = 'name,sku\nCoffee,C001\n';
      final result = parser.parse(csv);

      expect(result.isValid, false);
      expect(result.error, 'csvInvalidFormat');
    });

    test('skips empty rows', () {
      const csv = 'name,price\nCoffee,50.0\n,,\nTea,40.0\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows.length, 2);
    });

    test('handles Thai column headers', () {
      const csv = 'ชื่อ,ราคา,สต็อก\nกาแฟ,50.0,10\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows[0].name, 'กาแฟ');
      expect(result.rows[0].price, 50.0);
      expect(result.rows[0].stock, 10);
    });

    test('defaults trackStock to true when column missing', () {
      const csv = 'name,price\nCoffee,50.0\n';
      final result = parser.parse(csv);

      expect(result.rows[0].trackStock, true);
    });

    test('parses trackStock=false', () {
      const csv = 'name,price,track_stock\nCoffee,50.0,false\n';
      final result = parser.parse(csv);

      expect(result.rows[0].trackStock, false);
    });

    test('handles missing stock as 0', () {
      const csv = 'name,price\nCoffee,50.0\n';
      final result = parser.parse(csv);

      expect(result.rows[0].stock, 0);
    });

    test('strips UTF-8 BOM before parsing', () {
      const csv = '\uFEFFname,price\nCoffee,50.0\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows.length, 1);
      expect(result.rows[0].name, 'Coffee');
    });

    test('returns csvTooManyRows when data rows exceed maxDataRows', () {
      final buffer = StringBuffer('name,price\n');
      for (var i = 0; i < 6; i++) {
        buffer.writeln('Item$i,${10 + i}.0');
      }
      final result = const CsvProductParser(
        maxDataRows: 5,
      ).parse(buffer.toString());

      expect(result.isValid, false);
      expect(result.error, 'csvTooManyRows');
    });

    test('parses Thai track_stock aliases', () {
      const csv = 'name,price,ติดตามสต็อก\nCoffee,50.0,0\nTea,40.0,1\n';
      final result = parser.parse(csv);

      expect(result.isValid, true);
      expect(result.rows[0].trackStock, false);
      expect(result.rows[1].trackStock, true);
    });
  });
}
