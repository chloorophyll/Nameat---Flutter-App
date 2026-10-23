# Nameat!

Nameat! is a local food discovery app for students in Iloilo City. It helps
students find places to eat, save favorites, set a budget level for each
place, and add their own spots.

## Screenshots
| Discover | Place Details | Favorites |
| --- | --- | --- |
| ![Discover](docs/screenshots/discover.png) | ![Details](docs/screenshots/details.png) | ![Favorites](docs/screenshots/favorites.png) |

| Add / Edit Place | Filters |
| --- | --- |
| ![Form](docs/screenshots/form.png) | ![Filters](docs/screenshots/filters.png) |

## Features
- Discover list with search, cuisine filter, and budget filter
- Place details with address, hours, budget level, photo, and Open in Maps
- Favorites saved on the device
- Add, edit, and delete your own places, with form validation
- Photos added from the gallery
- Live OpenStreetMap data with an offline fallback
- Loading, error, empty, and no-internet states

## Packages Used
- provider: state management
- http: REST API calls
- shared_preferences: local storage
- image_picker: adding photos
- url_launcher: opening Google Maps
- flutter_launcher_icons and flutter_native_splash: app icon and splash screen

## Data Sources
- OpenStreetMap Overpass API (restaurants, cafes, and fast food in Iloilo City)
- OpenStreetMap Nominatim (address lookup)
- Data: OpenStreetMap contributors, ODbL

## Setup and Run
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run` (with an Android emulator or device)
4. Build a release APK with `flutter build apk --release`

## Team
| Member | Role |
| Frances Chloe Talaman ([@chloorophyll](https://github.com/chloorophyll)) | All roles: UI, state management, API/data layer, Git, and documentation |

## Debugging Case
**Bug:** [the exact error or symptom you saw]
**How I found it:** [terminal output, stack trace, or DevTools, and what it showed]
**Fix:** [what you changed]