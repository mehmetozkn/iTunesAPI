//
//  SearchRouter.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol SearchRoutingLogic {
    func routeToPreview()
}

// Router, kaynak ekranın DataStore'una erişir
protocol SearchDataPassing {
    var dataStore: SearchDataStore? { get }
}

// Ekran geçişi ve ekranlar arası veri aktarımı
@MainActor
final class SearchRouter: SearchDataPassing {
    weak var viewController: UIViewController?
    var dataStore: SearchDataStore?
}

// MARK: - SearchRoutingLogic
extension SearchRouter: SearchRoutingLogic {

    func routeToPreview() {
        let destination = PreviewConfigurator.makeScene()
        guard let dataStore,
              let destinationDataStore = destination.router?.dataStore else { return }

        passDataToPreview(source: dataStore, destination: destinationDataStore)
        navigateToPreview(destination: destination)
    }

    // MARK: - Passing data
    func passDataToPreview(source: SearchDataStore, destination: PreviewDataStore) {
        destination.image = source.selectedImage
    }

    // MARK: - Navigation
    private func navigateToPreview(destination: UIViewController) {
        destination.modalPresentationStyle = .fullScreen
        destination.modalTransitionStyle = .crossDissolve
        viewController?.present(destination, animated: true)
    }
}
