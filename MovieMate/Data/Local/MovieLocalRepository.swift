//
//  MovieLocalRepository.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// MovieLocalRepository.swift
import Foundation
import SwiftData

@MainActor
class MovieLocalRepository {
    let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func saveMovies(_ movies: [Movie]) async {
        do {
            for movie in movies {
                let entity = MovieEntity(
                    id: Int64(movie.id),
                    title: movie.title,
                    overview: movie.overview,
                    posterPath: movie.posterPath,
                    voteAverage: movie.voteAverage,
                    genreIds: movie.genreIds
                )
                container.mainContext.insert(entity)
            }
            try container.mainContext.save()
        } catch {
            print("❌ Не удалось сохранить фильмы: \(error)")
        }
    }

    func loadCachedMovies() async -> [Movie] {
        do {
            let fetchRequest = FetchDescriptor<MovieEntity>()
            let entities = try container.mainContext.fetch(fetchRequest)
            return entities.map {
                Movie(
                    id: Int($0.id),
                    title: $0.title,
                    overview: $0.overview,
                    posterPath: $0.posterPath,
                    voteAverage: $0.voteAverage,
                    genreIds: $0.genreIds
                )
            }
        } catch {
            print("❌ Не удалось загрузить фильмы из кэша: \(error)")
            return []
        }
    }

    func saveGenres(_ genres: [Genre]) async {
        do {
            for genre in genres {
                let entity = GenreEntity(id: Int64(genre.id), name: genre.name)
                container.mainContext.insert(entity)
            }
            try container.mainContext.save()
        } catch {
            print("❌ Не удалось сохранить жанры: \(error)")
        }
    }

    func loadCachedGenres() async -> [Genre] {
        do {
            let fetchRequest = FetchDescriptor<GenreEntity>()
            let entities = try container.mainContext.fetch(fetchRequest)
            return entities.map { Genre(id: Int($0.id), name: $0.name) }
        } catch {
            print("❌ Не удалось загрузить жанры из кэша: \(error)")
            return []
        }
    }
}
