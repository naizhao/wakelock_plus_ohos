import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 鸿蒙平台 WakelockPlus 集成测试
///
/// 测试目标：
/// 1. 验证 enable() 方法能够正常工作
/// 2. 验证 disable() 方法能够正常工作
/// 3. 验证 toggle() 方法能够正常工作
/// 4. 验证 enabled 状态能够正确获取
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('鸿蒙平台 WakelockPlus 测试', () {
    tearDown(() async {
      // 每个测试后确保 wakelock 被禁用
      await WakelockPlus.disable();
    });

    test('初始状态应为禁用', () async {
      // 禁用 wakelock 确保初始状态
      await WakelockPlus.disable();

      // 验证初始状态为禁用
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isFalse, reason: '初始状态应为禁用');

      print('✓ 初始状态验证通过: 禁用');
    });

    test('能够启用 wakelock', () async {
      // 禁用 wakelock
      await WakelockPlus.disable();

      // 启用 wakelock
      await WakelockPlus.enable();

      // 验证状态
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: 'wakelock 应该被启用');

      print('✓ 启用 wakelock 成功');
    });

    test('能够禁用 wakelock', () async {
      // 先启用
      await WakelockPlus.enable();

      // 再禁用
      await WakelockPlus.disable();

      // 验证状态
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isFalse, reason: 'wakelock 应该被禁用');

      print('✓ 禁用 wakelock 成功');
    });

    test('toggle(enable: true) 能够启用 wakelock', () async {
      // 禁用 wakelock
      await WakelockPlus.disable();

      // 使用 toggle 启用
      await WakelockPlus.toggle(enable: true);

      // 验证状态
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: 'toggle(enable: true) 后应该启用');

      print('✓ toggle(enable: true) 成功');
    });

    test('toggle(enable: false) 能够禁用 wakelock', () async {
      // 启用 wakelock
      await WakelockPlus.enable();

      // 使用 toggle 禁用
      await WakelockPlus.toggle(enable: false);

      // 验证状态
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isFalse, reason: 'toggle(enable: false) 后应该禁用');

      print('✓ toggle(enable: false) 成功');
    });

    test('多次启用不会导致错误', () async {
      // 多次启用
      await WakelockPlus.enable();
      await WakelockPlus.enable();
      await WakelockPlus.enable();

      // 验证状态仍然正确
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: '多次启用后应该仍然启用');

      print('✓ 多次启用测试通过');
    });

    test('多次禁用不会导致错误', () async {
      // 先启用
      await WakelockPlus.enable();

      // 多次禁用
      await WakelockPlus.disable();
      await WakelockPlus.disable();
      await WakelockPlus.disable();

      // 验证状态仍然正确
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isFalse, reason: '多次禁用后应该仍然禁用');

      print('✓ 多次禁用测试通过');
    });

    test('快速切换状态', () async {
      // 快速切换多次
      await WakelockPlus.enable();
      await WakelockPlus.disable();
      await WakelockPlus.enable();
      await WakelockPlus.disable();
      await WakelockPlus.enable();

      // 验证最终状态
      final isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: '最终应该是启用状态');

      print('✓ 快速切换测试通过');
    });

    test('状态查询的一致性', () async {
      // 启用
      await WakelockPlus.enable();

      // 多次查询状态应该一致
      final status1 = await WakelockPlus.enabled;
      final status2 = await WakelockPlus.enabled;
      final status3 = await WakelockPlus.enabled;

      expect(status1, equals(status2), reason: '多次查询状态应该一致');
      expect(status2, equals(status3), reason: '多次查询状态应该一致');
      expect(status1, isTrue, reason: '所有查询都应该返回 true');

      print('✓ 状态查询一致性验证通过');
    });

    test('启用后再禁用，状态正确', () async {
      // 启用
      await WakelockPlus.enable();
      var isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: '启用后状态应为 true');

      // 禁用
      await WakelockPlus.disable();
      isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isFalse, reason: '禁用后状态应为 false');

      // 再次启用
      await WakelockPlus.enable();
      isEnabled = await WakelockPlus.enabled;
      expect(isEnabled, isTrue, reason: '再次启用后状态应为 true');

      print('✓ 状态切换验证通过');
    });
  });
}
