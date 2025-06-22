//
//  RecommendationsViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

import Foundation
import Combine

@MainActor
class RecommendationsViewModel: ObservableObject {
    // MARK: - Published
    @Published var recommendedMovies: [Movie] = []
    @Published var isLoading = false

    // Сделано публичным (internal) для доступа из View
    let repository: MovieRepository
    let favoritesService: FavoritesService
    let watchedService: WatchedService

    private var cancellables = Set<AnyCancellable>()

    init(
        repository: MovieRepository,
        favoritesService: FavoritesService,
        watchedService: WatchedService
    ) {
        self.repository = repository
        self.favoritesService = favoritesService
        self.watchedService = watchedService
    }

    func fetchRecommended() {
        isLoading = true
        let favIds = Set(favoritesService.favorites.map { $0.id })
        let watchedIds = watchedService.watchedIds
        let genreIds = favoritesService.favorites
            .filter { favIds.contains($0.id) || watchedIds.contains($0.id) }
            .flatMap { $0.genreIds }
            .unique()

        let tasks = genreIds.map { genreId in
            repository
                .fetchMovies(genreId: genreId, page: 1)
                .map { $0.results }
                .replaceError(with: [])
        }

        Publishers.MergeMany(tasks)
            .collect()
            .map { $0.flatMap { $0 } }
            .map { movies in
                movies.filter {
                    !favIds.contains($0.id) && !watchedIds.contains($0.id)
                }
            }
            .map { Array(Set($0)).sorted { $0.voteAverage > $1.voteAverage } }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] recs in
                    self?.recommendedMovies = recs
                    self?.isLoading = false
                  })
            .store(in: &cancellables)
    }
}
