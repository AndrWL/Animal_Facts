//
//  CategoryDetailFeature.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public struct CategoryDetailFeature: Reducer {
    public struct State: Equatable {
        public let item: CategoryItem
        public var index: Int = 0
        public var direction: Direction = .forward
        
        public enum Direction: Equatable {
            case forward, back
        }
    }

    public enum Action: Equatable {
        case onAppear
        case backTapped
        case shareTapped
        case nextTapped
        case prevTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .backTapped:
                return .none
                
            case .shareTapped:
                guard let current = state.item.content[safe: state.index] else {
                    return .none
                }
                let fact = current.fact
                let link = current.imageURL

                return .run { _ in
                    await MainActor.run {
                        var items: [Any] = [fact]
                        if let url = link {
                            items.append(url)
                        }
                        ShareSheet.present(items: items)
                    }
                }
                
            case .nextTapped:
                guard !state.item.content.isEmpty else { return .none }
                state.direction = .back
                state.index = (state.index + 1 + state.item.content.count) % state.item.content.count
                return .none
                
            case .prevTapped:
                guard !state.item.content.isEmpty else { return .none }
                     state.direction = .forward
                state.index = (state.index - 1 + state.item.content.count) % state.item.content.count
                return .none
    
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
