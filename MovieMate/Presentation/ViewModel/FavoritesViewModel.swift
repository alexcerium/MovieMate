//
//  FavoritesViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published private(set) var favoriteMovies: [Movie] = []
    @Published var isSortedAlphabetically = false

    // стало публичным
    let service: FavoritesService

    private var cancellables = Set<AnyCancellable>()

    init(service: FavoritesService) {
        self.service = service
        service.$favorites
            .receive(on: DispatchQueue.main)
            .assign(to: \.favoriteMovies, on: self)
            .store(in: &cancellables)
        service.$isSortedAlphabetically
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSortedAlphabetically, on: self)
            .store(in: &cancellables)
    }

    func toggleFavorite(_ movie: Movie) {
        service.toggle(movie)
    }

    func toggleSortOrder() {
        service.toggleSortOrder()
    }
}
