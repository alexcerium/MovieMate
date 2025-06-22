//
//  MoviesByGenreView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

// MoviesByGenreView.swift
import SwiftUI

struct MoviesByGenreView: View {
    let repository: MovieRepository
    let favoritesService: FavoritesService

    @ObservedObject var viewModel: MoviesByGenreViewModel
    let genre: Genre
    @EnvironmentObject private var coordinator: AppCoordinator

    private let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.movies) { movie in
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
                    .onAppear {
                        if movie.id == viewModel.movies.last?.id {
                            viewModel.loadMovies(genre: genre)
                        }
                    }
                }
            }
            .padding()

            if viewModel.isLoading {
                ProgressView("Loading…")
                    .padding()
            }
        }
        .navigationTitle(genre.name)
        .onAppear {
            viewModel.resetPagination()
            viewModel.loadMovies(genre: genre)
        }
    }
}
