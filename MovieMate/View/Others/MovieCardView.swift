//
//  MovieCardView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import Kingfisher

// Представление для карточки фильма
struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(spacing: 0) {
            if let url = movie.posterURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 225)
                    .cornerRadius(10)
                    .clipped()
            }
        }
        .frame(width: 150, height: 225)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Представление для карусели фильмов
struct MovieCardCarouselView: View {
    let movie: Movie

    var body: some View {
        // Постер фильма
        if let url = movie.posterURL {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 32, height: (UIScreen.main.bounds.width - 32) * 3 / 2) // Соотношение 2:3
                .cornerRadius(15)
                .clipped()
                .shadow(radius: 5)
        }
    }
}
