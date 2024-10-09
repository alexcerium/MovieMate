//
//  GenreEntity.swift
//  MovieMate
//
//  Created by Aleksandr on 28.08.2024.
//

import SwiftData

@Model
class GenreEntity {
    var id: Int64
    var name: String

    init(id: Int64, name: String) {
        self.id = id
        self.name = name
    }
}
