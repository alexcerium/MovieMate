//
//  MovieDetailView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import Kingfisher

struct MovieDetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    if let url = viewModel.movie.posterURL {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                            .frame(width: geometry.size.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.width * 1.5 / 1.0)

                HStack {
                    Text("Rating: \(viewModel.movie.voteAverage, specifier: "%.1f")")
                        .font(.subheadline)
                    Spacer()
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorite ? .yellow : .gray)
                    }
                }
                .padding(.vertical, 5)

                Text(viewModel.movie.overview)
                    .padding(.vertical, 10)

                if !viewModel.movieImages.isEmpty {
                    Text("Scenes").font(.headline).padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.movieImages.indices, id: \.self) { idx in
                                if let imgURL = viewModel.movieImages[idx].imageURL {
                                    NavigationLink(
                                        destination: FullScreenGalleryView(
                                            imageURLs: viewModel.movieImages.compactMap { $0.imageURL },
                                            selectedImageIndex: idx
                                        )
                                    ) {
                                        KFImage(imgURL)
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

                if let trailer = viewModel.movieVideos.first(where: { $0.type == "Trailer" && $0.site == "YouTube" }) {
                    Text("Trailer").font(.headline).padding(.top)
                    GeometryReader { _ in
                        YouTubePlayerView(videoID: trailer.key)
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                }
            }
            .padding()
            .onAppear {
                viewModel.loadDetails()
            }
        }
        .navigationTitle(viewModel.movie.title)
    }
}
