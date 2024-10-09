//
//  MovieImage.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import Foundation

struct MovieImage: Identifiable, Codable {
    let filePath: String

    var id: String { filePath }

    var imageURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(filePath)")
    }

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }
}
