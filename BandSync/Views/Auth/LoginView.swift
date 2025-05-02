//
//  LoginView.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//


import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showForgotPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 40)

                    VStack(spacing: 24) {
                        Text("Welcome Back 👋")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primary)

                        Group {
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                .cornerRadius(12)

                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }



                        Button(action: {
                            viewModel.login()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Login")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                        }
                        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)

                        Button(action: {
                            authenticateWithFaceID()
                        }) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Login with Face ID")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }

                        Button("Forgot password?") {
                            showForgotPassword = true
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    .shadow(radius: 20)

                    Spacer()

                    NavigationLink(destination: RegisterView()) {
                        Text("Don’t have an account? Register")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding()
            }
            .fullScreenCover(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with Face ID") { success, error in
                DispatchQueue.main.async {
                    if success {
                        viewModel.isAuthenticated = true
                    } else {
                        viewModel.errorMessage = "Face ID authentication failed."
                    }
                }
            }
        } else {
            viewModel.errorMessage = "Face ID is not available on this device."
        }
    }
}
