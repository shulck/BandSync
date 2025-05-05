import Foundation
import FirebaseFirestore

struct Setlist: Identifiable, Codable, Hashable {
    @DocumentID var id: String?

    var name: String
    var userId: String
    var groupId: String
    var isShared: Bool
    var songs: [Song]

    var totalDuration: Int {
        songs.reduce(0) { $0 + $1.totalSeconds }
    }

    var formattedTotalDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Реализация протокола Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Setlist, rhs: Setlist) -> Bool {
        lhs.id == rhs.id
    }
}
