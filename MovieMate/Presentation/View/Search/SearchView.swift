//
//  SearchView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct SearchView: View {
    let repository: MovieRepository
    let favoritesService: FavoritesService

    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Закреплённая поисковая строка
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField(
                        "Search movies…",
                        text: $viewModel.searchQuery,
                        onCommit: { viewModel.searchMovies() }
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)

                // Контент
                if viewModel.isSearching && viewModel.searchResults.isEmpty {
                    Spacer()
                    Text("No results")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 20
                        ) {
                            ForEach(viewModel.searchResults) { movie in
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
                }
            }
            .navigationTitle("Search Movies")
        }
    }
}
