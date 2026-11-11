//
//  PreviewViewController.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
import SnapKit

protocol PreviewDisplayLogic: AnyObject {
    func displayImage(viewModel: PreviewScene.LoadImage.ViewModel)
}

// Seçilen screenshot'ın büyük hali
final class PreviewViewController: UIViewController {

    var interactor: PreviewBusinessLogic?
    var router: (PreviewRoutingLogic & PreviewDataPassing)?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.accessibilityLabel = Strings.previewClose.localized()
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor?.loadImage(request: .init())
    }

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(imageView)
        view.addSubview(closeButton)

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(44)
        }
    }

    @objc private func closeTapped() {
        router?.dismissPreview()
    }
}

// MARK: - PreviewDisplayLogic
extension PreviewViewController: PreviewDisplayLogic {

    func displayImage(viewModel: PreviewScene.LoadImage.ViewModel) {
        imageView.image = viewModel.image
    }
}
