# 📱 White Label Platform for Branded Community, Event & Content Apps

A powerful platform enabling creators to launch fully branded mobile and web apps that foster real connections, monetize content, and manage events with ease.

## 🔥 Vision

The Creator's Canvas empowers creators—whether coaches, adult event curators, community leaders, or content influencers—to launch fully branded mobile and web apps that foster real connections, monetize content, and manage events with ease.

## 👤 Target Users (White Label Creators)

### Who they are:
- Adult event curators (initial niche)
- Coaches, spiritual leaders, artists, private chefs, performers
- Online educators or niche communities

### Needs:
- Full control over branding
- Easy setup with no-code/low-code options
- Monetization tools (subscriptions, pay-per-view, tips)
- Community engagement and analytics
- Privacy and security, especially for adult content

## 📱 Target Audience (End-Users)

### Who they are:
- Fans, attendees, and members of the creators' communities
- Seeking genuine interaction and engaging content

### Needs:
- Frictionless onboarding and account creation
- Safe space for connection (especially in adult contexts)
- Private messaging and interactive tools
- Clean, mobile-first experience

## 💡 Core Value Proposition

A platform that feels like your app—not just another platform. With powerful tools to grow your community, earn revenue, and manage events.

### Key Pillars:
- Full White Labeling (domain, logo, colors, layout)
- Cross-Platform (iOS, Android, Web)
- Modular Design (enable only what's needed)
- Secure & Scalable (built using Flutter + Firebase stack)

## 🧩 Feature Modules

### A. Community
- Video replies & native async video conversations
- Direct & group messaging
- Channels, threads, and community spaces
- Reactions, Q&A, polls
- Profile directory and matching

### B. Content
- Uploads: text, audio, video, and courses
- Monetization: subscriptions, tips, pay-per-view
- Digital products: eBooks, merch, exclusive drops

### C. Events
- In-person & virtual event tools
- Ticketing, RSVPs, speaker/sponsor management
- Breakout rooms & post-event community spaces

### D. Monetization
- Stripe or LemonSqueezy integration
- Flexible pricing tiers for members
- Support for crypto/paywall tokens (future)

### E. AI & Analytics
- Content tagging, moderation support
- Engagement heatmaps
- Auto content recaps or suggestion engines

### F. Trust, Privacy & Security
- Built-in moderation dashboard
- Anonymity options for end-users
- End-to-end encrypted payments (future)
- Adult-safe guardrails and compliance controls

## ✨ Differentiators
- Asynchronous video-first design for authentic engagement
- Adult-content ready: platform, not censorship-focused
- Built on scalable Flutter & Firebase infrastructure (low overhead, quick launch)
- AI-enhanced creator tools (launch faster, engage deeper)

## 🛠 Recommended MVP Plan

### 🎯 Phase 1: MVP (4–6 weeks)
**Goal**: Launch a working app for one initial client (adult event curator)

**Core Modules:**
- White-labeled app shell (Flutter with Firebase auth, theming, routing)
- Event module: ticketing, RSVPs, event page
- Community feed: video-first posting, reactions, basic profiles
- Monetization: Stripe + Firestore tier system
- Admin dashboard: simple creator portal (web or mobile)
- Privacy & content flagging mechanism

**Tech Stack:**
- Flutter + Firebase (auth, Firestore, functions, cloud storage)
- Stripe for payments
- Riverpod for state management

### 🪜 Phase 2: Scale Up
- Add course builder or digital product store
- Launch native iOS/Android from single Flutter codebase
- Add AI auto-moderation and insight tools
- Enable creator onboarding self-service UI

## 🧱 Architecture Overview

This project is structured using a **Hybrid Clean Architecture** approach combined with a **Feature-First** organization. It aligns with scalable, testable, and maintainable mobile engineering practices expected of a Senior Flutter Engineer.

## 📁 Folder Structure

lib/
├── core/ # Global services, configs, and utilities
│ ├── services/ # e.g., StripeService, FCMService
│ ├── theme/ # App-wide styles and colors
│ └── utils/ # Helper functions and constants
│
├── features/ # Organized by feature, with internal layers
│ ├── tipping/ # Example feature
│ │ ├── data/ # Firestore models, remote sources
│ │ ├── domain/ # Entities, abstract repos, use cases
│ │ ├── state/ # Riverpod providers, controllers
│ │ └── ui/ # Screens and widgets
│
│ ├── events/
│ ├── feed/
│ └── profile/
│
├── router/ # Centralized routing logic (GoRouter)
├── l10n/ # Localization
└── main.dart # App entry point

## 🧩 Layered Responsibilities

**Data Layer**: Handles Firestore, REST APIs, Stripe, etc.
**Domain Layer**: Defines business logic via entities, use cases, and abstract contracts.
**State Layer**: Powered by Riverpod (StateNotifier, AsyncValue), managing app state per feature.
**UI Layer**: Contains screens and reusable widgets.
**Core**: Shared utilities, global services (notifications, payment, logging, etc.)

## ✅ Best Practices Implemented

Follows **Clean Architecture** for separation of concerns
Organized **per feature** to aid scalability and maintainability
Built using **Riverpod** for reactive, testable state management
Modular and ready for **white-label configurations**
Designed to support **Firebase integration** (Auth, Firestore, FCM, Storage)
Stripe integration for **payment-based events**
Setup for **unit and widget testing**
Prepared for **CI/CD pipelines** (GitHub Actions, Firebase Hosting)



# Deep Link Setup Guide

This guide explains how to set up deep links for different environments in the White Label Community App.

## Environment Configuration

The app uses environment variables to configure deep links for different environments (development, staging, production). You can set these variables in a `.env` file at the root of your project.

### Creating a .env File

Create a `.env` file in the root directory of your project with the following content:

```
# App Configuration
APP_NAME=White Label Community
APP_SCHEME=whitecommunity

# Deep Link Configuration
DEEP_LINK_DOMAIN=whitecommunity.page.link
DEEP_LINK_URI_PREFIX=https://whitecommunity.page.link

# Environment (development, staging, production)
ENVIRONMENT=development
```

### Environment-Specific Configurations

#### Development Environment

For local development, you might want to use a local server:

```
# App Configuration
APP_NAME=White Label Community (Dev)
APP_SCHEME=whitecommunity

# Deep Link Configuration
DEEP_LINK_DOMAIN=localhost
DEEP_LINK_URI_PREFIX=http://localhost:8080

# Environment
ENVIRONMENT=development
```

**Note for Emulators:**

- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For iOS Simulator, use `localhost`

#### Staging Environment

```
# App Configuration
APP_NAME=White Label Community (Staging)
APP_SCHEME=whitecommunity

# Deep Link Configuration
DEEP_LINK_DOMAIN=staging-whitecommunity.page.link
DEEP_LINK_URI_PREFIX=https://staging-whitecommunity.page.link

# Environment
ENVIRONMENT=staging
```

#### Production Environment

```
# App Configuration
APP_NAME=White Label Community
APP_SCHEME=whitecommunity

# Deep Link Configuration
DEEP_LINK_DOMAIN=whitecommunity.page.link
DEEP_LINK_URI_PREFIX=https://whitecommunity.page.link

# Environment
ENVIRONMENT=production
```

## Setting Up Deep Links on Different Platforms

### Android Setup

1. Make sure your `AndroidManifest.xml` has the correct intent filters:

```xml
<!-- App Links handling -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:host="${DEEP_LINK_DOMAIN}"
        android:scheme="https"/>
</intent-filter>

<!-- Custom URL scheme for deep linking -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="${APP_SCHEME}" />
</intent-filter>
```

### iOS Setup

1. Update your `Info.plist` with the correct configuration:

```xml
<!-- Deep linking configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.whiteLabelCommunityApp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>${APP_SCHEME}</string>
        </array>
    </dict>
</array>

<!-- Associated Domains for Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:${DEEP_LINK_DOMAIN}</string>
</array>
```

## Testing Deep Links

### Android

```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://whitecommunity.page.link/payment-success?eventId=123&sessionId=session_456&status=success" com.example.white_label_community_app
```

### iOS

```bash
xcrun simctl openurl booted "https://whitecommunity.page.link/payment-success?eventId=123&sessionId=session_456&status=success"
```

### Web

Simply navigate to the URL in your browser:

```
https://whitecommunity.page.link/payment-success?eventId=123&sessionId=session_456&status=success
```

## Troubleshooting

If deep links are not working:

1. Ensure your `.env` file has the correct configuration for your environment
2. Check that the `AppConfig.loadFromEnv()` method is called before any deep link handling
3. Verify that your platform-specific configurations (AndroidManifest.xml, Info.plist) are correct
4. For local development, ensure your local server is running and accessible
5. Check the logs for any errors related to deep link handling

For more information, see the `AppConfig` class in `lib/core/config/app_config.dart`.
