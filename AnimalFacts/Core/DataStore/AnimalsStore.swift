//
//  AnimalsStore.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import ComposableArchitecture
import Foundation

public struct AnimalsStore {
    public var load: @Sendable (_ forceRefresh: Bool) async throws -> [CategoryDTO]
    
    public init(load: @escaping @Sendable (Bool) async throws -> [CategoryDTO]) {
        self.load = load
    }
}

public extension AnimalsStore {
    static func live(
        api: AnimalsAPI,
        memory: AnimalsMemoryCache = AnimalsMemoryCache(),
        ttl: TimeInterval = 60 * 60
    ) -> Self {
        .init(load: { forceRefresh in
            if !forceRefresh, let cached = await memory.read() {
                let isFresh = Date().timeIntervalSince(cached.timestamp) < ttl
                if isFresh, !cached.items.isEmpty {
                    return cached.items
                }
            }
            let items = try await api.fetchAnimals()
            await memory.write(items)
            return items
        })
    }
}

public extension DependencyValues {
    var animalsStore: AnimalsStore {
        get { self[AnimalsStoreKey.self] }
        set { self[AnimalsStoreKey.self] = newValue }
    }
}

// MARK: - DependencyKey

private enum AnimalsStoreKey: DependencyKey {
    static var liveValue: AnimalsStore {
        @Dependency(\.animalsAPI) var api
        return .live(api: api)
    }
}
