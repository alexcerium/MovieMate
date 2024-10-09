//
//  MovieEntity.swift
//  MovieMate
//
//  Created by Aleksandr on 28.08.2024.
//

import SwiftData

@Model
class MovieEntity {
    var id: Int64
    var title: String
    var overview: String
    var posterPath: String?
    var voteAverage: Double
    var genreIds: [Int64]

    init(id: Int64, title: String, overview: String, posterPath: String?, voteAverage: Double, genreIds: [Int64]) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.genreIds = genreIds
    }
}
