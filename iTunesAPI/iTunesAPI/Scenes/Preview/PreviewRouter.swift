//
//  PreviewRouter.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol PreviewRoutingLogic {
    func dismissPreview()
}

protocol PreviewDataPassing {
    var dataStore: PreviewDataStore? { get }
}

final class PreviewRouter: PreviewDataPassing {
    weak var viewController: UIViewController?
    var dataStore: PreviewDataStore?
}

// MARK: - PreviewRoutingLogic
extension PreviewRouter: PreviewRoutingLogic {

    func dismissPreview() {
        viewController?.dismiss(animated: true)
    }
}
