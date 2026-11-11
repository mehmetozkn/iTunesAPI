//
//  SearchFakes.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
@testable import iTunesAPI

// Ağa çıkmadan verilen sonucu döner
final class FakeSearchWorker: SearchWorkerProtocol {
    var result: SearchAPIResult = .success(SearchResponse(results: []))
    private(set) var searchedTerms: [String] = []
    private(set) var cancelCount = 0

    func callAsFunction(term: String, completion: @escaping SearchAPICompletion) {
        searchedTerms.append(term)
        completion(result)
    }

    func cancel() {
        cancelCount += 1
    }
}

// İndirme isteklerini kaydeder, completion'ı test tetikler
final class FakeImageDownloadWorker: ImageDownloadWorkerProtocol {
    private(set) var downloadedURLs: [URL] = []
    private(set) var cancelAllCount = 0
    private var completion: ImageDownloadCompletion?

    func download(urls: [URL], completion: @escaping ImageDownloadCompletion) {
        downloadedURLs = urls
        self.completion = completion
    }

    func cancelAll() {
        cancelAllCount += 1
    }

    func finishDownload(url: URL, image: UIImage?) {
        completion?(url, image)
    }
}

// Presenter'a gelen çağrıları kaydeder
final class FakeSearchPresenter: SearchPresentationLogic {
    private(set) var screenshotsResponse: Search.Screenshots.Response?
    private(set) var imageResponse: Search.LoadImage.Response?
    private(set) var errorResponse: Search.Failure.Response?

    func presentScreenshots(response: Search.Screenshots.Response) {
        screenshotsResponse = response
    }

    func presentImage(response: Search.LoadImage.Response) {
        imageResponse = response
    }

    func presentError(response: Search.Failure.Response) {
        errorResponse = response
    }

    private(set) var presentSelectedScreenshotCount = 0
    func presentSelectedScreenshot(response: Search.SelectScreenshot.Response) {
        presentSelectedScreenshotCount += 1
    }
}

// ViewController'a gelen çağrıları kaydeder
final class FakeSearchDisplay: SearchDisplayLogic {
    private(set) var screenshotsViewModel: Search.Screenshots.ViewModel?
    private(set) var imageViewModel: Search.LoadImage.ViewModel?
    private(set) var errorViewModel: Search.Failure.ViewModel?

    func displayScreenshots(viewModel: Search.Screenshots.ViewModel) {
        screenshotsViewModel = viewModel
    }

    func displayImage(viewModel: Search.LoadImage.ViewModel) {
        imageViewModel = viewModel
    }

    func displayError(viewModel: Search.Failure.ViewModel) {
        errorViewModel = viewModel
    }

    private(set) var displaySelectedScreenshotCount = 0
    func displaySelectedScreenshot(viewModel: Search.SelectScreenshot.ViewModel) {
        displaySelectedScreenshotCount += 1
    }
}

// Router testi için sabit imaj tutan DataStore
final class FakeSearchDataStore: SearchDataStore {
    var selectedImage: UIImage?
}

// Test verisi
enum TestData {
    static let url1 = URL(string: "https://example.com/1.jpg")!
    static let url2 = URL(string: "https://example.com/2.jpg")!
    static let url3 = URL(string: "https://example.com/3.jpg")!

    static let response = SearchResponse(results: [
        AppResultResponse(trackName: "App 1", screenshotUrls: [url1.absoluteString, url2.absoluteString]),
        AppResultResponse(trackName: "App 2", screenshotUrls: [url3.absoluteString])
    ])

    static let image = UIImage(systemName: "star")!
}
