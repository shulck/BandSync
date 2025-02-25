import Foundation

class SetlistViewModel: ObservableObject {
    @Published var songs: [Song] = []

    func loadSongs() {
        // Implement load songs logic
    }
}
