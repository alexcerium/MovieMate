//
//  CarouselView.swift
//  MovieMate
//
//  Created by Aleksandr on 09.06.2025.
//

import SwiftUI
import Combine

struct MovieCarouselView: View {
    let movies: [Movie]
    @Binding var currentIndex: Int
    let namespace: Namespace.ID
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let onSelect: (Movie) -> Void

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(movies.enumerated()), id: \.offset) { idx, movie in
                MovieCardCarouselView(movie: movie)
                    .matchedGeometryEffect(id: movie.id, in: namespace)
                    .tag(idx)
                    .onTapGesture { onSelect(movie) }
            }
        }
        .frame(height: (UIScreen.main.bounds.width - Layout.padding * 2) * 3 / 2)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onReceive(timer) { _ in
            withAnimation {
                if !movies.isEmpty {
                    currentIndex = (currentIndex + 1) % movies.count
                }
            }
        }
    }
}

struct MovieCarouselSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(height: (UIScreen.main.bounds.width - Layout.padding * 2) * 3 / 2)
            .redacted(reason: .placeholder)
    }
}
