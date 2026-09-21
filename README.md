# FairShare 💰

FairShare is a Flutter-based expense splitting application that helps users manage shared expenses with friends, roommates, colleagues, or groups.

The app allows users to create groups, add members, record shared expenses, calculate balances, and generate settlement plans to simplify repayments.

## Features

* 🔐 User Authentication
* 👤 User Profiles
* 👥 Group Creation & Management
* ➕ Add Group Members
* 💰 Add Shared Expenses
* 🧾 Expense History
* ⚖️ Automatic Balance Calculation
* 💸 Settlement / Settle Up
* 📊 Settlement History
* 🔄 Real-time Firestore Updates
* ⚙️ Settings
* 🌙 Theme Support

## Technology Stack

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Cloud Firestore**
* **Provider** for state management

## Project Status

FairShare is currently under development as a Flutter internship/final-year project.

## 📱 Project Overview

FairShare is designed to make shared expense management simple and transparent.

Users can create groups for different purposes such as trips, roommates, events, or friends. Group members can record expenses and specify who paid and how the expense should be divided.

FairShare keeps track of each member's financial position and calculates how much each person owes or should receive.

The application also provides a settlement feature that generates a simplified payment plan between group members, helping reduce the number of payments required to settle the group balance.

### How FairShare Works

1. **Create an Account**
   Users can sign up and log in using their email and password.

2. **Create a Group**
   A user can create a group and add other members.

3. **Add Expenses**
   Members can record shared expenses by entering the description, amount, payer, and split method.

4. **Calculate Balances**
   FairShare calculates how much each member owes or is owed based on the recorded expenses.

5. **Settle Up**
   The settlement engine calculates the payments required between members to settle outstanding balances.

6. **Track Activity**
   Users can view expense and settlement activity within their groups.

7. **Real-time Updates**
   Firestore keeps the group's data synchronized so changes can be reflected across users' devices.

## 📂 Project Structure

The project follows a layered Flutter architecture to keep the application organized and maintainable.

```text
lib/
│
├── main.dart
│
├── models/
│   ├── user_model.dart
│   ├── group_model.dart
│   ├── expence_model.dart
│   ├── settlement_model.dart
│   └── activity_model.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── settlement_service.dart
│   └── activity_service.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── group_provider.dart
│   ├── expence_provider.dart
│   ├── settlement_provider.dart
│   └── activity_provider.dart
│
├── screens/
│   ├── auth/
│   ├── groups/
│   ├── expenses/
│   ├── activity/
│   └── settings/
│
└── widgets/
```

### Main Folders

| Folder       | Purpose                                             |
| ------------ | --------------------------------------------------- |
| `models/`    | Contains data models used by the application        |
| `services/`  | Handles Firebase and application-related operations |
| `providers/` | Manages application state using Provider            |
| `screens/`   | Contains the application's UI screens               |
| `widgets/`   | Contains reusable Flutter widgets                   |
| `main.dart`  | Entry point of the Flutter application              |

```

**Important:** Maine `expence_model.dart` aur `expence_provider.dart` tumhare current project ke naming ke according rakhe hain.

Ab **Step 3 save** karo aur mujhe `Step 3 done` bolo. Phir hum **Step 4 — Features ka detailed breakdown** banayenge.
```
## ✨ Features

### 🔐 Authentication

* User registration with email and password
* User login
* User logout
* Firebase Authentication integration
* User profile data stored in Firestore

### 👥 Groups

* Create a new expense group
* Add members to a group
* View group details
* Store group information in Cloud Firestore
* Manage group members

### 💰 Expenses

* Add shared expenses
* Select the person who paid
* Enter expense description and amount
* Support multiple split methods
* Equal expense splitting
* Exact amount splitting
* Share-based expense splitting
* Store expenses in Firestore
* View expense history

### ⚖️ Balances

FairShare calculates the financial balance of each group member based on:

* Expenses paid by each member
* Expenses owed by each member
* Individual expense splits
* Overall group balance

### 💸 Settlement

The settlement system calculates how group members can settle their outstanding balances.

The settlement engine:

* Calculates members' net balances
* Identifies members who need to pay
* Identifies members who should receive money
* Generates settlement transactions
* Reduces unnecessary payment transactions

### 📜 Settlement History

Users can view previous settlement transactions and track completed settlements within the group.

### 📊 Activity

The activity section provides information about important group actions such as:

* New expenses
* Expense updates
* Expense deletion
* Settlement activity
* Group-related activity

### 🔄 Real-time Data

Cloud Firestore is used to keep application data synchronized.

Changes to groups, expenses, and other relevant data can be reflected across users' devices through Firestore's real-time capabilities.

