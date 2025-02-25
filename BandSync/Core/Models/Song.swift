import Foundation

struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let duration: TimeInterval
    let event: Event
}
