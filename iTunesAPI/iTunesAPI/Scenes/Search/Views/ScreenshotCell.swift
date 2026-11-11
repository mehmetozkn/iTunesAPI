//
//  ScreenshotCell.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
import SnapKit

final class ScreenshotCell: UICollectionViewCell {

    static let reuseIdentifier = "ScreenshotCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Hücre tekrar kullanılırken eski imaj görünmesin
    override func prepareForReuse() {
        super.prepareForReuse()
        setImage(nil)
    }

    // nil ise imaj henüz inmemiştir, loading gösterilir
    func setImage(_ image: UIImage?) {
        imageView.image = image
        image == nil ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
