//
//  CategoryDetailView.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import ComposableArchitecture
import SwiftUI

public struct CategoryDetailView: View {
    let store: StoreOf<CategoryDetailFeature>
    @Environment(\.appTheme) private var appTheme

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                appTheme.background.ignoresSafeArea()
                
                let item = vs.state.item.content[vs.state.index]
                FactCardView(
                    title: item.fact,
                    imageURL: item.imageURL,
                    onPrev: { vs.send(.prevTapped) },
                    onNext: { vs.send(.nextTapped) }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { vs.send(.backTapped) }) {
                        Image(.back).font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(vs.item.title)
                        .font(.system(size: 17))
                        .foregroundStyle(appTheme.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { vs.send(.shareTapped) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17))
                            .foregroundStyle(appTheme.textPrimary)
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                NavBarShadowView()
                    .padding(.top, 12)
            }
        }
    }
}

private struct FactCardView: View {
    let title: String
    let imageURL: URL?
    
    let onPrev: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        
        ZStack {
            shape.fill(.white)
            
            VStack(spacing: 16) {
                AsyncImageLoader(url: imageURL, height: 235)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.7)
                
                Spacer(minLength: 0)
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 20)
            .clipShape(shape)
        }
        .frame(width: 320, height: 435)
        .overlay(alignment: .bottom) {
            HStack {
                Button(action: onPrev) {
                    Image(.backCircle).resizable().frame(width: 52, height: 52)
                }
                Spacer()
                Button(action: onNext) {
                    Image(.forwardCircle).resizable().frame(width: 52, height: 52)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
    }
}
