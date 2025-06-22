//
//   MoviesGridView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

// MoviesGridView.swift
import SwiftUI

struct MoviesGridView: View {
    let repository: MovieRepository
    let favoritesService: FavoritesService

    @ObservedObject var viewModel: MoviesGridViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
        ScrollView {
            if viewModel.movies.isEmpty {
                Text("No movies available").foregroundColor(.gray).padding()
            } else {
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
                                if let g = viewModel.selectedGenre {
                                    viewModel.loadMovies(genre: g)
                                } else {
                                    viewModel.loadMovies()
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            if viewModel.isLoading {
                ProgressView("Loading more…").padding()
            }
        }
        .navigationTitle(viewModel.selectedGenre?.name ?? "Movies")
        .onAppear {
            if let g = viewModel.selectedGenre {
                viewModel.loadMovies(genre: g)
            } else {
                viewModel.loadMovies()
            }
        }
    }
}
