//
//  MovieDetailViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MovieDetailViewModel.swift
import Foundation
import Combine

@MainActor
class MovieDetailViewModel: ObservableObject {
    // MARK: - Published
    @Published var movieImages: [MovieImage] = []
    @Published var movieVideos: [MovieVideo] = []
    @Published var isFavorite: Bool

    // MARK: - Public Properties
    let movie: Movie
    let repository: MovieRepository
    let favoritesService: FavoritesService

    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()

    init(
        movie: Movie,
        repository: MovieRepository,
        favoritesService: FavoritesService
    ) {
        self.movie = movie
        self.repository = repository
        self.favoritesService = favoritesService
        self.isFavorite = favoritesService.contains(movie)
        
        // Подписываемся на изменения избранного
        favoritesService.$favorites
            .map { $0.contains(where: { $0.id == movie.id }) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFavorite, on: self)
            .store(in: &cancellables)
    }

    func loadDetails() {
        repository.fetchMovieImages(movieId: movie.id)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] imgs in
                self?.movieImages = imgs
            })
            .store(in: &cancellables)

        repository.fetchMovieVideos(movieId: movie.id)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] vids in
                self?.movieVideos = vids
            })
            .store(in: &cancellables)
    }

    func toggleFavorite() {
        favoritesService.toggle(movie)
    }
}
