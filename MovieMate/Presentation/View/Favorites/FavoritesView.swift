//
//  FavoritesView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct FavoritesView: View {
    let repository: MovieRepository
    let favoritesService: FavoritesService

    @ObservedObject var viewModel: FavoritesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.favoriteMovies) { movie in
                        NavigationLink(
                            destination: MovieDetailView(
                                viewModel: MovieDetailViewModel(
                                    movie: movie,
                                    repository: repository,
                                    favoritesService: favoritesService
                                )
                            )
                        ) {
                            MovieCardView(movie: movie)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Favorite Movies")
            .onAppear { viewModel.toggleSortOrder() }
        }
    }
}
