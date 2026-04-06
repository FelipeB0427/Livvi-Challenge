# Overview

LivviApp is a small iOS application module that demonstrates common patterns for:

- Networking (typed endpoints, generic response decoding)
- Authentication and secure token storage
- Parsing BLE event payloads from IoT door devices
- Organizing SwiftUI views and view models for authentication and door management

Architecture

- Core/Network: NetworkService, Endpoint definitions, and error models
- Core/Parser: BLEEventParser which converts base64 device payloads into human-readable events
- Core/Security & Storage: CryptoManager and AuthStore for token persistence and permissions
- Features: ViewModels and Views (Auth, Doors, DoorEvents, SignUp)

See the HowTos for practical examples on making network requests and parsing BLE events.