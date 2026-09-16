import 'package:flutter_test/flutter_test.dart';
import 'package:fair_share_app/services/settlement_engine.dart';

void main() {
  test('Settlement Engine should calculate minimum payments', () {
    // Create the Settlement Engine object.
    final engine = SettlementEngine();

    // Positive balance = member should receive money.
    // Negative balance = member needs to pay money.
    final balances = {
      'Ali': 500.0,
      'Ahmed': -300.0,
      'Sara': -200.0,
    };

    // Calculate settlements.
    final settlements = engine.calculateSettlements(balances);

    // We expect 2 payments:
    // Ahmed -> Ali = 300
    // Sara  -> Ali = 200
    expect(settlements.length, 2);

    // Check first payment.
    expect(settlements[0]['fromUserId'], 'Ahmed');
    expect(settlements[0]['toUserId'], 'Ali');
    expect(settlements[0]['amount'], 300.0);

    // Check second payment.
    expect(settlements[1]['fromUserId'], 'Sara');
    expect(settlements[1]['toUserId'], 'Ali');
    expect(settlements[1]['amount'], 200.0);
  });
}
