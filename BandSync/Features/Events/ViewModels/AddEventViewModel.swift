import Foundation

class AddEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var date: Date = Date()
    @Published var location: String = ""
    @Published var status: EventStatus = .upcoming

    func addEvent() {
        // Implement add event logic
    }
}
