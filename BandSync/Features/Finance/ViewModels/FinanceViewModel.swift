import Foundation

class FinanceViewModel: ObservableObject {
    @Published var finances: [Finance] = []

    func loadFinances() {
        // Implement load finances logic
    }
}
