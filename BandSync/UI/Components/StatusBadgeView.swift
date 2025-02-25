import SwiftUI

struct StatusBadgeView: View {
    var status: EventStatus

    var body: some View {
        Text(status.rawValue)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
