//
//  SearchModels.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// VIP katmanları arasında taşınan modeller
enum Search {

    enum Screenshots {
        struct Request {
            let term: String
        }
        struct Response {
            let term: String
            let urls: [URL]
        }
        struct ViewModel {
            let urls: [URL]
            // nil ise liste gösterilir, değilse bilgi mesajı
            let message: String?
        }
    }

    enum LoadImage {
        struct Response {
            let url: URL
            let image: UIImage?
        }
        struct ViewModel {
            let url: URL
            let image: UIImage
        }
    }

    enum Failure {
        struct Response {
            let error: Error
        }
        struct ViewModel {
            let message: String
        }
    }

    // Seçilen imaj DataStore'a yazılır, Router oradan okur
    enum SelectScreenshot {
        struct Request {
            let index: Int
        }
        struct Response {}
        struct ViewModel {}
    }
}
