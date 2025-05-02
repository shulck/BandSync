//
//  RegisterView.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showLoadingIndicator = false
    @State private var emailVerified = false

    @State private var nameError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var phoneError = ""

    var body: some View {
        ZStack {

            VStack {
                Spacer(minLength: 40)

                VStack(spacing: 24) {
                    if !viewModel.isEmailVerificationSent && !emailVerified {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.primary)

                        Group {
                            CustomTextField("Full Name", text: $viewModel.name, error: nameError)
                            CustomTextField("Email", text: $viewModel.email, keyboardType: .emailAddress, error: emailError)
                            CustomSecureField(placeholder: "Password", text: $viewModel.password, error: passwordError)
                            CustomTextField("Phone Number", text: $viewModel.phone, keyboardType: .phonePad, error: phoneError)
                        }

                        Button(action: {
                            if validateFields() {
                                viewModel.register()
                                showLoadingIndicator = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Register")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                        }

                        if showLoadingIndicator {
                            ProgressView("Sending verification email…")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                    } else {
                        Spacer()

                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)

                        Text("Verification Email Sent")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        Text("A verification email has been sent to:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(viewModel.email)
                            .font(.body)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)

                        Text("After verifying your email, you can directly go to login to use the application.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Login")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                        }
                        .padding(.top, 16)

                        Spacer()
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.top, -12)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .shadow(radius: 10)

                Spacer()

                if !viewModel.isEmailVerificationSent && !emailVerified {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Already have an account? Log in")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isEmailVerificationSent) { newValue in
            if newValue {
                showLoadingIndicator = false
            }
        }
        .onChange(of: viewModel.isAuthenticated) { newValue in
            if newValue {
                emailVerified = true
            }
        }
    }

    func validateFields() -> Bool {
        var isValid = true

        nameError = viewModel.name.count >= 3 ? "" : "Name must be at least 3 characters"
        emailError = isValidEmail(viewModel.email) ? "" : "Invalid email address"
        passwordError = viewModel.password.count >= 6 ? "" : "Password must be at least 6 characters"
        phoneError = viewModel.phone.count >= 8 ? "" : "Enter a valid phone number"

        return [nameError, emailError, passwordError, phoneError].allSatisfy { $0.isEmpty }
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}




