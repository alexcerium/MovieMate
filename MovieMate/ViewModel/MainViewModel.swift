//
//  MainViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import Foundation
import Combine
import SwiftData
import Security // Импортируем Security для работы с Keychain

@MainActor
class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var favoriteMovies: [Movie] = []
    @Published var recommendedMovies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var selectedGenre: Genre? = nil
    @Published var isLoading: Bool = false
    @Published var isSortedAlphabetically: Bool = false
    @Published var isSearching: Bool = false

    // MARK: - Private Properties
    private var watchedMovies: Set<Int> = []
    private var cancellables = Set<AnyCancellable>()
    private var backgroundViewModel: BackgroundViewModel?
    private var movieServiceMainThread: MovieServiceMainThread?

    // MARK: - Initialization
    func initialize(container: ModelContainer) async {
        self.movieServiceMainThread = MovieServiceMainThread(container: container)
        self.backgroundViewModel = await BackgroundViewModel(container: container)
        loadHomeData()
        loadFavorites()
        loadWatchedMovies()
        fetchRecommendedMovies()
    }

    // MARK: - Load Initial Data
    func loadHomeData() {
        fetchGenres()
        fetchMovies()
    }

    // MARK: - Fetch Movies
    func fetchMovies() {
        guard let backgroundViewModel = backgroundViewModel else { return }
        isLoading = true
        backgroundViewModel.fetchMoviesInternal(
            page: backgroundViewModel.currentPage,
            saveHandler: { await self.movieServiceMainThread?.saveMovies($0) },
            appendHandler: { self.movies.append(contentsOf: $0) }
        )
    }

    func fetchMovies(forGenre genreId: Int) {
        guard let backgroundViewModel = backgroundViewModel else { return }
        isLoading = true
        backgroundViewModel.fetchMoviesInternal(
            genreId: genreId,
            page: backgroundViewModel.currentPage,
            saveHandler: { await self.movieServiceMainThread?.saveMovies($0) },
            appendHandler: { self.movies.append(contentsOf: $0) }
        )
    }

    func fetchRecommendedMovies() {
        guard let backgroundViewModel = backgroundViewModel else { return }
        guard !isLoading else { return }
        isLoading = true
        backgroundViewModel.fetchRecommendedMovies(
            favoriteMovies: favoriteMovies,
            watchedMovies: watchedMovies,
            completion: { recommendedMovies in
                self.recommendedMovies = recommendedMovies
                self.isLoading = false
            })
    }

    // MARK: - Genre Management
    func fetchGenres() {
        backgroundViewModel?.fetchGenres { genres in
            self.genres = genres
        }
    }

    // MARK: - Search Movies
    func searchMovies(query: String) {
        guard let backgroundViewModel = backgroundViewModel else { return }
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isLoading = true
        isSearching = true
        backgroundViewModel.searchMovies(query: query) { results, totalPages in
            self.searchResults = results
            backgroundViewModel.totalPages = totalPages
            self.isLoading = false
        }
    }

    // MARK: - Favorite Movies Management
    func toggleFavorite(movie: Movie) {
        if let index = favoriteMovies.firstIndex(where: { $0.id == movie.id }) {
            favoriteMovies.remove(at: index)
        } else {
            favoriteMovies.append(movie)
        }
        updateFavorites()
    }

    func isFavorite(movie: Movie) -> Bool {
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }

    func loadFavorites() {
        if let savedMovies: [Movie] = loadFromKeychain(key: "favoriteMovies") {
            self.favoriteMovies = savedMovies
            sortFavorites()
        }
    }

    func saveFavorites() {
        saveToKeychain(key: "favoriteMovies", value: favoriteMovies)
    }

    func toggleSortOrder() {
        isSortedAlphabetically.toggle()
        sortFavorites()
    }

    private func sortFavorites() {
        if isSortedAlphabetically {
            favoriteMovies.sort { $0.title < $1.title }
        }
    }

    private func updateFavorites() {
        sortFavorites()
        saveFavorites()
    }

    // MARK: - Keychain Management
    private func loadFromKeychain<T: Decodable>(key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        } else {
            print("Не удалось загрузить данные из Keychain для ключа \(key), статус: \(status)")
            return nil
        }
    }

    private func saveToKeychain<T: Encodable>(key: String, value: T) {
        if let encodedData = try? JSONEncoder().encode(value) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]

            let attributes: [String: Any] = [
                kSecValueData as String: encodedData
            ]

            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

            if status == errSecItemNotFound {
                var newItem = query
                newItem[kSecValueData as String] = encodedData

                let addStatus = SecItemAdd(newItem as CFDictionary, nil)
                if addStatus != errSecSuccess {
                    print("Не удалось сохранить данные в Keychain для ключа \(key), статус: \(addStatus)")
                }
            } else if status != errSecSuccess {
                print("Не удалось обновить данные в Keychain для ключа \(key), статус: \(status)")
            }
        }
    }

    // MARK: - Watched Movies Management
    func markMovieAsWatched(_ movie: Movie) {
        watchedMovies.insert(movie.id)
        saveWatchedMovies()
    }

    func loadWatchedMovies() {
        if let savedMovies: Set<Int> = loadFromKeychain(key: "watchedMovies") {
            self.watchedMovies = savedMovies
        }
    }

    func saveWatchedMovies() {
        saveToKeychain(key: "watchedMovies", value: watchedMovies)
    }

    // MARK: - Movie Images and Videos
    func fetchMovieImages(movieId: Int, completion: @escaping ([MovieImage]) -> Void) {
        backgroundViewModel?.fetchMovieImages(movieId: movieId, completion: completion)
    }

    func fetchMovieVideos(movieId: Int, completion: @escaping ([MovieVideo]) -> Void) {
        backgroundViewModel?.fetchMovieVideos(movieId: movieId, completion: completion)
    }

    // MARK: - Reset and Clear Data
    func resetPagination() {
        backgroundViewModel?.resetPagination()
        movies = []
    }

    func clearOldMovies() {
        Task {
            await backgroundViewModel?.clearOldMovies()
        }
    }

    // MARK: - Filter Movies by Genre
    func filteredMovies(for genre: Genre) -> [Movie] {
        return movies.filter { $0.genreIds.contains(genre.id) }
    }
}
