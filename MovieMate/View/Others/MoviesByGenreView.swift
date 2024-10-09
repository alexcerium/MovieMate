//
//  MoviesByGenreView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct MoviesByGenreView: View {
    @ObservedObject var viewModel: MainViewModel
    let genre: Genre
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.filteredMovies(for: genre)) { movie in
                    let isFavorite = viewModel.isFavorite(movie: movie)
                    NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                        MovieCardView(movie: movie)
                    }
                    .onAppear {
                        if movie.id == viewModel.movies.last?.id {
                            viewModel.fetchMovies(forGenre: genre.id)
                        }
                    }
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading more movies...")
                    .padding()
            }
        }
        .navigationTitle(genre.name)
        .onAppear {
            if viewModel.selectedGenre?.id != genre.id {
                viewModel.resetPagination()
                viewModel.selectedGenre = genre
                viewModel.fetchMovies(forGenre: genre.id)
            }
        }
    }
}
