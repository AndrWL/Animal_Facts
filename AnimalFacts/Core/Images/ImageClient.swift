//
//  ImageClient.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import Dependencies
import Foundation
import UIKit

// MARK: - Public client for TCA

public struct ImageClient {
    public var load: @Sendable (URL) async throws -> UIImage
    public var prefetch: @Sendable ([URL]) -> Void
    public var clear: @Sendable () -> Void
    
    public init(
        load: @escaping @Sendable (URL) async throws -> UIImage,
        prefetch: @escaping @Sendable ([URL]) -> Void,
        clear: @escaping @Sendable () -> Void
    ) {
        self.load = load
        self.prefetch = prefetch
        self.clear = clear
    }
}

public extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClientKey.self] }
        set { self[ImageClientKey.self] = newValue }
    }
}

// MARK: - DependencyKey

private enum ImageClientKey: DependencyKey {
    static var liveValue: ImageClient {
        @Dependency(\.networkSession) var net
        let loader = ImageLoader(session: net.session)
        
        return ImageClient(
            load: { url in try await loader.load(url) },
            prefetch: { urls in loader.prefetch(urls) },
            clear: { loader.clear() }
        )
    }
}
