//
//  SearchViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// SearchViewModel.swift
import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Movie] = []
    @Published var isLoading = false
    @Published var isSearching = false

    private let repository: MovieRepository
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1

    init(repository: MovieRepository) {
        self.repository = repository
    }

    func searchMovies() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        isLoading = true
        isSearching = true
        repository.searchMovies(query: searchQuery, page: currentPage)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] resp in
                    guard let s = self else { return }
                    s.searchResults = resp.results
                    s.isLoading = false
                  })
            .store(in: &cancellables)
    }
}
