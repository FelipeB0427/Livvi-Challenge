# How To: Make Network Requests

This guide shows how to use `NetworkService` to call backend endpoints and decode responses.

1. Create an endpoint (use the existing `AuthEndpoint`, `DoorsEndpoint`, etc.).
2. Call `NetworkService().request(endpoint)` to perform the request.

Example

```swift
let service = NetworkService()
let endpoint = AuthEndpoint.signIn(SignInRequest(email: "a@b.com", password: "pwd"))
let response: TokenResponse = try await service.request(endpoint)
```

Handle errors by catching `NetworkError` cases and inspecting `APIError` from the server side.