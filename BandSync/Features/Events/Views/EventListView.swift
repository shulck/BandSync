import SwiftUI

struct EventListView: View {
    @StateObject private var viewModel = EventListViewModel()

    var body: some View {
        List(viewModel.events) { event in
            Text(event.title)
        }
        .onAppear {
            viewModel.loadEvents()
        }
    }
}
