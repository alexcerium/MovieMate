//
//  MoviesGridViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MoviesGridViewModel.swift
import Foundation
import Combine

@MainActor
class MoviesGridViewModel: ObservableObject {
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

    func loadMovies() {
        load(page: currentPage, genreId: nil)
    }

    func loadMovies(genre: Genre) {
        selectedGenre = genre
        resetPagination()
        load(page: currentPage, genreId: genre.id)
    }

    func resetPagination() {
        currentPage = 1
        totalPages = 1
        movies = []
    }

    private func load(page: Int, genreId: Int?) {
        guard page <= totalPages else { return }
        isLoading = true
        let publisher = genreId.map {
            repository.fetchMovies(genreId: $0, page: page)
        } ?? repository.fetchPopular(page: page)

        publisher
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
}
