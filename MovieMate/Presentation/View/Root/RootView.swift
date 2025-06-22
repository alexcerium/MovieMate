//
//  RootView.swift.swift
//  MovieMate
//
//  Created by Aleksandr on 09.06.2025.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    let container: ModelContainer

    private let repository: MovieRepository
    private let favoritesService: FavoritesService
    private let watchedService: WatchedService

    @StateObject private var homeVM: HomeViewModel
    @StateObject private var recsVM: RecommendationsViewModel
    @StateObject private var favVM: FavoritesViewModel
    @StateObject private var searchVM: SearchViewModel

    init(container: ModelContainer) {
        self.container = container

        let remoteRepo = MovieRemoteRepository()
        let localRepo  = MovieLocalRepository(container: container)
        let repo       = MovieRepositoryImpl(remote: remoteRepo, local: localRepo)

        let kc   = KeychainServiceImpl()
        let favS = FavoritesService(keychain: kc)
        let watchS = WatchedService(keychain: kc)

        repository       = repo
        favoritesService = favS
        watchedService   = watchS

        _homeVM   = StateObject(wrappedValue: HomeViewModel(repository: repo))
        _recsVM   = StateObject(wrappedValue: RecommendationsViewModel(
                              repository: repo,
                              favoritesService: favS,
                              watchedService: watchS))
        _favVM    = StateObject(wrappedValue: FavoritesViewModel(service: favS))
        _searchVM = StateObject(wrappedValue: SearchViewModel(repository: repo))
    }

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                HomeView(
                    repository: repository,
                    favoritesService: favoritesService,
                    viewModel: homeVM
                )
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(
                        viewModel: MovieDetailViewModel(
                            movie: movie,
                            repository: repository,
                            favoritesService: favoritesService
                        )
                    )
                }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(AppCoordinator.Tab.home)

            NavigationStack(path: $coordinator.recsPath) {
                RecommendationsView(viewModel: recsVM)
                    .navigationDestination(for: Movie.self) { movie in
                        MovieDetailView(
                            viewModel: MovieDetailViewModel(
                                movie: movie,
                                repository: repository,
                                favoritesService: favoritesService
                            )
                        )
                    }
            }
            .tabItem { Label("Recs", systemImage: "star.fill") }
            .tag(AppCoordinator.Tab.recommendations)

            NavigationStack(path: $coordinator.favPath) {
                FavoritesView(
                    repository: repository,
                    favoritesService: favoritesService,
                    viewModel: favVM
                )
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(
                        viewModel: MovieDetailViewModel(
                            movie: movie,
                            repository: repository,
                            favoritesService: favoritesService
                        )
                    )
                }
            }
            .tabItem { Label("Favorites", systemImage: "star") }
            .tag(AppCoordinator.Tab.favorites)

            NavigationStack(path: $coordinator.searchPath) {
                SearchView(
                    repository: repository,
                    favoritesService: favoritesService,
                    viewModel: searchVM
                )
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(
                        viewModel: MovieDetailViewModel(
                            movie: movie,
                            repository: repository,
                            favoritesService: favoritesService
                        )
                    )
                }
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(AppCoordinator.Tab.search)
        }
        .modelContainer(container)
    }
}
