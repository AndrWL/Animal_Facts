//
//  CategoriesView.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 12.09.2025.
//

import ComposableArchitecture
import SwiftUI

public struct CategoriesView: View {
    let store: StoreOf<CategoriesListFeature>
    @Environment(\.appTheme) private var theme
        
    public var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: { .path($0) })
        ) {
            WithViewStore(store, observe: { $0 }) { vsAll in
                ZStack {
                    theme.background.ignoresSafeArea()
                    content(vsAll)
                        .padding(.horizontal, 20)
                }
                .task { vsAll.send(.onAppear) }
            }
            .alert(
                store: store.scope(state: \.$alert, action: { .alert($0) })
            )
            .overlay {
                WithViewStore(store, observe: \.isAdLoading) { vs in
                    if vs.state {
                        ZStack {
                            Color.black.opacity(0.3).ignoresSafeArea()
                            ProgressView("Loading…")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThickMaterial)
                                )
                        }
                        .transition(.opacity)
                    }
                }
            }
        } destination: { detailStore in
            CategoryDetailView(store: detailStore)
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
