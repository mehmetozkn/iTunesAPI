//
//  SearchInteractorTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Testing
@testable import iTunesAPI

@Suite("SearchInteractor")
struct SearchInteractorTests {

    private let searchWorker = FakeSearchWorker()
    private let imageDownloadWorker = FakeImageDownloadWorker()
    private let presenter = FakeSearchPresenter()
    private let sut: SearchInteractor

    init() {
        sut = SearchInteractor(searchWorker: searchWorker, imageDownloadWorker: imageDownloadWorker)
        sut.presenter = presenter
    }

    @Test("Arama başarılı olunca düzleştirilmiş URL'ler presenter'a gider")
    func searchSuccessPresentsScreenshots() {
        // Given
        searchWorker.result = .success(TestData.response)

        // When
        sut.search(request: .init(term: "instagram"))

        // Then
        #expect(searchWorker.searchedTerms == ["instagram"])
        #expect(presenter.screenshotsResponse?.urls == [TestData.url1, TestData.url2, TestData.url3])
        #expect(presenter.screenshotsResponse?.term == "instagram")
    }

    @Test("Arama başarılı olunca tüm screenshot'lar indirilmeye başlar")
    func searchSuccessStartsDownloads() {
        // Given
        searchWorker.result = .success(TestData.response)

        // When
        sut.search(request: .init(term: "instagram"))

        // Then
        #expect(imageDownloadWorker.downloadedURLs == [TestData.url1, TestData.url2, TestData.url3])
    }

    @Test("İmaj inince presenter'a iletilir")
    func downloadedImageIsPresented() {
        // Given
        searchWorker.result = .success(TestData.response)
        sut.search(request: .init(term: "instagram"))

        // When
        imageDownloadWorker.finishDownload(url: TestData.url1, image: TestData.image)

        // Then
        #expect(presenter.imageResponse?.url == TestData.url1)
        #expect(presenter.imageResponse?.image === TestData.image)
    }

    @Test("Arama hata verirse presenter'a hata gider")
    func searchFailurePresentsError() {
        // Given
        searchWorker.result = .failure(NetworkError.emptyData)

        // When
        sut.search(request: .init(term: "instagram"))

        // Then
        #expect(presenter.errorResponse != nil)
        #expect(presenter.screenshotsResponse == nil)
    }

    @Test("Boş aramada istek atılmaz, boş liste gösterilir")
    func emptyTermDoesNotSearch() {
        // When
        sut.search(request: .init(term: "   "))

        // Then
        #expect(searchWorker.searchedTerms.isEmpty)
        #expect(searchWorker.cancelCount == 1)
        #expect(presenter.screenshotsResponse?.urls.isEmpty == true)
        #expect(presenter.screenshotsResponse?.term == "")
    }

    @Test("İnmiş screenshot seçilince DataStore'a yazılır ve presenter'a iletilir")
    func selectDownloadedScreenshot() {
        // Given
        searchWorker.result = .success(TestData.response)
        sut.search(request: .init(term: "instagram"))
        imageDownloadWorker.finishDownload(url: TestData.url2, image: TestData.image)

        // When
        sut.selectScreenshot(request: .init(index: 1))

        // Then
        #expect(sut.selectedImage === TestData.image)
        #expect(presenter.presentSelectedScreenshotCount == 1)
    }

    @Test("İnmemiş screenshot seçilince preview açılmaz")
    func selectNotDownloadedScreenshot() {
        // Given
        searchWorker.result = .success(TestData.response)
        sut.search(request: .init(term: "instagram"))

        // When
        sut.selectScreenshot(request: .init(index: 0))

        // Then
        #expect(sut.selectedImage == nil)
        #expect(presenter.presentSelectedScreenshotCount == 0)
    }

    @Test("Geçersiz index seçilince bir şey olmaz")
    func selectInvalidIndex() {
        // When
        sut.selectScreenshot(request: .init(index: 5))

        // Then
        #expect(presenter.presentSelectedScreenshotCount == 0)
    }

    @Test("Her yeni aramada önceki indirmeler iptal edilir")
    func newSearchCancelsDownloads() {
        // When
        sut.search(request: .init(term: "a"))
        sut.search(request: .init(term: "ab"))

        // Then
        #expect(imageDownloadWorker.cancelAllCount == 2)
    }
}
