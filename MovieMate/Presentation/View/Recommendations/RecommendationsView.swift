//
//  GenresView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct RecommendationsView: View {
    @ObservedObject var viewModel: RecommendationsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    private let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView().padding()
            } else if viewModel.recommendedMovies.isEmpty {
                Text("Recommendations will appear here in a while!")
                    .padding()
                    .foregroundColor(.gray)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.recommendedMovies) { movie in
                        NavigationLink(
                            destination: MovieDetailView(
                                viewModel: MovieDetailViewModel(
                                    movie: movie,
                                    repository: viewModel.repository,
                                    favoritesService: viewModel.favoritesService
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
        .navigationTitle("Recommendations")
        .onAppear { viewModel.fetchRecommended() }
    }
}
