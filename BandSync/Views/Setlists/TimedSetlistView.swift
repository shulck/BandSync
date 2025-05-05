//
//  TimedSetlistView.swift
//  BandSyncApp
//
//  Created by Oleksandr Kuziakin on 02.05.2025.
//


// TimedSetlistView.swift
import SwiftUI

struct TimedSetlistView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = SetlistService.shared
    
    @State private var setlistName = ""
    @State private var concertDuration = 60 // Duration in minutes
    @State private var breakDuration = 5 // Break duration in minutes
    @State private var availableSongs: [Song] = []
    @State private var selectedSongs: [Song] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var totalSelectedDuration = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Setlist Information")) {
                    TextField("Setlist Name", text: $setlistName)
                    
                    Stepper("Concert Duration: \(concertDuration) min", value: $concertDuration, in: 30...240, step: 5)
                    
                    Stepper("Break Duration: \(breakDuration) min", value: $breakDuration, in: 0...30)
                    
                    HStack {
                        Text("Total Selected:")
                        Spacer()
                        Text(formatDuration(totalSelectedDuration))
                            .foregroundColor(totalSelectedDuration > (concertDuration * 60) ? .red : .green)
                    }
                    
                    HStack {
                        Text("Target Duration:")
                        Spacer()
                        Text(formatDuration(concertDuration * 60))
                    }
                }
                
                Section(header: Text("Available Songs")) {
                    if availableSongs.isEmpty {
                        Text("No songs available")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(availableSongs) { song in
                                if !selectedSongs.contains(where: { $0.id == song.id }) {
                                    Button {
                                        selectedSongs.append(song)
                                        updateTotalDuration()
                                    } label: {
                                        HStack {
                                            Text(song.title)
                                            Spacer()
                                            Text(song.formattedDuration)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Selected Songs")) {
                    if selectedSongs.isEmpty {
                        Text("No songs selected")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(selectedSongs) { song in
                                HStack {
                                    Text(song.title)
                                    Spacer()
                                    Text(song.formattedDuration)
                                        .foregroundColor(.gray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if let index = selectedSongs.firstIndex(where: { $0.id == song.id }) {
                                        selectedSongs.remove(at: index)
                                        updateTotalDuration()
                                    }
                                }
                            }
                            .onMove { from, to in
                                selectedSongs.move(fromOffsets: from, toOffset: to)
                            }
                        }
                    }
                }
                
                if errorMessage != nil {
                    Section {
                        Text(errorMessage!)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Optimize for Time") {
                        optimizeForTime()
                    }
                    .disabled(availableSongs.isEmpty)
                }
            }
            .navigationTitle("Create Timed Setlist")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveSetlist()
                }
                .disabled(setlistName.isEmpty || selectedSongs.isEmpty)
            )
            .onAppear {
                loadSongs()
            }
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            )
        }
    }
    
    private func loadSongs() {
        isLoading = true
        
        // Load all songs from all setlists for selection
        if let groupId = AppState.shared.user?.groupId {
            service.fetchSetlists(for: groupId)
            
            // Extract all unique songs from existing setlists
            var uniqueSongs: [Song] = []
            for setlist in service.setlists {
                for song in setlist.songs {
                    if !uniqueSongs.contains(where: { $0.id == song.id }) {
                        uniqueSongs.append(song)
                    }
                }
            }
            
            availableSongs = uniqueSongs.sorted(by: { $0.title < $1.title })
        }
        
        isLoading = false
    }
    
    private func updateTotalDuration() {
        totalSelectedDuration = selectedSongs.reduce(0) { $0 + $1.totalSeconds }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func optimizeForTime() {
        // Reset selection
        selectedSongs = []
        
        // Target duration in seconds, accounting for breaks
        let targetSeconds = (concertDuration * 60) - (breakDuration * 60)
        
        // Sort songs by duration (shortest first for greedy algorithm)
        let sortedSongs = availableSongs.sorted(by: { $0.totalSeconds < $1.totalSeconds })
        
        var currentDuration = 0
        
        // Simple greedy algorithm to fill the time
        for song in sortedSongs {
            if currentDuration + song.totalSeconds <= targetSeconds {
                selectedSongs.append(song)
                currentDuration += song.totalSeconds
            }
        }
        
        // Update total duration
        updateTotalDuration()
    }
    
    private func saveSetlist() {
        guard let userId = AppState.shared.user?.id,
              let groupId = AppState.shared.user?.groupId else {
            errorMessage = "User information not available"
            return
        }
        
        isLoading = true
        
        let newSetlist = Setlist(
            name: setlistName,
            userId: userId,
            groupId: groupId,
            isShared: true,
            songs: selectedSongs
        )
        
        service.addSetlist(newSetlist) { success in
            isLoading = false
            
            if success {
                dismiss()
            } else {
                errorMessage = "Failed to save setlist"
            }
        }
    }
}