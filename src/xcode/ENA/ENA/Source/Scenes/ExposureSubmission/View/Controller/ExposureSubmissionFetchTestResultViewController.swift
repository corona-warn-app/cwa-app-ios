//
// 🦠 Corona-Warn-App
//
//  ExposureSubmissionFetchTestResultViewController.swift

import Foundation
import UIKit
import Combine

class ExposureSubmissionFetchTestResultViewController: DynamicTableViewController {
	
	// MARK: - Init

	init(_ viewModel: ExposureSubmissionFetchTestResultViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionFetchTestResultViewModel

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.isPrimaryButtonHidden = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.ExposureSubmissionDispatch.title

		return item
	}()

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear

		hidesBottomBarWhenPushed = true

		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionImageCardCell.self),
				bundle: nil
			),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableData
		tableView.separatorStyle = .none
	}

}

// MARK: Data extension for DynamicTableView.

private extension DynamicCell {
	static func imageCard(
		title: String,
		description: String? = nil,
		attributedDescription: NSAttributedString? = nil,
		image: UIImage?,
		action: DynamicAction,
		accessibilityIdentifier: String? = nil) -> Self {
		.identifier(ExposureSubmissionOverviewViewController.CustomCellReuseIdentifiers.imageCard, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionImageCardCell else { return }
			cell.configure(
				title: title,
				description: description ?? "",
				attributedDescription: attributedDescription,
				image: image,
				accessibilityIdentifier: accessibilityIdentifier)
		}
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionFetchTestResultViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}
}
