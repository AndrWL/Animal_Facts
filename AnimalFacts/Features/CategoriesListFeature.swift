//
//  CategoriesListFeature.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 11.09.2025.
//

import ComposableArchitecture
import SwiftUI

public struct CategoryItem: Equatable, Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let imageURL: URL?
    public let status: Status
    
    public enum Status: Equatable {
        case free, paid, comingSoon
    }
}

public struct CategoriesListFeature: Reducer {
    public struct State: Equatable {
        public var phase: Phase = .idle
        
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
                        CategoryItem(
                            title: dto.title,
                            description: dto.description,
                            imageURL: URL(string: dto.image ?? ""),
                            status: {
                                switch dto.status.lowercased() {
                                case "free": return .free
                                case "paid": return dto.content == nil ? .comingSoon : .paid
                                default: return .comingSoon
                                }
                            }()
                        )
                    }
                state.phase = items.isEmpty ? .empty : .content(items)
                return .none
                
            case let .rowTapped(item):
                return .none
                
            case let .loaded(.failure(error)):
                state.phase = .error((error as NSError).localizedDescription)
                return .none
                
            }
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

public struct CategoriesView: View {
    let store: StoreOf<CategoriesListFeature>
    @Environment(\.appTheme) private var theme
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            NavigationStack {
                ZStack {
                    theme
                        .background
                        .ignoresSafeArea()
                    content(vs)
                        .padding(.horizontal, 20)
                }
            }
            .task { vs.send(.onAppear) }
        }
    }
    
    @ViewBuilder
    private func content(_ vs: ViewStoreOf<CategoriesListFeature>) -> some View {
        switch vs.phase {
        case .idle, .loading:
            List {
                ForEach(0..<4, id: \.self) { _ in
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(theme.cardBackground)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        
                        RowSkeletonView()
                            .padding(8)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            .listRowSpacing(16)
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)
            .refreshable { vs.send(.refresh) }
            
        case .empty:
            VStack(spacing: 12) {
                Image(systemName: "tray")
                Text("No data")
                Button("Retry") { vs.send(.refresh) }
            }
            .padding()
            
        case .error(let msg):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                Text(msg).multilineTextAlignment(.center)
                Button("Retry") { vs.send(.retryTapped) }
            }
            .padding()
            
        case .content(let items):
            List(items) { item in
                let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)
                
                Button { store.send(.rowTapped(item)) } label: {
                    ZStack {
                        shape
                            .fill(theme.cardBackground)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        
                        ZStack {
                            shape.fill(theme.cardBackground)
                            CategoryRowView(item: item)
                                .padding(5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .clipShape(shape)
                        
                        if item.status == .comingSoon {
                            ZStack(alignment: .trailing) {
                                Color.black.opacity(0.6)
                                Image("coming_soon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 78)
                                    .padding(.trailing, 10)
                            }
                            .clipShape(shape)
                            .allowsHitTesting(false)
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .listRowSpacing(16)
            .scrollContentBackground(.hidden)
            .refreshable { store.send(.refresh) }
        }
    }
}

// MARK: - Ячейка списка
struct CategoryRowView: View {
    let item: CategoryItem
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                AsyncImage(url: item.imageURL) { phase in
                    Group {
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: Color.gray.opacity(0.15)
                        @unknown default: Color.gray.opacity(0.15)
                        }
                    }
                }
                .frame(width: 120, height: 90)
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
