//
//  AuthViewModel.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isloading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let networkService: NetworkServiceProtocol
    private let authStore: AuthStore
    
    init(networkService: NetworkServiceProtocol = NetworkService(authStore: KeychainAuthStore()),
        authStore: AuthStore = KeychainAuthStore()) {
        self.networkService = networkService
        self.authStore = authStore
        
        self.isAuthenticated = authStore.getToken() != nil
    }
    
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
    
    func logout() {
        authStore.deleteToken()
        self.isAuthenticated = false
    }
}
