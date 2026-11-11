//
//  SearchWorkerTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Testing
@testable import iTunesAPI

@Suite("SearchWorker")
struct SearchWorkerTests {

    private let networkClient = FakeNetworkClient()
    private let sut: SearchWorker

    init() {
        sut = SearchWorker(networkClient: networkClient)
    }

    @Test("Arama, kelime ve 10 sonuç limitiyle SearchEndpoint'e gider")
    func searchUsesSearchEndpoint() {
        // When
        sut(term: "instagram") { _ in }

        // Then
        let endpoint = networkClient.requestedEndpoints.first as? SearchEndpoint
        #expect(endpoint?.term == "instagram")
        #expect(endpoint?.limit == 10)
    }

    @Test("Network cevabı olduğu gibi iletilir")
    func searchForwardsResponse() {
        // Given
        networkClient.response = TestData.response
        var receivedCount: Int?

        // When
        sut(term: "instagram") { result in
            receivedCount = try? result.get().results.count
        }

        // Then
        #expect(receivedCount == 2)
    }

    @Test("Network hatası olduğu gibi iletilir")
    func searchForwardsError() {
        // Given
        networkClient.error = NetworkError.emptyData
        var receivedError: Error?

        // When
        sut(term: "instagram") { result in
            if case .failure(let error) = result { receivedError = error }
        }

        // Then
        #expect(receivedError is NetworkError)
    }
}
