//
//  RowSkeletonView.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 11.09.2025.
//

import SwiftUI

public struct RowSkeletonView: View {
   public var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)).frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.2)).frame(height: 16)
                RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.2)).frame(height: 14).opacity(0.7)
                RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.2)).frame(width: 90, height: 20)
            }
        }
        .redacted(reason: .placeholder)
    }
}
