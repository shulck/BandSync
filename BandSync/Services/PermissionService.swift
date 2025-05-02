//
//  PermissionService.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 31.03.2025.
//


//
//  PermissionService.swift
//  BandSync
//
//  Created by Claude AI on 31.03.2025.
//

import Foundation
import FirebaseFirestore
import Combine

final class PermissionService: ObservableObject {
    static let shared = PermissionService()
    
    @Published var permissions: PermissionModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Automatic permission check when user changes
        AppState.shared.$user
            .removeDuplicates()
            .sink { [weak self] user in
                if let groupId = user?.groupId {
                    self?.fetchPermissions(for: groupId)
                } else {
                    self?.permissions = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // Get permissions for group
    func fetchPermissions(for groupId: String) {
        isLoading = true
        
        db.collection("permissions")
            .whereField("groupId", isEqualTo: groupId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error loading permissions: \(error.localizedDescription)"
                    return
                }
                
                if let document = snapshot?.documents.first {
                    do {
                        let permissionModel = try document.data(as: PermissionModel.self)
                        DispatchQueue.main.async {
                            self.permissions = permissionModel
                        }
                    } catch {
                        self.errorMessage = "Error converting permission data: \(error.localizedDescription)"
                    }
                } else {
                    // If no permissions for group, create default ones
                    self.createDefaultPermissions(for: groupId)
                }
            }
    }
    
    // Create default permissions for new group
    func createDefaultPermissions(for groupId: String) {
        isLoading = true
        
        // Default permissions for all modules
        let defaultModules: [PermissionModel.ModulePermission] = ModuleType.allCases.map { moduleType in
            // By default, admins and managers have access to everything
            // Regular members - only to calendar, setlists, tasks, and chats
            let roles: [UserModel.UserRole]
            
            switch moduleType {
            case .admin:
                // Only admins can access admin panel
                roles = [.admin]
            case .finances, .merchandise, .contacts:
                // Finances, merch, and contacts require manager rights
                roles = [.admin, .manager]
            case .calendar, .setlists, .tasks, .chats:
                // Basic modules available to all
                roles = [.admin, .manager, .musician, .member]
            }
            
            return PermissionModel.ModulePermission(moduleId: moduleType, roleAccess: roles)
        }
        
        let newPermissions = PermissionModel(groupId: groupId, modules: defaultModules)
        
        do {
            _ = try db.collection("permissions").addDocument(from: newPermissions) { [weak self] error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error creating permissions: \(error.localizedDescription)"
                } else {
                    // Load created permissions
                    self.fetchPermissions(for: groupId)
                }
            }
        } catch {
            isLoading = false
            errorMessage = "Error serializing permission data: \(error.localizedDescription)"
        }
    }
    
    // Update module permissions
    func updateModulePermission(moduleId: ModuleType, roles: [UserModel.UserRole]) {
        guard let permissionId = permissions?.id else { return }
        isLoading = true
        
        // Find existing module to update
        if var modules = permissions?.modules {
            if let index = modules.firstIndex(where: { $0.moduleId == moduleId }) {
                modules[index] = PermissionModel.ModulePermission(moduleId: moduleId, roleAccess: roles)
                
                db.collection("permissions").document(permissionId).updateData([
                    "modules": modules.map { [
                        "moduleId": $0.moduleId.rawValue,
                        "roleAccess": $0.roleAccess.map { $0.rawValue }
                    ]}
                ]) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Error updating permissions: \(error.localizedDescription)"
                    } else {
                        // Update local data
                        DispatchQueue.main.async {
                            self.permissions?.modules = modules
                        }
                    }
                }
            }
        }
    }
    
    // Check if user has access to a module
    func hasAccess(to moduleId: ModuleType, role: UserModel.UserRole) -> Bool {
        // Admins always have access to everything
        if role == .admin {
            return true
        }
        
        // Check permissions
        if let modulePermission = permissions?.modules.first(where: { $0.moduleId == moduleId }) {
            return modulePermission.hasAccess(role: role)
        }
        
        // If permissions not found, access is denied by default
        return false
    }
    
    // Check access for current user
    func currentUserHasAccess(to moduleId: ModuleType) -> Bool {
        guard let userRole = AppState.shared.user?.role else {
            return false
        }
        
        return hasAccess(to: moduleId, role: userRole)
    }
    
    // Get all modules that the user has access to
    func getAccessibleModules(for role: UserModel.UserRole) -> [ModuleType] {
        // Admins have access to everything
        if role == .admin {
            return ModuleType.allCases
        }
        
        // For other roles, filter modules by permissions
        return permissions?.modules
            .filter { $0.hasAccess(role: role) }
            .map { $0.moduleId } ?? []
    }
    
    // Get accessible modules for current user
    func getCurrentUserAccessibleModules() -> [ModuleType] {
        guard let userRole = AppState.shared.user?.role else {
            return []
        }
        
        return getAccessibleModules(for: userRole)
    }
    
    // Check if user has edit permission for a module
    // This is a stricter requirement, usually for admins and managers
    func hasEditPermission(for moduleId: ModuleType) -> Bool {
        guard let role = AppState.shared.user?.role else {
            return false
        }
        
        // Only admins and managers can edit
        return role == .admin || role == .manager
    }
    
    // Reset permissions to default values
    func resetToDefaults() {
        guard let groupId = AppState.shared.user?.groupId,
              let permissionId = permissions?.id else {
            return
        }
        
        // Delete current permissions and create new ones
        db.collection("permissions").document(permissionId).delete { [weak self] error in
            if error == nil {
                self?.createDefaultPermissions(for: groupId)
            }
        }
    }
    
    // Get list of roles that have access to a module
    func getRolesWithAccess(to moduleId: ModuleType) -> [UserModel.UserRole] {
        if let modulePermission = permissions?.modules.first(where: { $0.moduleId == moduleId }) {
            return modulePermission.roleAccess
        }
        return []
    }
}