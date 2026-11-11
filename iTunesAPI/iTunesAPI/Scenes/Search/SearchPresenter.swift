//
//  SearchPresenter.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol SearchPresentationLogic {
    func presentScreenshots(response: Search.Screenshots.Response)
    func presentImage(response: Search.LoadImage.Response)
    func presentError(response: Search.Failure.Response)
    func presentSelectedScreenshot(response: Search.SelectScreenshot.Response)
}

// Interactor'dan gelen veriyi ekranda gösterilecek hale getirir
final class SearchPresenter {

    // Retain cycle olmaması için weak
    weak var viewController: SearchDisplayLogic?

    static let placeholderImage = UIImage(systemName: "photo") ?? UIImage()
}

// MARK: - SearchPresentationLogic
extension SearchPresenter: SearchPresentationLogic {

    func presentScreenshots(response: Search.Screenshots.Response) {
        let message: String?
        if response.term.isEmpty {
            message = Strings.searchEmptyTermMessage.localized()
        } else if response.urls.isEmpty {
            message = Strings.searchNoResultMessage.localized()
        } else {
            message = nil
        }
        viewController?.displayScreenshots(viewModel: .init(urls: response.urls, message: message))
    }

    func presentImage(response: Search.LoadImage.Response) {
        // İndirme başarısızsa placeholder gösterilir
        let image = response.image ?? Self.placeholderImage
        viewController?.displayImage(viewModel: .init(url: response.url, image: image))
    }

    func presentError(response: Search.Failure.Response) {
        viewController?.displayError(viewModel: .init(message: Strings.searchErrorMessage.localized()))
    }

    func presentSelectedScreenshot(response: Search.SelectScreenshot.Response) {
        viewController?.displaySelectedScreenshot(viewModel: .init())
    }
}
