//
//  FullScreenImageView.swift
//  MovieMate
//
//  Created by Aleksandr on 27.08.2024.
//

import SwiftUI
import Kingfisher

struct FullScreenGalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    let imageURLs: [URL]
    @State private var selectedImageIndex: Int

    init(imageURLs: [URL], selectedImageIndex: Int) {
        self.imageURLs = imageURLs
        self._selectedImageIndex = State(initialValue: selectedImageIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedImageIndex) {
                ForEach(0..<imageURLs.count, id: \.self) { index in
                    KFImage(imageURLs[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .background(Color.black.ignoresSafeArea())

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .navigationBarHidden(true)
    }
}
