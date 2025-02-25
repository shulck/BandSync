import Foundation

enum Config {
    static let appName = "BandSync"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    enum API {
        static let baseURL = "https://api.bandsync.com"
        static let timeout: TimeInterval = 30
    }
    
    enum Cache {
        static let maxSize: Int = 50 * 1024 * 1024 // 50 MB
        static let timeToLive: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    }
    
    enum Validation {
        static let minPasswordLength = 8
        static let maxTitleLength = 100
        static let maxNotesLength = 1000
    }
}