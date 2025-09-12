//
//  CategoryRowView.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import SwiftUI

public struct CategoryRowView: View {
    let item: CategoryItem
    @Environment(\.appTheme) private var theme
    
  public var body: some View {
        ZStack {
            HStack(spacing: 12) {
                AsyncImageLoader(url: item.imageURL, height: 90)
                .frame(width: 120)
                .clipped()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    Text(item.description)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(theme.textPrimary.opacity(0.5))
                    
                    Spacer()
                    
                    if item.status == .paid {
                        HStack(spacing: 2) {
                            Image(systemName: "lock.fill")
                            Text("Premium")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.accent)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 7)
            }
        }
    }
}
