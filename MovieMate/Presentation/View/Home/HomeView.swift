//
//  HomeView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

// HomeView.swift
import SwiftUI

struct HomeView: View {
    let repository: MovieRepository
    let favoritesService: FavoritesService

    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @Namespace private var carouselNamespace
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.padding) {
                carouselSection
                genreSections
            }
            .padding(.horizontal, Layout.padding)
        }
        .navigationTitle("Home")
        .onAppear { viewModel.loadHomeData() }
        .refreshable { viewModel.refresh() }
    }

    @ViewBuilder
    private var carouselSection: some View {
        if viewModel.isLoading {
            MovieCarouselSkeleton()
        } else {
            MovieCarouselView(
                movies: viewModel.movies,
                currentIndex: $currentIndex,
                namespace: carouselNamespace,
                timer: timer,
                onSelect: coordinator.showDetail
            )
        }
    }

    private var genreSections: some View {
        ForEach(viewModel.genres) { genre in
            VStack(alignment: .leading, spacing: 8) {
                NavigationLink(
                    destination: MoviesByGenreView(
                        repository: repository,
                        favoritesService: favoritesService,
                        viewModel: MoviesByGenreViewModel(repository: repository),
                        genre: genre
                    )
                ) {
                    SectionHeaderView(title: genre.name)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.padding) {
                        ForEach(viewModel.movies.filter { $0.genreIds.contains(genre.id) }) { movie in
                            MovieCardView(movie: movie)
                                .frame(width: Layout.cardWidth, height: Layout.cardHeight)
                                .cornerRadius(Layout.cornerRadius)
                                .shadow(radius: 5)
                                .onTapGesture { coordinator.showDetail(movie) }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

private struct SectionHeaderView: View {
    let title: String
    var body: some View {
        HStack {
            Text(title).font(.title2).bold()
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}
