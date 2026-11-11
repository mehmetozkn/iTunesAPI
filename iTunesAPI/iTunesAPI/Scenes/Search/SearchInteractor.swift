//
//  SearchInteractor.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol SearchBusinessLogic {
    func search(request: Search.Screenshots.Request)
    func selectScreenshot(request: Search.SelectScreenshot.Request)
}

// Router'ın başka ekrana aktaracağı veri
protocol SearchDataStore {
    var selectedImage: UIImage? { get }
}

// İş mantığı: arama, imaj indirme ve seçim
final class SearchInteractor: SearchDataStore {

    var presenter: SearchPresentationLogic?
    private(set) var selectedImage: UIImage?

    private let searchWorker: SearchWorkerProtocol
    private let imageDownloadWorker: ImageDownloadWorkerProtocol
    private var currentTerm = ""
    private var screenshotURLs: [URL] = []
    private var downloadedImages: [URL: UIImage] = [:]

    init(searchWorker: SearchWorkerProtocol,
         imageDownloadWorker: ImageDownloadWorkerProtocol) {
        self.searchWorker = searchWorker
        self.imageDownloadWorker = imageDownloadWorker
    }

    private func updateScreenshots(term: String, urls: [URL]) {
        screenshotURLs = urls
        downloadedImages = [:]
        presenter?.presentScreenshots(response: .init(term: term, urls: urls))
    }

    private func downloadImages(urls: [URL]) {
        imageDownloadWorker.download(urls: urls) { [weak self] url, image in
            // Eski aramadan gelen imaj yoksayılır
            guard let self, screenshotURLs.contains(url) else { return }
            if let image {
                downloadedImages[url] = image
            }
            presenter?.presentImage(response: .init(url: url, image: image))
        }
    }
}

// MARK: - SearchBusinessLogic
extension SearchInteractor: SearchBusinessLogic {

    func search(request: Search.Screenshots.Request) {
        let term = request.term.trimmingCharacters(in: .whitespacesAndNewlines)
        currentTerm = term

        // Önceki aramanın indirmeleri artık gereksiz
        imageDownloadWorker.cancelAll()

        guard !term.isEmpty else {
            searchWorker.cancel()
            updateScreenshots(term: term, urls: [])
            return
        }

        searchWorker(term: term) { [weak self] result in
            // Geç gelen eski arama cevabı yoksayılır
            guard let self, term == currentTerm else { return }

            switch result {
            case .success(let response):
                let urls = response.asScreenshotURLs()
                updateScreenshots(term: term, urls: urls)
                downloadImages(urls: urls)
            case .failure(let error):
                screenshotURLs = []
                downloadedImages = [:]
                presenter?.presentError(response: .init(error: error))
            }
        }
    }

    func selectScreenshot(request: Search.SelectScreenshot.Request) {
        // İmaj henüz inmediyse preview açılmaz
        guard screenshotURLs.indices.contains(request.index),
              let image = downloadedImages[screenshotURLs[request.index]] else { return }

        selectedImage = image
        presenter?.presentSelectedScreenshot(response: .init())
    }
}
