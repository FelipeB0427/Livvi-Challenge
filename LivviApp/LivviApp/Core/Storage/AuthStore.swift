//
//  AuthStore.swift
//  LivviApp
//
//  Created by Felipe on 01/04/26.
//

import Foundation
import Security

/// AuthStore defines an interface for persisting an authentication token.
protocol AuthStore {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

/// Keychain-backed implementation of `AuthStore`.
///
/// Stores the token as a generic password item under a fixed account identifier.
class KeychainAuthStore: AuthStore {
    private let service = "com.livvi.bearerToken"
    
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: service
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        var attributes = query
        attributes[kSecValueData as String] = data
        
        SecItemAdd(attributes as CFDictionary, nil)
    }
    
    func getToken() -> String? {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(decoding: data, as: UTF8.self)
        }
        
        return nil
    }
    
    func deleteToken() {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: service
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
