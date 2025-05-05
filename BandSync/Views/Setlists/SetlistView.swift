import SwiftUI

struct SetlistView: View {
    @StateObject private var service = SetlistService.shared
    @State private var showAdd = false
    @State private var showTimedAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(service.setlists) { setlist in
                    NavigationLink(destination: SetlistDetailView(setlist: setlist)) {
                        VStack(alignment: .leading) {
                            Text(setlist.name)
                                .font(.headline)
                            Text("Songs: \(setlist.songs.count) • Duration: \(setlist.formattedTotalDuration)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Setlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAdd = true
                        } label: {
                            Label("Add Regular Setlist", systemImage: "music.note.list")
                        }
                        
                        Button {
                            showTimedAdd = true
                        } label: {
                            Label("Create by Concert Time", systemImage: "timer")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if let groupId = AppState.shared.user?.groupId {
                    service.fetchSetlists(for: groupId)
                }
            }
            .sheet(isPresented: $showAdd) {
                AddSetlistView()
            }
            .sheet(isPresented: $showTimedAdd) {
                TimedSetlistView()
            }
        }
    }
}
