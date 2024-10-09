//
//  MovieDetailView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import Kingfisher

struct MovieDetailView: View {
    let movie: Movie
    @Binding var isFavorite: Bool // Передаем состояние через @Binding
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var dragOffset = CGSize.zero
    @State private var movieImages: [MovieImage] = []
    @State private var movieVideos: [MovieVideo] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let url = movie.posterURL {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                        .offset(y: dragOffset.height > 0 ? dragOffset.height : 0)
                                        }

                HStack {
                    Text("Rating: \(movie.voteAverage, specifier: "%.1f")")
                        .font(.subheadline)
                    Spacer()
                    Button(action: {
                        isFavorite.toggle()
                        viewModel.toggleFavorite(movie: movie)
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                    }
                }
                .padding(.vertical, 5)

                Text(movie.overview)
                    .font(.body)
                    .padding(.vertical, 10)

                if !movieImages.isEmpty {
                    Text("Scenes")
                        .font(.headline)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(movieImages.indices, id: \.self) { index in
                                if let url = movieImages[index].imageURL {
                                    NavigationLink(destination: FullScreenGalleryView(imageURLs: movieImages.map { $0.imageURL! }, selectedImageIndex: index)) {
                                        KFImage(url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 120)
                                            .cornerRadius(10)
                                            .padding(.trailing, 5)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }

                if let trailer = movieVideos.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }) {
                    Text("Trailer")
                        .font(.headline)
                        .padding(.top)

                    YouTubePlayerView(videoID: trailer.key)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical)
                }
            }
            .padding()
            .onAppear {
                loadMovieDetails()
            }
        }
        .navigationTitle(movie.title)
    }

    private func loadMovieDetails() {
        viewModel.fetchMovieImages(movieId: movie.id) { images in
            self.movieImages = images
        }

        viewModel.fetchMovieVideos(movieId: movie.id) { videos in
            self.movieVideos = videos
        }
    }
}
