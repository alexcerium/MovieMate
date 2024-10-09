//
//  SearchView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var searchQuery: String = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search movies...", text: $searchQuery, onCommit: {
                        viewModel.searchMovies(query: searchQuery)
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                }
                .padding()

                if viewModel.isSearching && viewModel.searchResults.isEmpty {
                    Text("No movies found for \"\(searchQuery)\"")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.isSearching ? viewModel.searchResults : viewModel.movies) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(viewModel.isFavorite(movie: movie)), viewModel: viewModel)) {
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
