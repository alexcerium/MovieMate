//
//   MoviesGridView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct MoviesGridView: View {
    @ObservedObject var viewModel: MainViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            if viewModel.movies.isEmpty {
                Text("No movies available")
                    .padding()
                    .foregroundColor(.gray)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.movies) { movie in
                        let isFavorite = viewModel.isFavorite(movie: movie)
                        NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                            MovieCardView(movie: movie)
                        }
                        .onAppear {
                            // Проверяем, достигли ли мы последнего элемента в списке
                            if movie.id == viewModel.movies.last?.id {
                                if let genre = viewModel.selectedGenre {
                                    viewModel.fetchMovies(forGenre: genre.id)
                                } else {
                                    viewModel.fetchMovies()
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            if viewModel.isLoading {
                ProgressView("Loading more movies...")
                    .padding()
            }
        }
        .navigationTitle(viewModel.selectedGenre?.name ?? "Movies")
        .onAppear {
            if let genre = viewModel.selectedGenre {
                viewModel.fetchMovies(forGenre: genre.id)
            } else {
                viewModel.fetchMovies()
            }
        }
    }
}
