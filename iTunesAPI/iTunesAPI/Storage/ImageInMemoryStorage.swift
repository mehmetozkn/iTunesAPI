//
//  ImageInMemoryStorage.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol ImageInMemoryStorageProtocol {
    func image(for url: URL) -> UIImage?
    func save(_ image: UIImage, for url: URL)
    func removeAll()
}

final class ImageInMemoryStorage {

    private let cache = NSCache<NSURL, UIImage>()

    init(countLimit: Int = 200) {
        cache.countLimit = countLimit
    }
}

// MARK: - ImageInMemoryStorageProtocol
extension ImageInMemoryStorage: ImageInMemoryStorageProtocol {

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func save(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
