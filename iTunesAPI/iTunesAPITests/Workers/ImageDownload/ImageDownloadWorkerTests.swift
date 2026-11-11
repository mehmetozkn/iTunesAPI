//
//  ImageDownloadWorkerTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
import Testing
@testable import iTunesAPI

@Suite("ImageDownloadWorker")
struct ImageDownloadWorkerTests {

    @Test("Aynı anda en fazla 3 indirme yapılır")
    func maxConcurrentDownloadsIsThree() {
        // When
        let sut = ImageDownloadWorker(storage: ImageInMemoryStorage())

        // Then
        #expect(sut.queue.maxConcurrentOperationCount == 3)
    }

    @Test("Cache'teki imaj tekrar indirilmez, hemen döner")
    func cachedImageIsNotDownloaded() {
        // Given
        let storage = ImageInMemoryStorage()
        storage.save(TestData.image, for: TestData.url1)
        let sut = ImageDownloadWorker(storage: storage)
        sut.queue.isSuspended = true   // Kuyruğa eklenen olursa çalışmasın, sayılabilsin

        var returnedImage: UIImage?

        // When
        sut.download(urls: [TestData.url1]) { _, image in
            returnedImage = image
        }

        // Then
        #expect(returnedImage === TestData.image)
        #expect(sut.queue.operationCount == 0)
    }

    @Test("Cache'te olmayan imaj için kuyruğa operation eklenir")
    func missingImageIsQueued() {
        // Given
        let sut = ImageDownloadWorker(storage: ImageInMemoryStorage())
        sut.queue.isSuspended = true

        // When
        sut.download(urls: [TestData.url1, TestData.url2]) { _, _ in }

        // Then
        #expect(sut.queue.operationCount == 2)
        sut.cancelAll()
    }
}
