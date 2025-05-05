//
//  RoleView.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//

import SwiftUI
import FirebaseFirestore

struct RoleView: View {
    let userId: String
    @StateObject private var groupService = GroupService.shared
    @State private var selectedRole: UserModel.UserRole = .member
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if isLoading {
            ProgressView("Loading user data...")
                .onAppear {
                    loadUserRole()
                }
        } else {
            Form {
                Section(header: Text("Select a role")) {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserModel.UserRole.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(groupService.isLoading || userId.isEmpty)
                }
                
                if groupService.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                if let error = groupService.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Change role")
        }
    }
    
    private func loadUserRole() {
        if let user = groupService.groupMembers.first(where: { $0.id == userId }) {
            self.selectedRole = user.role
            self.isLoading = false
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let user = groupService.groupMembers.first(where: { $0.id == userId }) {
                    self.selectedRole = user.role
                }
                self.isLoading = false
            }
        }
    }
    
    private func saveChanges() {
        guard !userId.isEmpty else {
            return
        }
        
        // Fix: Remove the completion handler if GroupService doesn't expect one
        groupService.changeUserRole(userId: userId, newRole: selectedRole)
        
        // Add a delay before dismissing to allow the operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
