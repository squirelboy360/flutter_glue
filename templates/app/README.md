# Flutter Template with Native Features

A powerful Flutter template that includes native iOS features and fallback implementations for other platforms. This template provides a robust foundation for building cross-platform apps with native-like experiences.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Xcode 14+ (for iOS development)
- Android Studio / IntelliJ IDEA
- Git

### Setup Your Project

1. Clone the template:
```bash
git clone https://github.com/your-org/flutter-template.git your_app_name
cd your_app_name
```

2. Rename the project:
```bash
# Install rename package globally
dart pub global activate rename

# Rename the app bundle
rename setBundleId --value com.your.app

# Rename the app name
rename setAppName --value "Your App Name"
```

3. Update dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 📱 Features

### 1. Native Modal System
A powerful modal system that uses native iOS sheet presentation on iOS and provides a beautiful fallback implementation on other platforms.

#### Supported Features
| Feature | iOS (Native) | Other Platforms (Fallback) |
|---------|-------------|---------------------------|
| Presentation Style | ✅ Live Updates | ✅ Live Updates |
| Detents | ✅ Live Updates | ✅ Live Updates |
| Drag Indicator | ✅ Live Updates | ✅ Live Updates |
| Background Color | ✅ Live Updates | ✅ Live Updates |
| Corner Radius | ✅ Live Updates | ✅ Live Updates |
| Dismissible | ✅ Live Updates | ✅ Live Updates |
| Swipe Gesture | ✅ Live Updates | ✅ Live Updates |
| Header Style | ❌ Requires Reload | ✅ Live Updates |
| Transition Style | ❌ Not Supported | ❌ Not Supported |

#### Usage Example
```dart
ModalService.showModalWithRoute(
  context: context,
  route: '/example',
  arguments: {
    'modalId': 'unique_modal_id',
    'title': 'Modal Title',
    'description': 'Modal Description',
    'img': 'https://example.com/image.jpg',
  },
  configuration: const ModalConfiguration(
    presentationStyle: ModalPresentationStyle.sheet,
    detents: [ModalDetent.medium, ModalDetent.large],
    initialDetent: ModalDetent.medium,
    isDismissible: true,
    showDragIndicator: true,
    enableSwipeGesture: true,
  ),
);
```

### 2. Routing System
A flexible routing system that supports:
- Deep linking
- Modal presentations
- Arguments passing
- Route guards
- Navigation history

#### Usage Example
```dart
// Navigate to a route
RouteHandler.push('/example', arguments: {'key': 'value'});

// Show as modal
RouteHandler.showModal(
  route: '/example',
  arguments: {'key': 'value'},
);

// Handle deep links
RouteHandler.handleDeepLink('myapp://example?param=value');
```

### 3. Native Text Input
Cross-platform text input system that uses native implementations where available:
- iOS: Native UITextField/UITextView
- Other platforms: Flutter TextField with native-like behavior

### 4. Alert System
Cross-platform alert system with native implementations:
- iOS: UIAlertController
- Other platforms: Material Design alerts

#### Usage Example
```dart
AlertService.showAlert(
  title: "Alert Title",
  message: "Alert message goes here",
  actions: [
    AlertAction(title: "OK", style: AlertActionStyle.default),
    AlertAction(title: "Cancel", style: AlertActionStyle.cancel),
  ],
);
```

## 🛠 Configuration

### App Configuration
Update the following files to configure your app:

1. `ios/Runner/Info.plist`:
   - Bundle identifier
   - App name
   - Permissions
   - Deep link schemes

2. `android/app/build.gradle`:
   - Application ID
   - Version code/name
   - Dependencies

3. `lib/core/config/app_config.dart`:
   - API endpoints
   - Feature flags
   - Environment variables

### Theme Configuration
Customize your app's theme in `lib/core/theme/app_theme.dart`:
```dart
final lightTheme = ThemeData(
  primaryColor: YourColors.primary,
  // ... other theme properties
);
```

## 📦 Project Structure
```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── routing/        # Routing system
│   ├── services/       # Native services & fallbacks
│   └── theme/          # App theme
├── ui/
│   ├── screens/        # App screens
│   ├── widgets/        # Reusable widgets
│   └── modals/         # Modal screens
└── main.dart          # App entry point
```

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
