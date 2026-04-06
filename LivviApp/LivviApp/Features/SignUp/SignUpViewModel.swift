//
//  SignUpViewModel.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import Foundation
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var isloading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignedUp: Bool = false
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService(authStore: KeychainAuthStore())) {
        self.networkService = networkService
    }
    
    func signUp() async -> Bool {
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "All fields are required."
            return false
        }
        
        isloading = true
        errorMessage = nil
        
        let request = SignUpRequest(firstName: firstName, lastName: lastName, email: email, password: password)
        let endpoint = AuthEndpoint.signUp(request)
        
        do {
            let _: UserResponse = try await networkService.request(endpoint)
            isloading = false
            isSignedUp = true
            
            return true
        } catch let NetworkError.httpError(_, apiError) {
            errorMessage = apiError?.description ?? "An unknown error occurred."
            isloading = false
            
            return false
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            isloading = false
            
            return false
        }
    }
}
