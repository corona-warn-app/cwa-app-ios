//
// 🦠 Corona-Warn-App
//
//  ExposureSubmissionFetchTestResultViewController.swift

import Foundation
import UIKit

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

	// MARK: - Internal

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionFetchTestResultViewModel

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.isPrimaryButtonHidden = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.ExposureSubmissionDispatch.title
		item.largeTitleDisplayMode = .automatic

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
