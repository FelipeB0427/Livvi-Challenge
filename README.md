# LivviApp

## Overview
LivviApp is an iOS application that demonstrates door access management, BLE event parsing, permissions sync and decryption, and authentication flows. The project includes a small network layer, parsing utilities, local storage for authentication, and DocC-based documentation for core types.

This project was developed with the help of the Gemini IA.

## Key features
1. Authentication
   1. Sign in and sign up flows implemented in `Features/Auth/`.
   2. Local authentication persistence via `Core/Storage/AuthStore.swift`.
2. Doors management
   1. Doors list and details in `Features/Doors/`.
   2. Door events viewer in `Features/DoorEvents/`.
3. BLE parsing
   1. BLE event parsing and utilities in `Core/Parser/BLEEventParser.swift`.
4. Permissions sync and decryption
   1. Permissions endpoint and client-side decryption with `Core/Security/*` and `Core/Network/*`.
5. Network layer
   1. Endpoints and API error handling in `Core/Network/`.
   2. `NetworkService` implements request handling and decoding.
6. Security helpers
   1. `CryptoManager` for encryption/decryption primitives used by permissions flow.
7. Documentation
   1. DocC catalog at `LivviApp/Documentation.docc` with a module overview and how-tos.
8. Tests
   1. Unit tests for BLE parsing in `LivviAppTests/BLE/BLEEventParserTests.swift`.

## Project structure (important paths)
1. `App/` — App entry point and assets.
2. `Core/Network/` — `APIError.swift`, `Endpoint.swift`, `NetworkService.swift`, and endpoints.
3. `Core/Parser/` — `BLEEventParser.swift`.
4. `Core/Storage/` — `AuthStore.swift`.
5. `Features/` — UI and view models for Auth, Doors, DoorEvents, SignUp, Permissions.
6. `Models/` — Domain models used across the app.
7. `Documentation.docc/` — DocC module and articles.
8. `LivviApp.xcodeproj` — Xcode project file.
9. `LivviAppTests/` — Unit tests.

## Build and run
1. Open `LivviApp.xcodeproj` in Xcode (Xcode 14+ recommended).
2. Select the `LivviApp` scheme and run on a simulator or device.

Command-line:
1. Build:
   - `xcodebuild -project LivviApp.xcodeproj -scheme LivviApp -configuration Debug build`
2. Run unit tests:
   - `xcodebuild -project LivviApp.xcodeproj -scheme LivviApp -configuration Debug test`

## Generate documentation (DocC)
1. Create the DocC archive:
   - `xcodebuild -project LivviApp.xcodeproj -scheme LivviApp docbuild -derivedDataPath ./docbuild`
2. Convert to static HTML:
   - `xcrun docc convert ./docbuild/Build/Intermediates.noindex/Documentation/*.doccarchive --output-path ./docsite --transform-for-static-hosting`
3. Open:
   - `open ./docsite/index.html`

## Tests
1. Unit tests located in `LivviAppTests/`.
2. Run tests in Xcode or via `xcodebuild` (see Build and run).

## Contributing
1. Open a branch and submit pull requests.
2. Keep changes small and include tests for logic and parsing changes.
3. Update DocC comments for public types and add symbol articles when needed.

## License
Distributed under the MIT License. See `LICENSE` if present.

## Credits
1. Project sources and code authored by the repository owner.
2. Assistance for documentation, design decisions, and implementation guidance provided by the Gemini IA.
