//
//  ForgotPasswordView.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//


import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var emailSent = false

    var body: some View {
        ZStack {
            // Adaptive Background Gradient
            LinearGradient(
                colors: [
                    Color(.systemBlue).opacity(0.2),
                    Color(.systemPurple).opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer(minLength: 60)

                VStack(spacing: 20) {
                    Text("Reset Your Password")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if emailSent {
                        Image(systemName: "envelope.open.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)

                        Text("Reset Email Sent")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)

                        Text("You can now reset your password using the email sent to:")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)

                        Text(viewModel.email)
                            .font(.body)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)

                        Text("After resetting your password, log in again using your new credentials.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Enter your email to receive password reset instructions.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)

                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)

                        Button(action: {
                            viewModel.resetPassword()
                            emailSent = true
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Reset Password")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                        }
                        .disabled(viewModel.email.isEmpty)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back to Login")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.tertiarySystemFill))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(radius: 20)

                Spacer()
            }
        }
    }
}
