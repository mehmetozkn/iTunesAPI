//
//  ImageDownloadWorker.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// İmaj nil ise indirme başarısız olmuştur
typealias ImageDownloadCompletion = (URL, UIImage?) -> Void

protocol ImageDownloadWorkerProtocol {
    func download(urls: [URL], completion: @escaping ImageDownloadCompletion)
    func cancelAll()
}

final class ImageDownloadWorker {

    let queue = OperationQueue()
    private let storage: ImageInMemoryStorageProtocol
    private let session: URLSession

    init(storage: ImageInMemoryStorageProtocol,
         session: URLSession = .shared,
         maxConcurrentDownloads: Int = 3) {
        self.storage = storage
        self.session = session
        // Aynı anda en fazla 3 indirme
        queue.maxConcurrentOperationCount = maxConcurrentDownloads
        queue.qualityOfService = .userInitiated
        queue.name = "com.mehmetozkan.iTunesAPI.imageDownload"
    }
}

// MARK: - ImageDownloadWorkerProtocol
extension ImageDownloadWorker: ImageDownloadWorkerProtocol {

    func download(urls: [URL], completion: @escaping ImageDownloadCompletion) {
        urls.forEach { url in
            // Cache'te varsa tekrar indirilmez
            if let cachedImage = storage.image(for: url) {
                completion(url, cachedImage)
                return
            }

            let operation = ImageDownloadOperation(url: url,
                                                   session: session,
                                                   storage: storage,
                                                   completion: completion)
            queue.addOperation(operation)
        }
    }

    // Yeni aramada bekleyen indirmeler iptal edilir
    func cancelAll() {
        queue.cancelAllOperations()
    }
}
