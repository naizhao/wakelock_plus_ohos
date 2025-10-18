/*
 * WakelockPlus Plugin for HarmonyOS
 * Keeps device screen awake by controlling window keep screen on flag
 */

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import {
  MethodResult,
  MethodCallHandler
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import window from '@ohos.window';

const CHANNEL_NAME = "dev.fluttercommunity.plus/wakelock_plus";
const TAG = "WakelockPlus";

export class WakelockPlusPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private mainWindow: window.Window | null = null;

  /**
   * Plugin 附加到 Flutter 引擎时调用
   */
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    console.info(TAG, 'onAttachedToEngine called');
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);

    // 获取主窗口实例
    this.getMainWindow();
  }

  /**
   * Plugin 从 Flutter 引擎分离时调用
   */
  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    console.info(TAG, 'onDetachedFromEngine called');
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
    this.mainWindow = null;
  }

  /**
   * 获取主窗口实例
   */
  private getMainWindow(): void {
    try {
      window.getLastWindow(globalThis.abilityContext, (err, windowClass) => {
        if (err.code) {
          console.error(TAG, `Failed to get main window. Error: ${err.message}`);
          return;
        }
        this.mainWindow = windowClass;
        console.info(TAG, 'Successfully got main window');
      });
    } catch (error) {
      console.error(TAG, `Failed to get main window: ${error.message}`);
    }
  }

  /**
   * 处理方法调用
   */
  onMethodCall(call: MethodCall, result: MethodResult): void {
    console.info(TAG, `onMethodCall: ${call.method}`);

    switch (call.method) {
      case 'toggle':
        this.toggle(call, result);
        break;
      case 'isEnabled':
        this.isEnabled(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  /**
   * 切换屏幕常亮状态
   */
  private toggle(call: MethodCall, result: MethodResult): void {
    if (this.mainWindow == null) {
      console.error(TAG, 'Main window is null, cannot toggle wakelock');
      result.error('NO_WINDOW', 'Main window is not available', null);
      return;
    }

    try {
      const enable = call.argument('enable') as boolean;

      console.info(TAG, `toggle: enable=${enable}`);

      // 设置窗口保持屏幕常亮（HarmonyOS API 11+ 使用同步方法）
      this.mainWindow.setWindowKeepScreenOn(enable);
      console.info(TAG, `Successfully set keep screen on: ${enable}`);
      result.success(null);
    } catch (error) {
      console.error(TAG, `Error in toggle: ${error.message}`);
      result.error('TOGGLE_ERROR', error.message, null);
    }
  }

  /**
   * 获取当前屏幕常亮状态
   */
  private isEnabled(result: MethodResult): void {
    if (this.mainWindow == null) {
      console.error(TAG, 'Main window is null, cannot get wakelock status');
      result.error('NO_WINDOW', 'Main window is not available', null);
      return;
    }

    try {
      // 获取窗口属性（HarmonyOS API 11+ 使用同步方法）
      const properties = this.mainWindow.getWindowProperties();
      const isEnabled = properties.isKeepScreenOn;
      console.info(TAG, `isEnabled: ${isEnabled}`);

      // 返回结果 Map，与 Android/iOS 保持一致
      const resultMap = new Map<string, Object>();
      resultMap.set('enabled', isEnabled);
      result.success(resultMap);
    } catch (error) {
      console.error(TAG, `Error in isEnabled: ${error.message}`);
      result.error('GET_STATUS_ERROR', error.message, null);
    }
  }

  /**
   * 获取插件唯一标识符
   */
  getUniqueClassName(): string {
    return "WakelockPlusPlugin";
  }
}
