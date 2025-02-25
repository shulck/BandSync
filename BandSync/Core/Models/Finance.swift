import Foundation

struct Event: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let location: String
    let finance: Finance
    let song: Song
}
