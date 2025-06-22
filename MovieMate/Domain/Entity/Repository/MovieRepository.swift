//
//  MovieRepository.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MovieRepository.swift
import Foundation
import Combine

protocol MovieRepository {
    func fetchPopular(page: Int) -> AnyPublisher<MoviesResponse, Error>
    func fetchMovies(genreId: Int, page: Int) -> AnyPublisher<MoviesResponse, Error>
    func fetchGenres() -> AnyPublisher<[Genre], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviesResponse, Error>
    func fetchMovieImages(movieId: Int) -> AnyPublisher<[MovieImage], Error>
    func fetchMovieVideos(movieId: Int) -> AnyPublisher<[MovieVideo], Error>
}

class MovieRepositoryImpl: MovieRepository {
    private let remote: MovieRemoteRepository
    private let local: MovieLocalRepository

    init(remote: MovieRemoteRepository, local: MovieLocalRepository) {
        self.remote = remote
        self.local = local
    }

    func fetchPopular(page: Int) -> AnyPublisher<MoviesResponse, Error> {
        remote.fetchPopularMovies(page: page)
    }

    func fetchMovies(genreId: Int, page: Int) -> AnyPublisher<MoviesResponse, Error> {
        remote.fetchMovies(forGenre: genreId, page: page)
    }

    func fetchGenres() -> AnyPublisher<[Genre], Error> {
        remote.fetchGenres()
    }

    func searchMovies(query: String, page: Int) -> AnyPublisher<MoviesResponse, Error> {
        remote.searchMovies(query: query, page: page)
    }

    func fetchMovieImages(movieId: Int) -> AnyPublisher<[MovieImage], Error> {
        remote.fetchMovieImages(movieId: movieId)
    }

    func fetchMovieVideos(movieId: Int) -> AnyPublisher<[MovieVideo], Error> {
        remote.fetchMovieVideos(movieId: movieId)
    }
}
