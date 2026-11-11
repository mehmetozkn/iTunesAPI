//
//  SearchViewController.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import UIKit
import SnapKit

protocol SearchDisplayLogic: AnyObject {
    func displayScreenshots(viewModel: Search.Screenshots.ViewModel)
    func displayImage(viewModel: Search.LoadImage.ViewModel)
    func displayError(viewModel: Search.Failure.ViewModel)
    func displaySelectedScreenshot(viewModel: Search.SelectScreenshot.ViewModel)
}

final class SearchViewController: UIViewController {

    var interactor: SearchBusinessLogic?
    var router: (SearchRoutingLogic & SearchDataPassing)?

    // Ekranın gösterdiği state
    private var urls: [URL] = []
    private var images: [URL: UIImage] = [:]

    // Debounce: kullanıcı yazmayı bırakınca arama yapılır
    private var searchWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.3

    private enum Layout {
        static let columnCount: CGFloat = 3
        static let spacing: CGFloat = 8
        static let inset: CGFloat = 16
        static let imageRatio: CGFloat = 696 / 392
    }

    private let searchController = UISearchController(searchResultsController: nil)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Layout.spacing
        layout.minimumLineSpacing = Layout.spacing
        layout.sectionInset = UIEdgeInsets(top: Layout.inset, left: Layout.inset,
                                           bottom: Layout.inset, right: Layout.inset)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ScreenshotCell.self, forCellWithReuseIdentifier: ScreenshotCell.reuseIdentifier)
        return collectionView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor?.search(request: .init(term: ""))
    }

    private func setupUI() {
        title = Strings.searchTitle.localized()
        view.backgroundColor = .systemBackground

        searchController.searchBar.placeholder = Strings.searchPlaceholder.localized()
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(collectionView)
        view.addSubview(messageLabel)
        view.addSubview(activityIndicator)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        messageLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func scheduleSearch(term: String) {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.startSearch(term: term)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    private func startSearch(term: String) {
        let isEmpty = term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if !isEmpty {
            messageLabel.isHidden = true
            activityIndicator.startAnimating()
        }
        interactor?.search(request: .init(term: term))
    }

    private func showMessage(_ message: String?) {
        messageLabel.text = message
        messageLabel.isHidden = message == nil
    }
}

// MARK: - SearchDisplayLogic
extension SearchViewController: SearchDisplayLogic {

    func displayScreenshots(viewModel: Search.Screenshots.ViewModel) {
        activityIndicator.stopAnimating()
        urls = viewModel.urls
        images = [:]
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        showMessage(viewModel.message)
    }

    func displayImage(viewModel: Search.LoadImage.ViewModel) {
        // Eski aramadan gelen imaj yoksayılır
        guard urls.contains(viewModel.url) else { return }
        images[viewModel.url] = viewModel.image

        // Sadece ekranda görünen hücreler güncellenir, diğerleri cellForItemAt'te alır
        urls.indices
            .filter { urls[$0] == viewModel.url }
            .forEach { index in
                let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ScreenshotCell
                cell?.setImage(viewModel.image)
            }
    }

    func displayError(viewModel: Search.Failure.ViewModel) {
        activityIndicator.stopAnimating()
        urls = []
        images = [:]
        collectionView.reloadData()
        showMessage(viewModel.message)
    }

    func displaySelectedScreenshot(viewModel: Search.SelectScreenshot.ViewModel) {
        router?.routeToPreview()
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        scheduleSearch(term: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Klavyeden ara'ya basılınca beklemeden aranır
        searchWorkItem?.cancel()
        startSearch(term: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        startSearch(term: "")
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScreenshotCell.reuseIdentifier,
                                                            for: indexPath) as? ScreenshotCell else {
            return UICollectionViewCell()
        }
        cell.setImage(images[urls[indexPath.item]])
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = Layout.inset * 2 + Layout.spacing * (Layout.columnCount - 1)
        let width = floor((collectionView.bounds.width - totalSpacing) / Layout.columnCount)
        return CGSize(width: width, height: width * Layout.imageRatio)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor?.selectScreenshot(request: .init(index: indexPath.item))
    }
    
}
