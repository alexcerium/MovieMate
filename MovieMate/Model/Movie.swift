//
//  Movie.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import Foundation

struct Movie: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let genreIds: [Int]

    var posterURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
}
