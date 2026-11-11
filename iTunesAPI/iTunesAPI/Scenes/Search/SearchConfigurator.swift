//
//  SearchConfigurator.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// VIP parçalarını oluşturup birbirine bağlar (constructor injection)
@MainActor
enum SearchConfigurator {

    static func makeScene() -> UIViewController {
        let storage = ImageInMemoryStorage()
        let interactor = SearchInteractor(searchWorker: SearchWorker(networkClient: NetworkClient()),
                                          imageDownloadWorker: ImageDownloadWorker(storage: storage))
        let presenter = SearchPresenter()
        let router = SearchRouter()
        let viewController = SearchViewController()

        // VC -> Interactor -> Presenter -> VC (weak), Router -> DataStore (Interactor)
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
