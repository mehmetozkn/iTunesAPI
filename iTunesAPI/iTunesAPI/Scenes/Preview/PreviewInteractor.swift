//
//  PreviewInteractor.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

protocol PreviewBusinessLogic {
    func loadImage(request: PreviewScene.LoadImage.Request)
}

// Search router'ı imajı buraya yazar
protocol PreviewDataStore: AnyObject {
    var image: UIImage? { get set }
}

final class PreviewInteractor: PreviewDataStore {
    var presenter: PreviewPresentationLogic?
    var image: UIImage?
}

// MARK: - PreviewBusinessLogic
extension PreviewInteractor: PreviewBusinessLogic {

    func loadImage(request: PreviewScene.LoadImage.Request) {
        guard let image else { return }
        presenter?.presentImage(response: .init(image: image))
    }
}
