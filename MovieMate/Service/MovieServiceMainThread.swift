//
//  MovieServiceMainThread.swift
//  MovieMate
//
//  Created by Aleksandr on 31.08.2024.
//

import Foundation
import SwiftData

// Структуры для ответов от API
struct GenresResponse: Codable {
    let genres: [Genre]
}

struct MovieImagesResponse: Codable {
    let backdrops: [MovieImage]
}

struct MovieVideosResponse: Codable {
    let results: [MovieVideo]
}

struct MoviesResponse: Codable {
    let results: [Movie]
    let page: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
    }
}

// Класс с методами, которые должны выполняться в главном потоке
@MainActor
class MovieServiceMainThread {
    internal var container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func saveMovies(_ movies: [Movie]) async {
        do {
            for movie in movies {
                let movieEntity = MovieEntity(
                    id: Int64(movie.id),
                    title: movie.title,
                    overview: movie.overview,
                    posterPath: movie.posterPath,
                    voteAverage: movie.voteAverage,
                    genreIds: movie.genreIds.map { Int64($0) }
                )
                container.mainContext.insert(movieEntity)
            }
            try container.mainContext.save()
        } catch {
            print("Не удалось сохранить фильмы: \(error)")
        }
    }

    func loadCachedMovies() async -> [Movie] {
        do {
            let fetchRequest = FetchDescriptor<MovieEntity>()
            let movieEntities = try container.mainContext.fetch(fetchRequest)
            return movieEntities.map { entity in
                Movie(
                    id: Int(entity.id),
                    title: entity.title,
                    overview: entity.overview,
                    posterPath: entity.posterPath,
                    voteAverage: entity.voteAverage,
                    genreIds: entity.genreIds.map { Int($0) }
                )
            }
        } catch {
            print("Не удалось загрузить фильмы из кэша: \(error)")
            return []
        }
    }

    func saveGenres(_ genres: [Genre]) async {
        do {
            for genre in genres {
                let genreEntity = GenreEntity(id: Int64(genre.id), name: genre.name)
                container.mainContext.insert(genreEntity)
            }
            try container.mainContext.save()
        } catch {
            print("Не удалось сохранить жанры: \(error)")
        }
    }

    func loadCachedGenres() async -> [Genre] {
        do {
            let fetchRequest = FetchDescriptor<GenreEntity>()
            let genreEntities = try container.mainContext.fetch(fetchRequest)
            return genreEntities.map { Genre(id: Int($0.id), name: $0.name) }
        } catch {
            print("Не удалось загрузить жанры из кэша: \(error)")
            return []
        }
    }
}
