//
//  GenresView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct RecommendationsView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ScrollView {
            if viewModel.recommendedMovies.isEmpty {
                Text("Recommendations will appear here in a while!")
                    .padding()
                    .foregroundColor(.gray)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.recommendedMovies) { movie in
                        let isFavorite = viewModel.isFavorite(movie: movie)
                        NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                            MovieCardView(movie: movie)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recommendations")
        .onAppear {
            viewModel.fetchRecommendedMovies()
        }
    }
}
