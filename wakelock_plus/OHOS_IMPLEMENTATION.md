# WakelockPlus 鸿蒙平台实施文档

## 📋 实施概述

本文档记录了 wakelock_plus 插件的鸿蒙（OpenHarmony/HarmonyOS）平台适配过程。

**实施方式**：直接集成（MethodChannel）
**实施日期**：2025-10-19
**实施状态**：✅ 已完成

---

## 🎯 实施方案选择

### 为什么选择直接集成？

1. **插件架构匹配**：wakelock_plus 是传统非联合插件，所有平台代码在同一包内
2. **保持一致性**：与 Android/iOS 实现方式保持一致
3. **简单高效**：无需复杂的项目架构改造
4. **易于维护**：代码集中，便于后续更新

### 技术方案

- **通信方式**：MethodChannel（与 Android/iOS 保持一致）
- **核心 API**：`@ohos.window` - Window.setWindowKeepScreenOn()
- **权限要求**：无需额外权限
- **数据格式**：与现有平台保持一致

---

## 📁 创建的文件结构

```
ohos/
├── oh-package.json5                          # 鸿蒙包配置文件
├── build-profile.json5                       # 构建配置文件
├── hvigorfile.ts                             # Hvigor 构建脚本
├── hvigor/
│   └── hvigor-config.json5                   # Hvigor 配置
└── src/
    └── main/
        ├── ets/
        │   ├── Index.ets                     # 插件入口
        │   └── components/
        │       └── plugin/
        │           └── WakelockPlusPlugin.ets  # 核心插件实现
        ├── module.json5                      # 模块配置
        └── resources/
            └── base/
                ├── element/
                │   └── string.json           # 字符串资源
                └── profile/
                    └── main_pages.json       # 页面配置
```

---

## 🔧 核心实现

### 1. pubspec.yaml 配置

```yaml
flutter:
  plugin:
    platforms:
      ohos:
        packageName: dev.fluttercommunity.plus.wakelock
        pluginClass: WakelockPlusPlugin
```

### 2. Window API 实现要点

#### 保持屏幕常亮

鸿蒙使用 Window API 的 `setWindowKeepScreenOn` 方法：

```typescript
// 启用屏幕常亮
window.setWindowKeepScreenOn(true, (err) => {
  if (err.code) {
    console.error('Failed to keep screen on');
  }
});

// 禁用屏幕常亮
window.setWindowKeepScreenOn(false, (err) => {
  if (err.code) {
    console.error('Failed to release screen on');
  }
});
```

#### 查询状态

通过 Window 属性查询当前状态：

```typescript
window.getWindowProperties((err, properties) => {
  if (!err.code) {
    const isEnabled = properties.isKeepScreenOn;
  }
});
```

### 3. MethodChannel 实现

支持的方法：
- `toggle(enable: bool)` - 切换屏幕常亮状态
- `isEnabled()` - 获取当前状态

返回格式：
```typescript
// toggle 方法：成功返回 null
result.success(null);

// isEnabled 方法：返回 Map
const resultMap = {
  'enabled': isEnabled  // boolean
};
result.success(resultMap);
```

### 4. 无需额外权限

鸿蒙平台控制屏幕常亮不需要额外的权限声明，这与 Android/iOS 保持一致。

---

## 🚀 如何测试

### 环境要求

1. **Flutter SDK**：鸿蒙版 Flutter SDK（3.22.0+）
2. **开发工具**：DevEco Studio 4.0+
3. **测试设备**：
   - 鸿蒙真机（推荐）
   - 鸿蒙模拟器

### 测试步骤

#### 方式一：使用现有 example（推荐）

```bash
# 1. 进入 example 目录
cd wakelock_plus/example

# 2. 如果没有 ohos 平台，添加它
flutter create --platforms ohos .

# 3. 获取依赖
flutter pub get

# 4. 连接鸿蒙设备

# 5. 运行
flutter run -d <device-id>
```

#### 方式二：运行集成测试

```bash
# 在 example 目录下
flutter test integration_test/wakelock_plus_ohos_test.dart -d <device-id>
```

### 测试用例

- [ ] 应用启动正常
- [ ] 能够启用 wakelock (`WakelockPlus.enable()`)
- [ ] 能够禁用 wakelock (`WakelockPlus.disable()`)
- [ ] 能够使用 toggle 切换状态
- [ ] 能够正确获取当前状态 (`WakelockPlus.enabled`)
- [ ] 多次启用/禁用不会出错
- [ ] 快速切换状态稳定

