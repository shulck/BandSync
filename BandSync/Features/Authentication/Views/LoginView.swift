import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            CustomTextField(placeholder: "Email", text: $viewModel.email)
            CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
            CustomButton(title: "Login", action: {
                viewModel.login()
            })
        }
        .padding()
    }
}
