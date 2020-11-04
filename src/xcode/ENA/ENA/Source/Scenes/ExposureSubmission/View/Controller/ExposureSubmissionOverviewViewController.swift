import AVFoundation
import Foundation
import UIKit

class ExposureSubmissionOverviewViewController: DynamicTableViewController {

	// MARK: - Init

	required init(
		onQRCodeButtonTap: @escaping () -> Void,
		onTANButtonTap: @escaping () -> Void,
		onHotlineButtonTap: @escaping () -> Void
	) {
		self.onQRCodeButtonTap = onQRCodeButtonTap
		self.onTANButtonTap = onTANButtonTap
		self.onHotlineButtonTap = onHotlineButtonTap

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

	private let onQRCodeButtonTap: () -> Void
	private let onTANButtonTap: () -> Void
	private let onHotlineButtonTap: () -> Void

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
				nibName: String(describing: ExposureSubmissionTestResultHeaderView.self),
				bundle: nil
			),
			forHeaderFooterViewReuseIdentifier: "test"
		)

		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionImageCardCell.self),
				bundle: nil
			),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue
		)

		dynamicTableViewModel = dynamicTableData()
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

private extension ExposureSubmissionOverviewViewController {
	func dynamicTableData() -> DynamicTableViewModel {
		var data = DynamicTableViewModel([])

		let header = DynamicHeader.blank

		data.add(
			.section(
				header: header,
				separators: .none,
				cells: [
					.body(
						text: AppStrings.ExposureSubmissionDispatch.description,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.description)
				]
			)
		)

		data.add(DynamicSection.section(cells: [
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription,
				image: UIImage(named: "Illu_Submission_QRCode"),
				action: .execute { [weak self] _ in self?.onQRCodeButtonTap() },
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.qrCodeButtonDescription
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.tanButtonDescription,
				image: UIImage(named: "Illu_Submission_TAN"),
				action: .execute { [weak self] _ in self?.onTANButtonTap() },
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
				attributedDescription: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription.inserting(emphasizedString: AppStrings.ExposureSubmissionDispatch.positiveWord),
				image: UIImage(named: "Illu_Submission_Anruf"),
				action: .execute { [weak self] _ in self?.onHotlineButtonTap() },
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.hotlineButtonDescription
			)
		]))

		return data
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionOverviewViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}
}
