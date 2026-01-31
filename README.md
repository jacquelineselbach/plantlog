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

Screenshots of the running App can be found in Docs package, showcasing the implemented features.

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
