//
//  SearchEndpointTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation
import Testing
@testable import iTunesAPI

@Suite("SearchEndpoint")
struct SearchEndpointTests {

    @Test("URL arama kelimesi, software ve limit içerir")
    func urlContainsParameters() throws {
        // Given
        let sut = SearchEndpoint(term: "instagram", limit: 10)

        // When
        let url = try #require(sut.url)

        // Then
        #expect(url.absoluteString == "https://itunes.apple.com/search?term=instagram&media=software&limit=10")
    }

    @Test("Boşluk ve Türkçe karakterler encode edilir")
    func urlEncodesSpacesAndTurkishCharacters() throws {
        // When
        let url = try #require(SearchEndpoint(term: "çiçek bahçe", limit: 10).url)

        // Then
        #expect(url.absoluteString.contains("term=%C3%A7i%C3%A7ek%20bah%C3%A7e"))
    }

    @Test("'+' karakteri boşluk sayılmasın diye encode edilir")
    func urlEncodesPlus() throws {
        // When
        let url = try #require(SearchEndpoint(term: "c++", limit: 10).url)

        // Then
        #expect(url.absoluteString.contains("term=c%2B%2B"))
    }
}
