//
//  CategoriesListFeature.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 11.09.2025.
//

import ComposableArchitecture
import Foundation

public struct CategoryItem: Equatable, Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let imageURL: URL?
    public let status: Status
    public var content: [ItemContent]
    
    public enum Status: Equatable {
        case free, paid, comingSoon
    }
    
    public struct ItemContent: Equatable, Identifiable {
        public let id = UUID()
        public let fact: String
        public let imageURL: URL?
    }
}

public struct CategoriesListFeature: Reducer {
    public struct State: Equatable {
        public var phase: Phase = .idle
        public var path = StackState<CategoryDetailFeature.State>()
        
        public enum Phase: Equatable {
            case idle
            case loading
            case content([CategoryItem])
            case empty
            case error(String)
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case refresh
        case loaded(TaskResult<[CategoryDTO]>)
        case retryTapped
        case rowTapped(CategoryItem)
        case path(StackAction<CategoryDetailFeature.State, CategoryDetailFeature.Action>)
    }
    
    @Dependency(\.animalsStore) var animalsStore
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh, .retryTapped:
                guard !isLoading(state.phase) else { return .none }
                state.phase = .loading
                return .run { [animalsStore = self.animalsStore] send in
                    await send(.loaded(
                        TaskResult { try await animalsStore.load(false) }
                    ))
                }
                
            case let .loaded(.success(dtos)):
                let items: [CategoryItem] = dtos
                    .sorted { $0.order < $1.order }
                    .map { dto in
                        let itemContent: [CategoryItem.ItemContent] = dto.content?.map {
                            CategoryItem.ItemContent(
                                fact: $0.fact,
                                imageURL: URL(string: $0.image ?? "")
                            )
                        } ?? []
                        
                        return CategoryItem(
                            title: dto.title,
                            description: dto.description,
                            imageURL: URL(string: dto.image ?? ""),
                            status: {
                                switch dto.status.lowercased() {
                                case "free": return .free
                                case "paid": return dto.content == nil ? .comingSoon : .paid
                                default:     return .comingSoon
                                }
                            }(),
                            content: itemContent
                        )
                    }
                state.phase = items.isEmpty ? .empty : .content(items)
                return .none
                
            case let .rowTapped(item):
                state.path.append(CategoryDetailFeature.State(item: item))
                return .none
                
            case let .loaded(.failure(error)):
                state.phase = .error((error as NSError).localizedDescription)
                return .none
                
            case .path(.element(id: let id, action: .backTapped)):
                state.path.pop(from: id)
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            CategoryDetailFeature()
        }
    }
    
    private func isLoading(_ p: State.Phase) -> Bool {
        if case .loading = p {
            return true
        } else {
            return false
        }
    }
}
