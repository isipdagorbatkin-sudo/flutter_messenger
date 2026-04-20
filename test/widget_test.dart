import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_messenger/chat_utils.dart';

void main() {
  test('buildPrivateChatId creates same id regardless of uid order', () {
    final id1 = buildPrivateChatId('alice', 'bob');
    final id2 = buildPrivateChatId('bob', 'alice');
    expect(id1, id2);
    expect(id1, 'alice_bob');
  });

  test('buildPrivateChatId handles equal uids', () {
    expect(buildPrivateChatId('same', 'same'), 'same_same');
  });

  test('buildAvatarInitial handles empty and normal names', () {
    expect(buildAvatarInitial('Mai'), 'M');
    expect(buildAvatarInitial('   '), '?');
  });
}
