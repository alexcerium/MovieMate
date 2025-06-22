//
//  AppCoordinator.swift.swift
//  MovieMate
//
//  Created by Aleksandr on 09.06.2025.
//

// AppCoordinator.swift
import SwiftUI

final class AppCoordinator: ObservableObject {
    enum Tab { case home, recommendations, favorites, search }
    @Published var selectedTab: Tab = .home
    @Published var homePath = NavigationPath()
    @Published var recsPath = NavigationPath()
    @Published var favPath = NavigationPath()
    @Published var searchPath = NavigationPath()

    func showDetail(_ movie: Movie) {
        switch selectedTab {
        case .home:           homePath.append(movie)
        case .recommendations: recsPath.append(movie)
        case .favorites:      favPath.append(movie)
        case .search:         searchPath.append(movie)
        }
    }
}
