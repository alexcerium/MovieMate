//
//  HomeView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var currentIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Основная карусель с новыми фильмами
                if !viewModel.movies.isEmpty {
                    movieCarousel
                        .accessibilityIdentifier("moviesCarousel") // Устанавливаем идентификатор на уровне TabView
                }

                // Разделы жанров со списками фильмов
                genreSections
            }
        }
        .navigationTitle("Home")
        .onAppear {
            viewModel.loadHomeData()
        }
    }

    // Карусель с новыми фильмами
    private var movieCarousel: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(viewModel.movies.enumerated()), id: \.offset) { index, movie in
                let isFavorite = viewModel.isFavorite(movie: movie)
                NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                    MovieCardCarouselView(movie: movie)
                        .tag(index)
                }
            }
        }
        .frame(height: (UIScreen.main.bounds.width - 32) * 3 / 2) // Соотношение сторон 2:3
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .padding(.vertical)
        .onReceive(timer) { _ in
            withAnimation {
                if viewModel.movies.count > 0 {
                    currentIndex = (currentIndex + 1) % viewModel.movies.count
                }
            }
        }
    }

    // Разделы жанров
    private var genreSections: some View {
        ForEach(viewModel.genres) { genre in
            VStack(alignment: .leading, spacing: 10) {
                // Заголовок жанра
                NavigationLink(destination: MoviesByGenreView(viewModel: viewModel, genre: genre)) {
                    genreHeader(genre: genre)
                }

                // Горизонтальная карусель фильмов из жанра
                genreMoviesScrollView(genre: genre)
            }
        }
    }

    // Заголовок жанра
    private func genreHeader(genre: Genre) -> some View {
        HStack {
            Text(genre.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundColor(Color(white: 0.7))
        }
        .padding(.horizontal, 16)
    }

    // Горизонтальная карусель фильмов для жанра
    private func genreMoviesScrollView(genre: Genre) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.movies.filter { $0.genreIds.contains(genre.id) }) { movie in
                    let isFavorite = viewModel.isFavorite(movie: movie)
                    NavigationLink(destination: MovieDetailView(movie: movie, isFavorite: .constant(isFavorite), viewModel: viewModel)) {
                        MovieCardView(movie: movie)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
