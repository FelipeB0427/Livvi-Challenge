//
//  AuthViewModel.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation
import Combine

@MainActor
/// AuthViewModel manages the sign-in state and authentication actions used by the Auth screen.
///
/// This view model exposes published properties for the view to bind to and uses a
/// `NetworkServiceProtocol` to perform authentication requests. It persists tokens using
/// an `AuthStore` implementation (defaulting to `KeychainAuthStore`).
///
/// - SeeAlso: `SignInRequest`, `TokenResponse`, `AuthStore`
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isloading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let networkService: NetworkServiceProtocol
    private let authStore: AuthStore
    
    /// Create a new AuthViewModel.
    ///
    /// - Parameters:
    ///   - networkService: A `NetworkServiceProtocol` used to perform auth requests. A concrete
    ///                     `NetworkService` with a `KeychainAuthStore` is used by default.
    ///   - authStore: An `AuthStore` implementation responsible for persisting tokens.
    init(networkService: NetworkServiceProtocol? = nil,
        authStore: AuthStore? = nil) {
        // Defer default instance creation to the initializer body to avoid calling potentially
        // main-actor-isolated initializers in a non-isolated default argument context.
        self.networkService = networkService ?? NetworkService(authStore: KeychainAuthStore())
        self.authStore = authStore ?? KeychainAuthStore()

        self.isAuthenticated = self.authStore.getToken() != nil
    }
    
    /// Attempt to sign in using the currently-provided `email` and `password`.
    ///
    /// On success the returned token is saved in the `authStore` and `isAuthenticated` becomes `true`.
    /// On failure `errorMessage` is set with a user-friendly description.
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            return
        }
        
        isloading = true
        errorMessage = nil
        
        let request = SignInRequest(email: email, password: password)
        let endpoint = AuthEndpoint.signIn(request)
        
        do {
            let response: TokenResponse = try await networkService.request(endpoint)
            
            authStore.saveToken(response.token)
            self.isAuthenticated = true
        } catch let NetworkError.httpError(_, apiError) {
            self.errorMessage = apiError?.description ?? "An unknown error occurred."
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        isloading = false
    }
    
    /// Log out the current user by removing the saved token and clearing authentication state.
    func logout() {
        authStore.deleteToken()
        self.isAuthenticated = false
    }
}
