//
//  PreviewTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Testing
@testable import iTunesAPI

@Suite("PreviewInteractor")
struct PreviewInteractorTests {

    private let presenter = FakePreviewPresenter()
    private let sut = PreviewInteractor()

    init() {
        sut.presenter = presenter
    }

    @Test("DataStore'da imaj varsa presenter'a iletilir")
    func loadImagePresentsImage() {
        // Given
        sut.image = TestData.image

        // When
        sut.loadImage(request: .init())

        // Then
        #expect(presenter.imageResponse?.image === TestData.image)
    }

    @Test("DataStore'da imaj yoksa bir şey gösterilmez")
    func loadImageWithoutImage() {
        // When
        sut.loadImage(request: .init())

        // Then
        #expect(presenter.imageResponse == nil)
    }
}

@Suite("PreviewPresenter")
struct PreviewPresenterTests {

    @Test("İmaj ekrana iletilir")
    func presentImageDisplaysImage() {
        // Given
        let display = FakePreviewDisplay()
        let sut = PreviewPresenter()
        sut.viewController = display

        // When
        sut.presentImage(response: .init(image: TestData.image))

        // Then
        #expect(display.imageViewModel?.image === TestData.image)
    }
}
