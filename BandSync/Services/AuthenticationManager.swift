import Foundation

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Implement login logic here
    }

    func logout() {
        // Implement logout logic here
    }
}
