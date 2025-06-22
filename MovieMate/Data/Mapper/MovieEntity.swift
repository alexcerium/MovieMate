//
//  MovieEntity.swift
//  MovieMate
//
//  Created by Aleksandr on 28.08.2024.
//

import Foundation
import SwiftData

@Model
class MovieEntity {
    var id: Int64
    var title: String
    var overview: String
    var posterPath: String?
    var voteAverage: Double
    var genreIdsData: Data  // сериализованный массив

    // Преобразование в удобный формат
    var genreIds: [Int] {
        get {
            (try? JSONDecoder().decode([Int].self, from: genreIdsData)) ?? []
        }
        set {
            genreIdsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(id: Int64, title: String, overview: String, posterPath: String?, voteAverage: Double, genreIds: [Int]) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.genreIdsData = Data()
        self.genreIds = genreIds
    }
}
