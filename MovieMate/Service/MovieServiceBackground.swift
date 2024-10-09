//
//  MovieService.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import Foundation
import Combine

// Класс с фоновыми операциями
class MovieServiceBackground {
    private let baseURL = "https://api.themoviedb.org/3"
    private var apiKey: String? {
        return KeychainHelper.shared.getApiKey()
    }

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

    private func makeRequest<T: Codable>(endpoint: String, parameters: [String: String] = [:]) -> AnyPublisher<T, Error> {
        guard let apiKey = apiKey else {
            return Fail(error: NSError(domain: "API_KEY_NOT_FOUND", code: -1, userInfo: [NSLocalizedDescriptionKey: "API-ключ не найден в Keychain"]))
                .eraseToAnyPublisher()
        }

        var components = URLComponents(string: baseURL + endpoint)!
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)] + parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            return Fail(error: NSError(domain: "INVALID_URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Невозможно создать URL"]))
                .eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
