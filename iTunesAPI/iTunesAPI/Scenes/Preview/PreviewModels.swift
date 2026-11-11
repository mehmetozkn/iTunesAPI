//
//  PreviewModels.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit

// VIP katmanları arasında taşınan modeller
enum PreviewScene {

    enum LoadImage {
        struct Request {}
        struct Response {
            let image: UIImage
        }
        struct ViewModel {
            let image: UIImage
        }
    }
}
