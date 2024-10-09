//
//  FavoritesView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: MainViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView { // Добавили NavigationView
            VStack {
                // Убрали HStack с текстом заголовка, так как будем использовать navigationTitle
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.favoriteMovies) { movie in
                            let isFavorite = viewModel.isFavorite(movie: movie)
                            NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                                MovieCardView(movie: movie)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorite Movies") // Установили заголовок навигации
            .onAppear {
                viewModel.toggleSortOrder()
            }
        }
    }
}
