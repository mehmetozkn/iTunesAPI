//
//  PreviewPresenter.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol PreviewPresentationLogic {
    func presentImage(response: PreviewScene.LoadImage.Response)
}

final class PreviewPresenter {
    // Retain cycle olmaması için weak
    weak var viewController: PreviewDisplayLogic?
}

// MARK: - PreviewPresentationLogic
extension PreviewPresenter: PreviewPresentationLogic {

    func presentImage(response: PreviewScene.LoadImage.Response) {
        viewController?.displayImage(viewModel: .init(image: response.image))
    }
}
