//
//  HomeViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// HomeViewModel.swift
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false

    private let repository: MovieRepository
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var totalPages = 1

    init(repository: MovieRepository) {
        self.repository = repository
    }

    func loadHomeData() {
        isLoading = true
        repository.fetchGenres()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] genres in
                    guard let s = self else { return }
                    s.genres = genres
                    s.fetchPopular()
                  })
            .store(in: &cancellables)
    }

    func refresh() {
        currentPage = 1
        totalPages = 1
        movies = []
        loadHomeData()
    }

    private func fetchPopular() {
        guard currentPage <= totalPages else { return }
        repository.fetchPopular(page: currentPage)
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
