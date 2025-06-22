//
//  KeychainService.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// KeychainService.swift
import Foundation
import Security

protocol KeychainService {
    func load<T: Decodable>(_ key: String) -> T?
    func save<T: Encodable>(_ key: String, value: T)
}

class KeychainServiceImpl: KeychainService {
    func load<T>(_ key: String) -> T? where T : Decodable {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
    
    func save<T>(_ key: String, value: T) where T : Encodable {
        guard let data = try? JSONEncoder().encode(value) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let attrs: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
}
