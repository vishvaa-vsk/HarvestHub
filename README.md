# HarvestHub

HarvestHub is a modern farming companion app designed to provide farmers with real-time weather updates, agricultural insights, and community support. The app leverages advanced technologies like Firebase, Weather API, and Google Generative AI to deliver a seamless and informative user experience.

## Features

- **Weather Updates**: Get real-time weather data, including temperature, humidity, wind speed, and 3-day forecasts.
- **Agricultural Insights**: Receive farming tips and crop recommendations based on current weather conditions.
- **Language Support**: Supports multiple Indian regional languages and popular foreign languages for a personalized experience.
- **AI Chat**: Interact with an AI-powered assistant for farming-related queries.
- **Pest Detection**: Placeholder feature for detecting pests (future implementation).
- **Community Support**: Connect with other farmers in the community.
- **Profile Management**: Edit profile settings and manage user preferences.

## Technology Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **APIs**:
  - Weather API for weather data
  - Google Generative AI for agricultural insights
- **State Management**: Provider
- **Localization**: Flutter's `intl` package and `.arb` files

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/harvesthub.git
   ```
2. Navigate to the project directory:
   ```bash
   cd harvesthub
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Set up Firebase:
   - Add your `google-services.json` file to the `android/app` directory.
   - Add your `GoogleService-Info.plist` file to the `ios/Runner` directory.
5. Run the app:
   ```bash
   flutter run
   ```

## Folder Structure

- **`lib/`**: Contains the main application code.
  - **`core/`**: Core services, providers, and utilities.
  - **`features/`**: Feature-specific code (e.g., authentication, home).
  - **`l10n/`**: Localization files.
- **`android/`** and **`ios/`**: Platform-specific configurations.
- **`assets/`**: Icons and animations.

## How It Works

1. **Authentication**:
   - Users authenticate using their phone number and OTP.
   - After authentication, users can select their preferred language.

2. **Weather and Insights**:
   - The app fetches weather data from the Weather API.
   - Agricultural insights are generated using Google Generative AI based on weather conditions.

3. **Language Support**:
   - Users can change the app's language from the drawer menu.
   - The app dynamically updates weather data and insights in the selected language.

4. **Community and AI Chat**:
   - Placeholder features for community support and AI-powered chat.

## Contributing

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add some feature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For any inquiries or support, please contact [kvishvaa6@gmail.com].
