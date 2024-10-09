//
//  YouTubePlayerView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        return playerView
    }

    func updateUIView(_ playerView: YTPlayerView, context: Context) {
        playerView.load(withVideoId: videoID)
    }
}