### ⚙️ Settings

The application includes a settings section where users can manage application preferences and access account-related options.

### 🌙 Theme Support

FairShare supports a clean light interface and includes dark-mode support for a better user experience.

## 🔥 Firebase Setup

FairShare uses Firebase for authentication and cloud data storage.

### Firebase Services Used

* **Firebase Authentication** — Handles user registration and login.
* **Cloud Firestore** — Stores users, groups, expenses, settlements, and activity data.

### Firebase Configuration

To configure Firebase for the project:

1. Create a project in the Firebase Console.
2. Add the required Flutter platforms to the Firebase project.
3. Enable **Email/Password Authentication**.
4. Create a **Cloud Firestore Database**.
5. Configure Firebase for the Flutter application using FlutterFire CLI.
6. Make sure the generated Firebase configuration files are available in the project.
7. Run the Flutter application.

### Firebase Configuration Command

If FlutterFire CLI is installed, Firebase can be configured using:

```bash
flutterfire configure
```

### Run the Project

After Firebase configuration, get the project dependencies:

```bash
flutter pub get
```

Then run the application:

```bash
flutter run
```

### Important

Firebase configuration files and credentials should be handled securely.

Do not add private credentials, API keys with restricted access, service-account files, or other sensitive Firebase configuration data to public repositories.

## 📦 Dependencies

FairShare uses the following main Flutter packages:

| Package           | Purpose                                              |
| ----------------- | ---------------------------------------------------- |
| `firebase_core`   | Initializes Firebase in the Flutter application      |
| `firebase_auth`   | Handles user authentication                          |
| `cloud_firestore` | Stores and retrieves application data from Firestore |
| `provider`        | Manages application state                            |

### Install Dependencies

After cloning the project, install all required packages using:

```bash
flutter pub get
```

### Check Flutter Environment

You can verify the Flutter installation with:

```bash
flutter doctor
```

### Run the Application

```bash
flutter run
```

The application can be run on an available Flutter-supported device or platform.

## 🧮 Expense Split Methods

FairShare supports different ways of dividing an expense between group members.

### 1. Equal Split

The total expense is divided equally among the selected members.

**Example:**

If an expense is **Rs. 3,000** and there are **3 members**:

```text
Member 1 → Rs. 1,000
Member 2 → Rs. 1,000
Member 3 → Rs. 1,000
```

### 2. Exact Amount Split

Each member can be assigned a specific amount.

**Example:**

For an expense of **Rs. 3,000**:

```text
Member 1 → Rs. 1,500
Member 2 → Rs. 1,000
Member 3 → Rs.   500
```

The assigned amounts must add up to the total expense.

### 3. Shares Split

The expense can be divided according to the number of shares assigned to each member.

**Example:**

For an expense of **Rs. 3,000**:

```text
Member 1 → 1 share
Member 2 → 2 shares
Member 3 → 3 shares
```

The total amount is distributed according to each member's share.

### Expense Information

Each expense records information such as:

* Expense description
* Total amount
* Person who paid
* Split method
* Individual member shares
* Expense date
* Group ID
* User who created the expense
* Creation timestamp

## ⚖️ Balance & Settlement System

FairShare calculates the financial position of each member based on the expenses recorded in a group.

### Balance Calculation

For each member, the application considers:

* Total amount paid by the member
* Total amount the member owes
* The member's resulting net balance

A member can have:

* **Positive balance** → The member should receive money.
* **Negative balance** → The member needs to pay money.
* **Zero balance** → The member has no outstanding amount.

### Example

Suppose a group has three members:

```text
Ali      → +Rs. 1,000
Ahmed    → -Rs.   600
Usman    → -Rs.   400
```

This means:

```text
Ahmed needs to pay Ali Rs. 600
Usman needs to pay Ali Rs. 400
```

After these payments, the group balances become zero.

### Settlement Engine

FairShare contains a settlement engine that processes the calculated balances and creates a simplified payment plan.

The settlement process:

```text
Expenses
   ↓
Calculate Individual Balances
   ↓
Identify Creditors
   ↓
Identify Debtors
   ↓
Match Payments
   ↓
Generate Settlement Transactions
```

### Settlement Transaction

A settlement transaction contains information about:

* Person who needs to pay
* Person who receives the payment
* Amount to be paid
* Related group
* Settlement status
* Settlement date

The settlement information can also be stored so that users can view their settlement history later.

## 🔄 Real-time Updates

FairShare uses **Cloud Firestore real-time listeners** to keep relevant application data synchronized.

When data changes in Firestore, connected users can receive the updated information without manually refreshing the application.

