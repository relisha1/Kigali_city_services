Project Overview

The Kigali City Services & Places Directory is a mobile application built using Flutter and Firebase. The goal of the application is to help residents and visitors in Kigali easily find important services and places such as hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions.

Users can create an account, browse available listings, and contribute by adding their own service locations. All data is stored in Firebase Firestore, which allows the application to update information in real time across all users.

This project demonstrates the integration of Flutter frontend development with Firebase backend services, including authentication, cloud databases, and real-time updates.

Application Features

The application provides the following main features.

User Authentication

The app uses Firebase Authentication to manage user accounts.

Users can:

Sign up using an email and password

Verify their email address before accessing the application

Log in and log out securely

After registration, a user profile is created in Firestore and linked to the user's UID.
Any listing created by the user is associated with this UID.

Location Listings (CRUD)

Users can create and manage listings for services and places within Kigali.

Each listing contains the following information:

Place or Service Name

Category (Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction)

Address

Contact Number

Description

Geographic Coordinates (Latitude and Longitude)

Created By (User UID)

Timestamp

The application supports full CRUD functionality:

Create a new listing

View all listings in the directory

Update listings created by the authenticated user

Delete listings created by the authenticated user

All updates appear immediately in the UI using state management and Firestore real-time updates.

Search and Category Filtering

Users can search for services by name and filter listings by category.

Examples of categories include:

Hospital

Police Station

Library

Restaurant

Café

Park

Tourist Attraction

Search results update dynamically as the user types or changes filters.

Listing Detail Page and Map Integration

When a listing is selected, the user is navigated to a detail page displaying all information about that location.

This page includes:

Full service information

Contact details

Address

Description

Embedded Google Map

The map displays a marker using the stored latitude and longitude coordinates from Firestore.

A navigation button is also provided which launches Google Maps turn-by-turn directions to the selected location.

Technologies Used

The following technologies were used to develop the application.

Flutter
Used for building the mobile application UI and overall application logic.

Dart
The programming language used by Flutter.

Firebase Authentication
Used for secure user signup, login, logout, and email verification.

Cloud Firestore
Used as the cloud database to store service listings and user profiles.

Google Maps Flutter API
Used to display map markers and provide navigation functionality.

Provider (State Management)
Used to manage application state and connect Firestore data to the UI.

Firestore Database Structure

The application stores data using Cloud Firestore.

Two main collections are used.

Users Collection

Stores profile information for authenticated users.

users
   userId
      email
      createdAt
Listings Collection

Stores all service or location listings.

listings
   listingId
      name
      category
      address
      contactNumber
      description
      latitude
      longitude
      createdBy
      timestamp

Each listing is associated with the UID of the user who created it.

State Management and Architecture

The application uses Provider for state management.

A clean architecture approach was followed where Firestore interactions are separated from the UI.

The architecture is structured as follows:

Models
Define the structure of data used in the application.

Services
Handle all Firebase operations such as authentication and Firestore CRUD operations.

Providers
Manage application state and expose data to the UI.

Screens / UI
Display data to the user and react to state changes.

Firestore queries are never called directly inside UI widgets.
Instead, UI components interact with providers, which communicate with the service layer.

This approach ensures:

Clean separation of concerns

Easier maintenance

Automatic UI updates when Firestore data changes

Navigation Structure

The application uses a BottomNavigationBar with four main screens.

Directory

Displays all available listings stored in Firestore.

Users can:

Browse services

Search listings

Filter by category

My Listings

Displays only the listings created by the authenticated user.

Users can:

Edit their listings

Delete their listings

Map View

Displays service listings on a map using their stored geographic coordinates.

Settings

Displays the authenticated user profile information.

This screen also includes a toggle for location-based notification preferences (simulated locally).

Project Structure

The project follows a structured Flutter folder organization.

lib/
   models/
   services/
   providers/
   screens/
   widgets/
   main.dart

models → data models for listings and users

services → Firebase authentication and Firestore operations

providers → state management logic

screens → UI pages of the application

widgets → reusable UI components

Firebase Setup

To run the project, Firebase must be configured.

Create a Firebase project in the Firebase Console

Enable Firebase Authentication (Email/Password)

Create a Cloud Firestore database

Register the Android or iOS app in Firebase

Download the Firebase configuration file

For Android, place the file in:

android/app/google-services.json
How to Run the Project

Clone the repository

git clone https://github.com/relisha1/Kigali_city_services.git

Navigate to the project folder

cd Kigali_city_services

Install dependencies

flutter pub get

Run the application

flutter run

The application can be executed on an Android emulator, iOS simulator, or a physical mobile device.

Repository

GitHub Repository:

https://github.com/relisha1/Kigali_city_services
