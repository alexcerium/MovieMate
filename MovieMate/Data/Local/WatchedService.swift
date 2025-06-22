//
//  WatchedService.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// WatchedService.swift
import Foundation
import Combine

class WatchedService: ObservableObject {
    @Published private(set) var watchedIds: Set<Int> = []
    
    private let keychain: KeychainService
    
    init(keychain: KeychainService) {
        self.keychain = keychain
        load()
    }
    
    func mark(_ movieId: Int) {
        watchedIds.insert(movieId)
        save()
    }
    
    func contains(_ movieId: Int) -> Bool {
        watchedIds.contains(movieId)
    }
    
    private func load() {
        if let saved: Set<Int> = keychain.load("watchedMovies") {
            watchedIds = saved
        }
    }
    
    private func save() {
        keychain.save("watchedMovies", value: watchedIds)
    }
}
