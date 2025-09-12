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
        @PresentationState public var alert: AlertState<Action.Alert>?
        public var phase: Phase = .idle
        public var path = StackState<CategoryDetailFeature.State>()
        public var isAdLoading = false
        public var pendingPaidItem: CategoryItem?
        
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
        case alert(PresentationAction<Alert>)
        case adFinished
        
        public enum Alert: Equatable {
          case cancelTapped ,showAdTapped
        }
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
                switch item.status {
                case .free:
                    state.path.append(CategoryDetailFeature.State(item: item))
                    return .none
                case .paid:
                    state.pendingPaidItem = item
                    state.alert = AlertState {
                        TextState("Watch Ad to continue")
                    } actions: {
                        ButtonState(role: .cancel, action: .send(.cancelTapped)) {
                            TextState("Cancel")
                        }
                        ButtonState(action: .send(.showAdTapped)) {
                            TextState("Show Ad")
                        }
                    } message: {
                        TextState("Watch a short ad to unlock this content.")
                    }
                    return .none
                    
                case .comingSoon:
                    state.alert = AlertState {
                        TextState("Coming soon")
                    } actions: {
                        ButtonState(role: .cancel, action: .send(.cancelTapped)) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("This content will be available later.")
                    }
                }
                return .none
                
            case let .loaded(.failure(error)):
                state.phase = .error((error as NSError).localizedDescription)
                return .none
                
            case .path(.element(id: let id, action: .backTapped)):
                state.path.pop(from: id)
                return .none
                
            case .path:
                return .none
                
            case .alert(.presented(.cancelTapped)):
                state.alert = nil
                state.pendingPaidItem = nil
                return .none
                
            case .alert(.presented(.showAdTapped)):
                state.alert = nil
                state.isAdLoading = true
                return .run { send in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    await send(.adFinished)
                }
            case .adFinished:
                state.isAdLoading = false
                if let item = state.pendingPaidItem {
                    state.path.append(CategoryDetailFeature.State(item: item))
                }
                state.pendingPaidItem = nil
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert) { }
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
