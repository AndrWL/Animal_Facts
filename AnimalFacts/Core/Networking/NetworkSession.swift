//
//  NetworkSession.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import Foundation
import UIKit
import ComposableArchitecture

public struct NetworkSession {
    public let session: URLSession
    public init(session: URLSession) { self.session = session }
}

public extension DependencyValues {
    var networkSession: NetworkSession {
        get { self[NetworkSessionKey.self] }
        set { self[NetworkSessionKey.self] = newValue }
    }
}

private enum NetworkSessionKey: DependencyKey {
    static let liveValue: NetworkSession = {
        let urlCache = URLCache(
            memoryCapacity: 64 * 1024 * 1024,
            diskCapacity:   256 * 1024 * 1024,
            diskPath: "app_urlcache"
        )
        
        let cfg = URLSessionConfiguration.default
        cfg.urlCache = urlCache
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.timeoutIntervalForRequest = 15
        cfg.timeoutIntervalForResource = 30
        cfg.waitsForConnectivity = true
        
        return NetworkSession(session: URLSession(configuration: cfg))
    }()
}
