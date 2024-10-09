//
//  KeychainHelper.swift
//  MovieMate
//
//  Created by Aleksandr on 09.10.2024.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private let service = Bundle.main.bundleIdentifier ?? "com.yourapp.bundle"

    func save(_ data: Data, forKey key: String) -> Bool {
        // Удаляем существующие данные с таким же ключом
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(queryDelete as CFDictionary)
        
        // Добавляем новые данные
        let queryAdd: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Ошибка при сохранении данных в Keychain: \(status)")
            return false
        }
        return true
    }
    
    func load(forKey key: String) -> Data? {
        let queryLoad: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(queryLoad as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            print("Не удалось загрузить данные из Keychain для ключа \(key), статус: \(status)")
            return nil
        }
    }
    
    func delete(forKey key: String) -> Bool {
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(queryDelete as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Ошибка при удалении данных из Keychain: \(status)")
            return false
        }
        return true
    }
    
    // Специальные методы для работы с API-ключом
    func saveApiKey(_ apiKey: String) -> Bool {
        guard let data = apiKey.data(using: .utf8) else { return false }
        return save(data, forKey: "API_KEY")
    }
    
    func getApiKey() -> String? {
        if let data = load(forKey: "API_KEY"),
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        return nil
    }
}
