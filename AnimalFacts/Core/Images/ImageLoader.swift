//
//  ImageLoader.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import ComposableArchitecture
import Foundation
import UIKit

final class ImageLoader {
    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()
    private var inflight: [URL: Task<UIImage, Error>] = [:]
    private let lock = NSLock()
    
    init(session: URLSession, totalCostLimit: Int = 64 * 1024 * 1024) {
        self.session = session
        cache.totalCostLimit = totalCostLimit // ~64MB
    }
    
    func load(_ url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        
        lock.lock()
        if let task = inflight[url] { lock.unlock(); return try await task.value }
        let task = Task<UIImage, Error> {
            let (data, resp) = try await self.session.data(from: url)
            guard
                let http = resp as? HTTPURLResponse,
                (200..<300).contains(http.statusCode),
                let img = UIImage(data: data)
            else { throw URLError(.badServerResponse) }
            self.cache.setObject(img, forKey: url as NSURL,
                                 cost: img.cgImage.map { $0.bytesPerRow * $0.height } ?? 0)
            return img
        }
        inflight[url] = task
        lock.unlock()
        
        defer {
            lock.lock(); inflight[url] = nil; lock.unlock()
        }
        return try await task.value
    }
    
    func prefetch(_ urls: [URL]) {
        for u in urls {
            Task { _ = try? await load(u) }
        }
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
