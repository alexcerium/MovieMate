//
//  APIModels.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//


// APIModels.swift
import Foundation

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
        case results, page
        case totalPages = "total_pages"
    }
}
