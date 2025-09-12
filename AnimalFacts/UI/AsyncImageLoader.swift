//
//  AsyncImageLoader.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import SwiftUI

struct AsyncImageLoader: View {
    let url: URL?
    let height: CGFloat
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let img):
                img
                    .resizable()
                    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
                    .clipped()
            case .failure(_):
                Color.gray.opacity(0.2)
            case .empty:
                Color.gray.opacity(0.1)
            @unknown default:
                Color.gray.opacity(0.1)
            }
        }
    }
}
