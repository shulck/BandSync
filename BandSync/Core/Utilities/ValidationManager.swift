import Foundation

struct ValidationManager {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        let minLength = 8
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasDigit = password.contains(where: { $0.isNumber })
        
        return password.count >= minLength && hasUppercase && hasDigit
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}
