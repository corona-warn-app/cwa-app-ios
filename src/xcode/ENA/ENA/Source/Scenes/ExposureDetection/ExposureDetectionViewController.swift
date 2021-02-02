//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit
import OpenCombine

final class ExposureDetectionViewController: DynamicTableViewController, RequiresAppDependencies {

	// MARK: - Init

	init(
		viewModel: ExposureDetectionViewModel,
		store: Store
	) {
		self.viewModel = viewModel
        self.store = store

		super.init(nibName: "ExposureDetectionViewController", bundle: .main)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.accessibilityTraits = .header

		closeButton.isAccessibilityElement = true
		closeButton.accessibilityTraits = .button
		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		registerCells()

		viewModel.$dynamicTableViewModel
			.sink { [weak self] dynamicTableViewModel in
				self?.dynamicTableViewModel = dynamicTableViewModel
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)

		viewModel.$closeButtonStyle
			.sink { [weak self] in
				switch $0 {
				case .normal:
					self?.closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
					self?.closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
				case .contrast:
					self?.closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
					self?.closeButton.setImage(UIImage(named: "Icons - Close - Tap - Contrast"), for: .highlighted)
				}
			}
			.store(in: &subscriptions)

		viewModel.$exposureNotificationError
			.sink { [weak self] error in
				guard let self = self, let error = error else { return }

				self.viewModel.exposureNotificationError = nil

				self.alertError(message: error.localizedDescription, title: AppStrings.Common.alertTitleGeneral)
			}
			.store(in: &subscriptions)

		viewModel.$riskBackgroundColor.assign(to: \.backgroundColor, on: headerView).store(in: &subscriptions)

		viewModel.$titleText.assign(to: \.text, on: titleLabel).store(in: &subscriptions)
		viewModel.$titleTextAccessibilityColor.assign(to: \.accessibilityValue, on: titleLabel).store(in: &subscriptions)

		viewModel.$titleTextColor.assign(to: \.textColor, on: titleLabel).store(in: &subscriptions)

		viewModel.$buttonTitle
			.sink { [weak self] buttonTitle in
				UIView.performWithoutAnimation {
					self?.checkButton.setTitle(buttonTitle, for: .normal)

					self?.checkButton.layoutIfNeeded()
				}
			}
			.store(in: &subscriptions)

		viewModel.$isButtonHidden
			.sink { [weak self] in
				self?.footerView.isHidden = $0

				self?.footerView.layoutIfNeeded()
			}
			.store(in: &subscriptions)

		viewModel.$isButtonEnabled.assign(to: \.isEnabled, on: checkButton).store(in: &subscriptions)
		viewModel.$buttonTitle.assign(to: \.accessibilityLabel, on: checkButton).store(in: &subscriptions)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if footerView.isHidden {
			tableView.contentInset.bottom = 0
			tableView.verticalScrollIndicatorInsets.bottom = 0
		} else {
			tableView.contentInset.bottom = footerView.frame.height - tableView.safeAreaInsets.bottom
			tableView.verticalScrollIndicatorInsets.bottom = tableView.contentInset.bottom
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		(cell as? DynamicTypeTableViewCell)?.backgroundColor = .clear

		if cell.backgroundView == nil {
			cell.backgroundView = UIView()
		}

		if cell.backgroundColor == nil || cell.backgroundColor == .clear {
			cell.backgroundView?.backgroundColor = .enaColor(for: .background)
		}

		return cell
	}

	// MARK: - Internal

	enum ReusableCellIdentifier: String, TableViewCellReuseIdentifiers {
		case risk = "riskCell"
		case riskText = "riskTextCell"
		case riskRefresh = "riskRefreshCell"
		case riskLoading = "riskLoadingCell"
		case header = "headerCell"
		case guide = "guideCell"
		case longGuide = "longGuideCell"
		case link = "linkCell"
		case hotline = "hotlineCell"
		case survey = "surveyCell"
	}

	let viewModel: ExposureDetectionViewModel
    let store: Store

	// MARK: - Private

	@IBOutlet private var closeButton: UIButton!
	@IBOutlet private var headerView: UIView!
	@IBOutlet private var titleViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var footerView: UIView!
	@IBOutlet private var checkButton: ENAButton!

	private var subscriptions = Set<AnyCancellable>()

	@IBAction private func tappedClose() {
		dismiss(animated: true)
	}

	@IBAction private func tappedBottomButton() {
		viewModel.onButtonTap()
	}

	private func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.y

		if offset > 0 {
			titleViewBottomConstraint.constant = 0
		} else {
			titleViewBottomConstraint.constant = -offset
		}
	}

	private func registerCells() {
		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionHeaderCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.header.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionRiskCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.risk.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionLongGuideCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.longGuide.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionLoadingCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskLoading.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionHotlineCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.hotline.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionRiskRefreshCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskRefresh.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionRiskTextCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskText.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionGuideCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.guide.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.link.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionSurveyTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.survey.rawValue
		)
	}
	
}
