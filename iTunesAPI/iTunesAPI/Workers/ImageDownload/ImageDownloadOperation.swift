//
//  ImageDownloadOperation.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// Tek bir imajı indiren operation, OperationQueue'nun arka plan thread'inde çalışır
final class ImageDownloadOperation: Operation, @unchecked Sendable {

    let url: URL
    private let session: URLSession
    private let storage: ImageInMemoryStorageProtocol
    private let completion: ImageDownloadCompletion

    init(url: URL,
         session: URLSession,
         storage: ImageInMemoryStorageProtocol,
         completion: @escaping ImageDownloadCompletion) {
        self.url = url
        self.session = session
        self.storage = storage
        self.completion = completion
    }

    override func main() {
        guard !isCancelled else { return }

        // İndirme bitene kadar bekler, yoksa operation hemen biter ve 3'lü sınır işe yaramaz
        let semaphore = DispatchSemaphore(value: 0)
        var downloadedImage: UIImage?

        session.dataTask(with: url) { data, _, _ in
            // Decode arka planda yapılır, main thread'de takılma olmaz
            downloadedImage = data.flatMap { UIImage(data: $0) }?.preparingForDisplay()
            semaphore.signal()
        }.resume()

        semaphore.wait()

        // Bu sırada yeni arama yapıldıysa sonuç kullanılmaz
        guard !isCancelled else { return }

        if let downloadedImage {
            storage.save(downloadedImage, for: url)
        }

        let url = url
        let completion = completion
        DispatchQueue.main.async { completion(url, downloadedImage) }
    }
}
