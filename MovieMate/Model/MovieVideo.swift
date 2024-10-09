//
//  MovieVideo.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import Foundation

struct MovieVideo: Identifiable, Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}
