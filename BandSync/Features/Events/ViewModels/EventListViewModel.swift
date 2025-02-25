import Foundation

class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []

    func loadEvents() {
        // Implement load events logic
    }
}
