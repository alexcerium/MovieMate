//
//  FavoritesService.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// FavoritesService.swift
import Foundation
import Combine

class FavoritesService: ObservableObject {
    @Published private(set) var favorites: [Movie] = []
    @Published private(set) var isSortedAlphabetically = false
    
    private let keychain: KeychainService
    
    init(keychain: KeychainService) {
        self.keychain = keychain
        load()
    }
    
    func toggle(_ movie: Movie) {
        if let idx = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: idx)
        } else {
            favorites.append(movie)
        }
        save()
        sortIfNeeded()
    }
    
    func contains(_ movie: Movie) -> Bool {
        favorites.contains { $0.id == movie.id }
    }
    
    func toggleSortOrder() {
        isSortedAlphabetically.toggle()
        sortIfNeeded()
    }
    
    private func sortIfNeeded() {
        if isSortedAlphabetically {
            favorites.sort { $0.title < $1.title }
        }
    }
    
    private func load() {
        if let saved: [Movie] = keychain.load("favoriteMovies") {
            favorites = saved
            sortIfNeeded()
        }
    }
    
    private func save() {
        keychain.save("favoriteMovies", value: favorites)
    }
}
