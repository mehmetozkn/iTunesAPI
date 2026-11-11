//
//  SearchResponseTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation
import Testing
@testable import iTunesAPI

@Suite("SearchResponse")
struct SearchResponseTests {

    @Test("JSON decode edilir ve screenshot'lar tek listeye düzleşir")
    func decodeAndFlatten() throws {
        // Given
        let json = """
        {
          "resultCount": 2,
          "results": [
            { "trackName": "App 1", "screenshotUrls": ["https://example.com/1.jpg", "https://example.com/2.jpg"] },
            { "trackName": "App 2", "screenshotUrls": ["https://example.com/3.jpg"] }
          ]
        }
        """

        // When
        let response = try JSONDecoder().decode(SearchResponse.self, from: Data(json.utf8))

        // Then
        #expect(response.results.count == 2)
        #expect(response.asScreenshotURLs() == [TestData.url1, TestData.url2, TestData.url3])
    }

    @Test("screenshotUrls olmayan sonuç atlanır")
    func missingScreenshotsAreSkipped() throws {
        // Given
        let json = """
        { "results": [ { "trackName": "App" }, { "trackName": "App 2", "screenshotUrls": [] } ] }
        """

        // When
        let response = try JSONDecoder().decode(SearchResponse.self, from: Data(json.utf8))

        // Then
        #expect(response.asScreenshotURLs().isEmpty)
    }
}
