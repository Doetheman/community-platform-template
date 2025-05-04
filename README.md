## 📱 White-Label Community App – Architecture Overview

## 🧱 Architecture Overview
This project is structured using a **Hybrid Clean Architecture** approach combined with a **Feature-First** organization. It aligns with scalable, testable, and maintainable mobile engineering practices expected of a Senior Flutter Engineer.

## 📁 Folder Structure
lib/
├── core/                      # Global services, configs, and utilities
│   ├── services/              # e.g., StripeService, FCMService
│   ├── theme/                 # App-wide styles and colors
│   └── utils/                 # Helper functions and constants
│
├── features/                  # Organized by feature, with internal layers
│   ├── tipping/               # Example feature
│   │   ├── data/              # Firestore models, remote sources
│   │   ├── domain/            # Entities, abstract repos, use cases
│   │   ├── state/             # Riverpod providers, controllers
│   │   └── ui/                # Screens and widgets
│
│   ├── events/
│   ├── feed/
│   └── profile/
│
├── router/                    # Centralized routing logic (GoRouter)
├── l10n/                      # Localization
└── main.dart                  # App entry point

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