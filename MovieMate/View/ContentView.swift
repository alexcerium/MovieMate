//
//  ContentView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel: MainViewModel

    init() {
        _viewModel = StateObject(wrappedValue: MainViewModel())
    }

    var body: some View {
        TabView {
            NavigationView {
                HomeView(viewModel: viewModel)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationView {
                RecommendationsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Recommendations", systemImage: "star.fill")
            }
            .tag(1)

            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(2)

            SearchView(viewModel: viewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(3)
        }
        .onAppear {
            Task {
                let container = try! ModelContainer(for: MovieEntity.self, GenreEntity.self)
                await viewModel.initialize(container: container)
            }
        }
    }
}

#Preview {
    ContentView()
}
