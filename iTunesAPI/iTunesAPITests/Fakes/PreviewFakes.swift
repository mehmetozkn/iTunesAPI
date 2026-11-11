//
//  PreviewFakes.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
@testable import iTunesAPI

// Presenter'a gelen çağrıları kaydeder
final class FakePreviewPresenter: PreviewPresentationLogic {
    private(set) var imageResponse: PreviewScene.LoadImage.Response?

    func presentImage(response: PreviewScene.LoadImage.Response) {
        imageResponse = response
    }
}

// ViewController'a gelen çağrıları kaydeder
final class FakePreviewDisplay: PreviewDisplayLogic {
    private(set) var imageViewModel: PreviewScene.LoadImage.ViewModel?

    func displayImage(viewModel: PreviewScene.LoadImage.ViewModel) {
        imageViewModel = viewModel
    }
}
