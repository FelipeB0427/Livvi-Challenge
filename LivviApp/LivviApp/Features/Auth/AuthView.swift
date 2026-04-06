//
//  AuthView.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Livvi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        await viewModel.signIn()
                    }
                }) {
                    if viewModel.isloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isloading)
                
                Spacer()
                
            }
            .padding()
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                Text("You are now signed in!")
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    AuthView()
}
