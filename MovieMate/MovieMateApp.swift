//
//  MovieMateApp.swift
//  MovieMate
//
//  Created by Aleksandr on 13.09.2024.
//

import SwiftUI
import SwiftData

@main
struct MovieMateApp: App {
    // Shared model container setup
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MovieEntity.self,
            GenreEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
    }()
    
    // Инициализация приложения и обработка хранения API-ключа
    init() {
        // Проверяем, сохранен ли API-ключ в Keychain
        if KeychainHelper.shared.getApiKey() == nil {
            // Загружаем API-ключ из Config.plist
            if let apiKey = loadApiKeyFromConfig() {
                let isSaved = KeychainHelper.shared.saveApiKey(apiKey)
                if !isSaved {
                    print("Ошибка при сохранении API-ключа в Keychain")
                }
            } else {
                print("API-ключ не найден. Убедитесь, что он установлен в файле Config.plist.")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Принудительное использование темной темы
        }
        .modelContainer(sharedModelContainer)
    }
    
    // Функция для загрузки API-ключа из Config.plist
    private func loadApiKeyFromConfig() -> String? {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let apiKey = config["API_KEY"] as? String {
            return apiKey
        }
        return nil
    }
}
