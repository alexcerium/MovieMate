//
//  MovieRemoteRepository.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MovieRemoteRepository.swift
import Foundation
import Combine

class MovieRemoteRepository {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "1abeabfd080f319137ea77dc1f21bd48"

    func fetchPopularMovies(page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        makeRequest(endpoint: "/movie/popular", parameters: ["page": "\(page)"])
    }

    func fetchMovies(forGenre genreId: Int, page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        makeRequest(endpoint: "/discover/movie", parameters: ["with_genres": "\(genreId)", "page": "\(page)"])
    }

    func searchMovies(query: String, page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        makeRequest(endpoint: "/search/movie", parameters: ["query": query, "page": "\(page)"])
    }

    func fetchGenres() -> AnyPublisher<[Genre], Error> {
        makeRequest(endpoint: "/genre/movie/list")
            .map { (response: GenresResponse) in response.genres }
            .eraseToAnyPublisher()
    }

    func fetchMovieImages(movieId: Int) -> AnyPublisher<[MovieImage], Error> {
        makeRequest(endpoint: "/movie/\(movieId)/images")
            .map { (response: MovieImagesResponse) in response.backdrops }
            .eraseToAnyPublisher()
    }

    func fetchMovieVideos(movieId: Int) -> AnyPublisher<[MovieVideo], Error> {
        makeRequest(endpoint: "/movie/\(movieId)/videos")
            .map { (response: MovieVideosResponse) in response.results }
            .eraseToAnyPublisher()
    }

    private func makeRequest<T: Codable>(
        endpoint: String,
        parameters: [String: String] = [:]
    ) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
            + parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

