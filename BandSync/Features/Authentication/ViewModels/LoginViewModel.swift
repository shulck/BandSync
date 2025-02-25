import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    func login() {
        AuthenticationManager.shared.login(email: email, password: password) { result in
            // Handle login result
        }
    }
}
