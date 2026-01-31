# PlantLog - Plant Care Tracker

## OVERVIEW

PlantLog is a plant care management app that helps you track your plants and their watering schedules. The app uses SwiftData for persistent storage and includes camera integration for capturing plant photos.


## FEATURES

- Add and manage multiple plants with names, species, and photos
- Flexible watering schedules (interval-based or specific weekdays)
- Local notifications to remind you when plants need watering
- Photo capture via camera or photo library
- Search functionality to find plants by name or species
- Watering history tracking with calendar view
- Full accessibility support with VoiceOver labels and hints
- Modern Liquid Glass UI design (iOS 26+)

## SCREENSHOTS

![Plant list view showing multiple plants with their watering schedules](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.27.26)
![Delete Option from Plant list view](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.27.40)
![Plant detail view with photo and watering information](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.28.19)
![Plant calendar view showing history](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.28.35)
![Add/Edit plant form with photo picker and schedule options](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.28.45)
![Add/Edit plant form with interval options](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.29.00)
![Add/Edit plant form with weekday options](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.29.08)
![Notification reminder for watering a plant](docs/Simulator Screenshot - iPhone 17 Pro - 2026-01-31 at 08.30.01)

## REQUIREMENTS

- iOS 26.0 or later
- Xcode 16 or later
- Swift 6.0 or later


## INSTALLATION & SETUP

1. Clone or download the project
2. Open the project in Xcode
3. Build and run on a device or simulator
4. Grant notification permissions when prompted (required for watering reminders)
4. Grant camera permissions when prompted


## CAMERA SETUP FOR MAC DEVELOPMENT

When running the app in the iOS Simulator on a Mac, camera functionality requires RocketSim to be installed.

RocketSim is a developer tool that enables the iOS Simulator to access your Mac's camera. Without it, the camera feature will not work in the simulator (though selecting photos from the library will still work).

Download RocketSim: https://www.rocketsim.app

Once installed, the app will automatically detect and use RocketSim's camera capabilities when running in the simulator. The app checks for RocketSim at launch and loads the connection framework if available.


## NOTIFICATIONS

The app uses local notifications to remind you when your plants need watering. Notifications are scheduled based on each plant's watering schedule (either every X days or on specific weekdays).

- Notifications are requested on first launch
- You can manage notification permissions in iOS Settings
- Tapping a notification will take you directly to that plant's detail page
- Notifications are automatically rescheduled after marking a plant as watered


## ACCESSIBILITY

PlantLog is built with full accessibility support:

- All interactive elements have descriptive labels and hints
- VoiceOver navigation is fully supported
- Semantic grouping of related information
- Dynamic Type support for text scaling
- High contrast UI with the Liquid Glass design system
- Screen reader friendly date and time formatting
