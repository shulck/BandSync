import SwiftUI

struct AddSetlistView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = SetlistService.shared
    
    @State private var name: String = ""
    @State private var songs: [Song] = []
    @State private var newTitle: String = ""
    @State private var minutes: String = ""
    @State private var seconds: String = ""
    @State private var bpm: String = ""
    
    @State private var showExistingSongs = false
    @State private var selectedSetlist: Setlist? = nil
    @State private var availableSongs: [Song] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Information")) {
                    TextField("Setlist name", text: $name)
                }
                
                // New section for importing songs
                Section(header: Text("Import Songs")) {
                    Button("Import from existing setlist") {
                        showExistingSongs = true
                    }
                }

                Section(header: Text("Add song manually")) {
                    TextField("Title", text: $newTitle)
                    HStack {
                        TextField("Min", text: $minutes)
                            .keyboardType(.numberPad)
                        Text(":")
                        TextField("Sec", text: $seconds)
                            .keyboardType(.numberPad)
                    }
                    TextField("BPM", text: $bpm)
                        .keyboardType(.numberPad)

                    Button("Add") {
                        guard let min = Int(minutes), let sec = Int(seconds), let bpmVal = Int(bpm), !newTitle.isEmpty else { return }
                        let song = Song(title: newTitle, durationMinutes: min, durationSeconds: sec, bpm: bpmVal)
                        songs.append(song)
                        newTitle = ""
                        minutes = ""
                        seconds = ""
                        bpm = ""
                    }
                }

                Section(header: Text("Songs")) {
                    ForEach(songs) { song in
                        HStack {
                            Text(song.title)
                            Spacer()
                            Text("\(song.formattedDuration) - \(song.bpm) BPM")
                        }
                    }
                    .onDelete { indexSet in
                        songs.remove(atOffsets: indexSet)
                    }
                    .onMove { from, to in
                        songs.move(fromOffsets: from, toOffset: to)
                    }
                }

                Section {
                    HStack {
                        Text("Total duration")
                        Spacer()
                        Text(formattedTotalDuration)
                            .bold()
                    }
                }
            }
            .navigationTitle("Create Setlist")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let uid = AppState.shared.user?.id,
                              let groupId = AppState.shared.user?.groupId,
                              !name.isEmpty
                        else { return }

                        let setlist = Setlist(
                            name: name,
                            userId: uid,
                            groupId: groupId,
                            isShared: true,
                            songs: songs
                        )

                        SetlistService.shared.addSetlist(setlist) { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showExistingSongs) {
                SongSelectionView(selectedSongs: $songs)
            }
        }
    }

    private var formattedTotalDuration: String {
        let total = songs.reduce(0) { $0 + $1.totalSeconds }
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// New view for selecting songs from existing setlists
struct SongSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = SetlistService.shared
    @Binding var selectedSongs: [Song]
    
    @State private var selectedSetlist: Setlist? = nil
    @State private var tempSelectedSongs: [Song] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Setlist picker
                Picker("Select Setlist", selection: $selectedSetlist) {
                    Text("None").tag(nil as Setlist?)
                    ForEach(service.setlists) { setlist in
                        Text(setlist.name).tag(setlist as Setlist?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                if selectedSetlist != nil {
                    List {
                        ForEach(selectedSetlist!.songs) { song in
                            Button {
                                toggleSongSelection(song)
                            } label: {
                                HStack {
                                    Text(song.title)
                                    Spacer()
                                    Text("\(song.formattedDuration) - \(song.bpm) BPM")
                                        .foregroundColor(.gray)
                                    
                                    if tempSelectedSongs.contains(where: { $0.id == song.id }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                } else {
                    Text("Select a setlist to view songs")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Select Songs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected") {
                        // Add selected songs to the main view's songs array
                        for song in tempSelectedSongs {
                            if !selectedSongs.contains(where: { $0.id == song.id }) {
                                selectedSongs.append(song)
                            }
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select All") {
                        if let setlist = selectedSetlist {
                            tempSelectedSongs = setlist.songs
                        }
                    }
                }
            }
            .onAppear {
                if let groupId = AppState.shared.user?.groupId {
                    service.fetchSetlists(for: groupId)
                }
                
                // Initialize temp selection with songs already in the setlist
                tempSelectedSongs = selectedSongs
            }
        }
    }
    
    private func toggleSongSelection(_ song: Song) {
        if let index = tempSelectedSongs.firstIndex(where: { $0.id == song.id }) {
            tempSelectedSongs.remove(at: index)
        } else {
            tempSelectedSongs.append(song)
        }
    }
}
