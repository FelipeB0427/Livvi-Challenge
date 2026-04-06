//
//  SignUpView.swift
//  LivviApp
//
//  Created by Felipe on 05/04/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Password must be beetween 4 and 12 characters, and include at least one uppercase letter, one lowercase letter, one number, and one special character.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.signUp()
                    if success {
                        dismiss()
                    }
                }
            }) {
                if viewModel.isloading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
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
    }
}