### Real-time Data Flow

```text
User Action
    ↓
Flutter Application
    ↓
Provider
    ↓
Firestore Service
    ↓
Cloud Firestore
    ↓
Real-time Listener
    ↓
Provider Updates State
    ↓
UI Updates Automatically
```

### Examples

Real-time updates can be used for:

* New group members
* New expenses
* Updated expenses
* Deleted expenses
* Balance changes
* Settlement information
* Activity updates

This allows members of the same group to see relevant changes across their devices while they are connected to the application.

### Firestore Data

The application uses Cloud Firestore to store application data such as:

```text
Users
Groups
Expenses
Settlements
Activities
```

The exact Firestore structure and security rules are configured separately from the Flutter UI.

## 🚀 Installation & Setup

Follow these steps to run FairShare locally.

### 1. Clone the Repository

```bash
git clone https://github.com/choudharysaeed/fair_share_app.git
```

Move into the project directory:

```bash
cd fair_share_app
```

### 2. Install Flutter Dependencies

Run:

```bash
flutter pub get
```

### 3. Configure Firebase

Make sure Firebase is configured for the project.

If FlutterFire CLI is available, run:

```bash
flutterfire configure
```

Select the Firebase project and the required platforms.

### 4. Check the Flutter Environment

Run:

```bash
flutter doctor
```

Resolve any required Flutter or platform configuration issues.

### 5. Run the Application

Run:

```bash
flutter run
```

You can also select a specific available device or platform from your Flutter development environment.

### 6. Build the Application

For an Android release build:

```bash
flutter build apk
```

The generated APK can be used for testing on an Android device.

## 🧪 Testing

Testing is an important part of the FairShare project to verify that the application's core logic works correctly.

### Run All Tests

Run the following command from the project root:

```bash
flutter test
```

### Settlement Engine Testing

FairShare includes tests for the settlement engine.

The settlement tests verify the calculation of balances and the generation of settlement transactions.

The test file is located at:

```text
test/
└── settlement_engine_test.dart
```

### What Is Tested

The settlement logic can be tested for scenarios such as:

* Members with positive balances
* Members with negative balances
* Balanced groups
* Multiple debtors
* Multiple creditors
* Settlement transaction generation

### Manual Testing

The application should also be manually tested for:

* User registration
* User login
* User logout
* Group creation
* Adding group members
* Adding expenses
* Different expense split methods
* Expense history
* Balance calculation
* Settlement generation
* Settlement history
* Activity updates
* Real-time Firestore updates
* Settings and theme changes

## 🖥️ Application Screens

FairShare contains multiple screens organized according to their functionality.

### 🔐 Authentication

* Login Screen
* Sign Up Screen

These screens allow users to create an account and securely access the application.

### 👥 Groups

* Home / Groups Screen
* Create Group Screen
* Group Details Screen
* Add Member Screen

Users can create groups, view their groups, and manage group members.

### 💰 Expenses

* Add Expense Screen
* Expense History Screen

Users can record shared expenses and view previously recorded expenses.

### ⚖️ Settlement

* Settle Up Screen
* Settlement History Screen

Users can view outstanding balances and generate or review settlement transactions.

### 📊 Activity

The Activity screen displays important actions and changes related to the application.

### ⚙️ Settings

The Settings screen provides application and account-related options, including theme preferences.

### 🎨 UI Design

The application follows a clean and simple interface with:

* Teal/green primary theme
* Rounded cards
* Clear typography
* Simple navigation
* Bottom navigation
* Light and dark theme support

The main bottom navigation sections are:

```text
Groups
Activity
Settings
```
## 🏗️ Architecture

FairShare follows a simple layered architecture using **Provider** for state management.

```text
UI / Screens
     ↓
Provider
     ↓
Services
     ↓
Firebase
     ↓
Cloud Firestore
```

### Main Layers

* **Models** — Define application data such as users, groups, expenses, settlements, and activities.
* **Providers** — Manage application state and update the UI.
* **Services** — Handle Firebase Authentication and Firestore operations.
* **Screens** — Provide the application's user interface.
* **Settlement Engine** — Calculates balances and generates settlement transactions.

## 🛠️ Requirements

Before running FairShare, make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Firebase account
* Git

### Check Flutter Installation

```bash
flutter --version
```

### Check Project

```bash
flutter doctor
```
## 👨‍💻 Developer

**Developed by:** Saeed Ahmad
**Project:** FairShare
**Platform:** Flutter
**Backend:** Firebase
**Database:** Cloud Firestore
**State Management:** Provider

### GitHub Repository

https://github.com/choudharysaeed/fair_share_app