---

## 📝 使用说明

### 基本使用

```dart
import 'package:wakelock_plus/wakelock_plus.dart';

// 启用屏幕常亮
await WakelockPlus.enable();

// 禁用屏幕常亮
await WakelockPlus.disable();

// 使用 toggle
await WakelockPlus.toggle(enable: true);

// 获取当前状态
bool isEnabled = await WakelockPlus.enabled;
```

### 在鸿蒙平台的特殊说明

1. **无需权限**：鸿蒙平台不需要任何额外权限即可使用屏幕常亮功能

2. **Window 生命周期**：插件会自动管理主窗口的引用，无需手动处理

3. **应用场景**：
   - 视频播放器：播放时保持屏幕常亮
   - 阅读应用：阅读时防止屏幕关闭
   - 导航应用：导航过程中保持屏幕亮起
   - 游戏应用：游戏过程中保持屏幕常亮

---

## ⚠️ 注意事项

### 1. 电池消耗

- 保持屏幕常亮会增加电池消耗
- 建议只在必要时启用，使用完毕后及时禁用
- 示例：

```dart
class VideoPlayerScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // 进入页面时启用
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // 离开页面时禁用
    WakelockPlus.disable();
    super.dispose();
  }
}
```

### 2. 应用生命周期

- 应用进入后台时，系统会自动管理屏幕状态
- 应用回到前台时，wakelock 状态会保持

### 3. 多次调用

- 多次调用 `enable()` 或 `disable()` 是安全的
- 插件会自动处理重复调用，不会产生副作用

### 4. 异常处理

```dart
try {
  await WakelockPlus.enable();
} catch (e) {
  print('Failed to enable wakelock: $e');
}
```

---

## 🔍 故障排查

### 问题 1：编译失败

**症状**：构建时报错找不到模块

**解决方案**：
```bash
# 清理构建缓存
flutter clean
cd ohos
rm -rf build oh_modules
cd ..

# 重新获取依赖
flutter pub get

# 重新构建
flutter build ohos
```

### 问题 2：Window 为 null

**症状**：运行时提示 "Main window is not available"

**可能原因**：
1. 应用还未完全启动
2. Window 还未初始化

**解决方案**：
- 确保在 `runApp()` 之后调用
- 可以添加延迟：
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  // 稍微延迟后启用
  await Future.delayed(Duration(milliseconds: 100));
  await WakelockPlus.enable();
}
```

### 问题 3：状态不一致

**症状**：调用 enable() 后，`enabled` 返回 false

**解决方案**：
- await 所有异步调用
- 检查设备日志

```dart
// 正确的方式
await WakelockPlus.enable();
final enabled = await WakelockPlus.enabled;
assert(enabled == true);
```

---

## 📊 与其他平台对比

| 特性 | Android | iOS | HarmonyOS |
|------|---------|-----|-----------|
| 核心 API | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON | UIApplication.isIdleTimerDisabled | window.setWindowKeepScreenOn |
| 权限要求 | 无 | 无 | 无 |
| 支持版本 | API 21+ | iOS 12+ | API 20+ |
| 实现方式 | Window Flag | UIApplication | Window API |

---

## 🎉 总结

### 已完成

- ✅ pubspec.yaml 配置 ohos 平台
- ✅ 创建完整 ohos 目录结构
- ✅ 实现 WakelockPlusPlugin.ets
- ✅ 配置资源文件和构建文件
- ✅ API 与其他平台保持一致
- ✅ 无需额外权限
- ✅ 创建集成测试

### 待测试

- ⏳ 在鸿蒙真机上验证功能
- ⏳ 测试不同设备型号兼容性
- ⏳ 长时间运行稳定性测试

### 后续优化

- 🔄 根据测试结果优化实现
- 🔄 添加更详细的错误处理
- 🔄 优化 Window 获取逻辑

---

## 📚 参考资料

- [鸿蒙 Flutter 开发文档](https://gitee.com/openharmony-sig/flutter_flutter)
- [鸿蒙 Window API](https://developer.huawei.com/consumer/cn/doc/harmonic-references-V5/js-apis-window-V5)
- [WakelockPlus 官方文档](https://pub.dev/packages/wakelock_plus)

---

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- GitHub Issues: [wakelock_plus/issues](https://github.com/fluttercommunity/wakelock_plus/issues)
- 原作者: Flutter Community
- 鸿蒙适配: [Sam NG]

---

**最后更新时间**: 2025-10-19
