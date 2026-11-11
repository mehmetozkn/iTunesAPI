//
//  PreviewConfigurator.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// VIP parçalarını oluşturup birbirine bağlar
@MainActor
enum PreviewConfigurator {

    static func makeScene() -> PreviewViewController {
        let interactor = PreviewInteractor()
        let presenter = PreviewPresenter()
        let router = PreviewRouter()
        let viewController = PreviewViewController()

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
