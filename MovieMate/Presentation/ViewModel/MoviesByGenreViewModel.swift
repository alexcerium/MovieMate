//
//  MoviesByGenreViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MoviesByGenreViewModel.swift
import Foundation
import Combine

@MainActor
class MoviesByGenreViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var selectedGenre: Genre? = nil

    private let repository: MovieRepository
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var totalPages = 1

    init(repository: MovieRepository) {
        self.repository = repository
    }

    func loadMovies(genre: Genre) {
        guard currentPage <= totalPages else { return }
        selectedGenre = genre
        isLoading = true
        repository.fetchMovies(genreId: genre.id, page: currentPage)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] resp in
                    guard let s = self else { return }
                    s.movies.append(contentsOf: resp.results)
                    s.totalPages = resp.totalPages
                    s.currentPage += 1
                    s.isLoading = false
                  })
            .store(in: &cancellables)
    }

    func resetPagination() {
        currentPage = 1
        totalPages = 1
        movies = []
    }
}
