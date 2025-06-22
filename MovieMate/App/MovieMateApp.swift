//
//  MovieMateApp.swift
//  MovieMate
//
//  Created by Aleksandr on 13.09.2024.
//

// MovieMateApp.swift
import SwiftUI
import SwiftData

@main
struct MovieMateApp: App {
    @StateObject private var coordinator = AppCoordinator()
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([ MovieEntity.self, GenreEntity.self ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            RootView(container: sharedModelContainer)
                .environmentObject(coordinator)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
