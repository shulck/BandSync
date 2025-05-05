import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore
import FirebaseAuth

@main
struct BandSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Init logic here if needed
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(AppState.shared)
                .onAppear {
                    print("SplashView: appeared")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("SplashView: launching deferred auth state update")
                        AppState.shared.refreshAuthState()
                    }
                }
//                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("BandSyncApp: App is active")
                // Проверяем, аутентифицирован ли пользователь
                if Auth.auth().currentUser != nil,
                   let userId = UserDefaults.standard.string(forKey: "userID"),
                   !userId.isEmpty {
                    // Даем Firebase время на инициализацию
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        FirebaseManager.shared.updateUserOnlineStatus(isOnline: true)
                    }
                }
                
            case .background, .inactive:
                print("BandSyncApp: App moved to background/inactive")
                if Auth.auth().currentUser != nil,
                   let userId = UserDefaults.standard.string(forKey: "userID"),
                   !userId.isEmpty {
                    FirebaseManager.shared.updateUserOnlineStatus(isOnline: false)
                }
                
            @unknown default:
                break
            }
        }
    }
}

extension FirebaseManager {
    func updateUserOnlineStatus(isOnline: Bool) {
        // Убедимся, что Firebase инициализирован
        self.ensureInitialized()
        
        // Проверяем наличие идентификатора пользователя и убеждаемся, что он не пустой
        guard let userId = UserDefaults.standard.string(forKey: "userID"),
              !userId.isEmpty,
              Auth.auth().currentUser != nil else {
            print("FirebaseManager: Нет ID пользователя или пользователь не аутентифицирован")
            return
        }

        let userRef = Firestore.firestore().collection("users").document(userId)
        let data: [String: Any] = [
            "isOnline": isOnline,
            "lastSeen": FieldValue.serverTimestamp()
        ]

        // Используем setData вместо updateData для создания документа, если он не существует
        userRef.setData(data, merge: true) { error in
            if let error = error {
                print("FirebaseManager: Ошибка обновления статуса: \(error.localizedDescription)")
            } else {
                print("FirebaseManager: Статус обновлен на isOnline=\(isOnline)")
            }
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
