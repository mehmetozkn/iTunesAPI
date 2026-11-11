//
//  SearchPresenterTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Testing
@testable import iTunesAPI

@Suite("SearchPresenter")
struct SearchPresenterTests {

    private let display = FakeSearchDisplay()
    private let sut = SearchPresenter()

    init() {
        sut.viewController = display
    }

    @Test("Sonuç varsa liste gösterilir, mesaj gösterilmez")
    func resultsHaveNoMessage() {
        // When
        sut.presentScreenshots(response: .init(term: "instagram", urls: [TestData.url1]))

        // Then
        #expect(display.screenshotsViewModel?.urls == [TestData.url1])
        #expect(display.screenshotsViewModel?.message == nil)
    }

    @Test("Arama boşsa yönlendirme mesajı gösterilir")
    func emptyTermShowsHint() {
        // When
        sut.presentScreenshots(response: .init(term: "", urls: []))

        // Then
        #expect(display.screenshotsViewModel?.message == Strings.searchEmptyTermMessage.localized())
    }

    @Test("Sonuç yoksa 'sonuç bulunamadı' gösterilir")
    func noResultShowsMessage() {
        // When
        sut.presentScreenshots(response: .init(term: "asdqwe", urls: []))

        // Then
        #expect(display.screenshotsViewModel?.message == Strings.searchNoResultMessage.localized())
    }

    @Test("İndirilen imaj olduğu gibi gösterilir")
    func downloadedImageIsDisplayed() {
        // When
        sut.presentImage(response: .init(url: TestData.url1, image: TestData.image))

        // Then
        #expect(display.imageViewModel?.url == TestData.url1)
        #expect(display.imageViewModel?.image === TestData.image)
    }

    @Test("İndirme başarısızsa placeholder gösterilir")
    func failedImageShowsPlaceholder() {
        // When
        sut.presentImage(response: .init(url: TestData.url1, image: nil))

        // Then
        #expect(display.imageViewModel?.image === SearchPresenter.placeholderImage)
    }

    @Test("Screenshot seçilince ekrana iletilir")
    func selectedScreenshotIsDisplayed() {
        // When
        sut.presentSelectedScreenshot(response: .init())

        // Then
        #expect(display.displaySelectedScreenshotCount == 1)
    }

    @Test("Hata gelince hata mesajı gösterilir")
    func errorShowsMessage() {
        // When
        sut.presentError(response: .init(error: NetworkError.emptyData))

        // Then
        #expect(display.errorViewModel?.message == Strings.searchErrorMessage.localized())
    }
}
