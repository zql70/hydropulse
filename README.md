# HydroPulse - 水动力
## 智能饮水健康管理 APP

### 环境要求
- Flutter SDK 3.38+
- Android Studio 2025+
- JDK 21
- Android SDK 36

### 初始化步骤

1. 安装 Flutter SDK 后，在项目目录运行：
```bash
flutter create --project-name hydropulse --org com.hydropulse .
```
此命令会生成 Gradle Wrapper 等必要的构建文件（不会覆盖已有的 lib/ 代码）。

2. 获取依赖：
```bash
flutter pub get
```

3. 连接 Android 设备或启动模拟器，运行：
```bash
flutter run
```

### 项目结构
```
lib/
├── main.dart              # 入口 + Provider 初始化
├── app.dart               # MaterialApp 配置
├── theme/app_theme.dart   # Material 3 主题（颜色/字体/间距）
├── models/                # 数据模型
├── providers/             # 状态管理（ChangeNotifier）
├── screens/               # 4 个主页面
└── widgets/               # 可复用组件
```
