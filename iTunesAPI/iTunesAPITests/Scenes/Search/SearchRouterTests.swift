//
//  SearchRouterTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Testing
@testable import iTunesAPI

@MainActor
@Suite("SearchRouter")
struct SearchRouterTests {

    @Test("Seçilen imaj Preview DataStore'una aktarılır")
    func passDataToPreview() {
        // Given
        let source = FakeSearchDataStore()
        source.selectedImage = TestData.image
        let destination = PreviewInteractor()
        let sut = SearchRouter()

        // When
        sut.passDataToPreview(source: source, destination: destination)

        // Then
        #expect(destination.image === TestData.image)
    }

    @Test("Preview sahnesi DataStore ile birlikte kurulur")
    func previewSceneHasDataStore() {
        // When
        let preview = PreviewConfigurator.makeScene()

        // Then
        #expect(preview.interactor != nil)
        #expect(preview.router?.dataStore != nil)
    }
}
