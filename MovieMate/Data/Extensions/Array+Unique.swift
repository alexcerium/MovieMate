//
//  Array+Unique.swift
//  MovieMate
//
//  Created by Aleksandr on 12.06.2025.
//

// Array+Unique.swift
import Foundation

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
