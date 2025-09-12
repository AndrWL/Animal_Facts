//
//  NavBarShadowView.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import SwiftUI

public struct NavBarShadowView: View {
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear.frame(height: 8)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.black.opacity(0.001))
                    .frame(height: 1 / UIScreen.main.scale)
                LinearGradient(
                    colors: [.black.opacity(0.25), .black.opacity(0.12), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 7)
            }
        }
        .allowsHitTesting(false)
    }
}
