import SwiftUI

struct SetlistView: View {
    @StateObject private var viewModel = SetlistViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            ForEach(viewModel.songs) { song in
                SongRowView(song: song)
            }
            .onMove(perform: viewModel.moveSongs)
            .onDelete(perform: viewModel.deleteSongs)
        }
        .navigationTitle("Setlist")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showingAddSong.toggle() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddSong) {
            AddSongView()
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct SongRowView: View {
    let song: SongViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(song.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "clock")
                Text(formatDuration(song.duration))
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            if let notes = song.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
