//
//  BackgroundViewModel.swift
//  MovieMate
//
//  Created by Aleksandr on 31.08.2024.
//

import Foundation
import Combine
import SwiftData

class BackgroundViewModel {
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let movieServiceMainThread: MovieServiceMainThread
    private let movieServiceBackground: MovieServiceBackground
    var currentPage = 1
    var totalPages = 1

    // MARK: - Initialization
    init(container: ModelContainer) async {
        self.movieServiceMainThread = await MainActor.run {
            MovieServiceMainThread(container: container)
        }
        self.movieServiceBackground = MovieServiceBackground()
    }

    // MARK: - Fetch Movies
    func fetchMoviesInternal(
        genreId: Int? = nil,
        page: Int,
        saveHandler: @escaping ([Movie]) async -> Void,
        appendHandler: @escaping ([Movie]) -> Void
    ) {
        guard page <= totalPages else { return }

        let fetchPublisher: AnyPublisher<MoviesResponse, Error>
        if let genreId = genreId {
            fetchPublisher = movieServiceBackground.fetchMovies(forGenre: genreId, page: page)
        } else {
            fetchPublisher = movieServiceBackground.fetchPopularMovies(page: page)
        }

        fetchPublisher
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Не удалось загрузить фильмы: \(error)")
                }
            }, receiveValue: { response in
                Task {
                    await saveHandler(response.results)
                }
                appendHandler(response.results)
                self.totalPages = response.totalPages
                self.currentPage += 1
            })
            .store(in: &cancellables)
    }

    // MARK: - Fetch Recommended Movies
    func fetchRecommendedMovies(favoriteMovies: [Movie], watchedMovies: Set<Int>, completion: @escaping ([Movie]) -> Void) {
        let favoriteGenreIds = (favoriteMovies + favoriteMovies.filter { watchedMovies.contains($0.id) })
            .flatMap { $0.genreIds }
            .unique()

        let fetchTasks = favoriteGenreIds.map { genreId in
            movieServiceBackground.fetchMovies(forGenre: genreId, page: 1)
                .map { $0.results }
                .replaceError(with: [])
        }

        Publishers.MergeMany(fetchTasks)
            .collect()
            .map { movieLists in
                movieLists.flatMap { $0 }
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Не удалось загрузить рекомендованные фильмы: \(error)")
                }
            }, receiveValue: { movies in
                let newMovies = movies.filter { movie in
                    !favoriteMovies.contains(where: { $0.id == movie.id }) &&
                    !watchedMovies.contains(movie.id)
                }
                completion(Array(Set(newMovies)).sorted(by: { $0.voteAverage > $1.voteAverage }))
            })
            .store(in: &cancellables)
    }

    // MARK: - Fetch Genres
    func fetchGenres(completion: @escaping ([Genre]) -> Void) {
        movieServiceBackground.fetchGenres()
            .sink(receiveCompletion: { _ in }, receiveValue: { genres in
                Task {
                    await self.movieServiceMainThread.saveGenres(genres)
                }
                completion(genres)
            })
            .store(in: &cancellables)
    }

    // MARK: - Search Movies
    func searchMovies(query: String, completion: @escaping ([Movie], Int) -> Void) {
        movieServiceBackground.searchMovies(query: query, page: currentPage)
            .sink(receiveCompletion: { completionStatus in
                if case let .failure(error) = completionStatus {
                    print("Не удалось выполнить поиск фильмов: \(error)")
                }
            }, receiveValue: { response in
                completion(response.results, response.totalPages)
            })
            .store(in: &cancellables)
    }

    // MARK: - Movie Images and Videos
    func fetchMovieImages(movieId: Int, completion: @escaping ([MovieImage]) -> Void) {
        movieServiceBackground.fetchMovieImages(movieId: movieId)
            .sink(receiveCompletion: { completionStatus in
                if case let .failure(error) = completionStatus {
                    print("Не удалось загрузить изображения фильма: \(error)")
                }
            }, receiveValue: { images in
                completion(images)
            })
            .store(in: &cancellables)
    }

    func fetchMovieVideos(movieId: Int, completion: @escaping ([MovieVideo]) -> Void) {
        movieServiceBackground.fetchMovieVideos(movieId: movieId)
            .sink(receiveCompletion: { completionStatus in
                if case let .failure(error) = completionStatus {
                    print("Не удалось загрузить видео фильма: \(error)")
                }
            }, receiveValue: { videos in
                completion(videos)
            })
            .store(in: &cancellables)
    }

    // MARK: - Reset and Clear Data
    func resetPagination() {
        currentPage = 1
        totalPages = 1
    }

    func clearOldMovies() async {
        await MainActor.run {
            do {
                let fetchRequest = FetchDescriptor<MovieEntity>()
                let movieEntities = try movieServiceMainThread.container.mainContext.fetch(fetchRequest)
                for entity in movieEntities {
                    movieServiceMainThread.container.mainContext.delete(entity)
                }
                try movieServiceMainThread.container.mainContext.save()
            } catch {
                print("Не удалось очистить старые фильмы: \(error)")
            }
        }
    }
}
// Extension to handle unique filtering of arrays
extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}
