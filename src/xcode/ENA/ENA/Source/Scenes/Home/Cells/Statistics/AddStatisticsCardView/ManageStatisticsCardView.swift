////
// 🦠 Corona-Warn-App
//

import UIKit

class ManageStatisticsCardView: UIView {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let borderColor: UIColor = .enaColor(for: .backgroundLightGray)
		layer.borderColor = borderColor.cgColor
		// TODO: will move to the `CustomDashedView`
//		addLocalIncidenceLabel.text = AppStrings.Statistics.AddCard.sevenDayIncidence
//		addLocalIncidenceLabel.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidenceLabel
//		addLocalIncidencesButton.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
//		addLocalIncidenceLabel.onAccessibilityFocus = { [weak self] in
//			self?.onAccessibilityFocus?()
//		}
	}
	
	// swiftlint:disable:next function_parameter_count
	func configure(
		localStatisticsModel: LocalStatisticsModel,
		availableCardsState: LocalStatisticsState,
		onAddStateButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onFetchGroupData: @escaping (LocalStatisticsDistrict) -> Void,
		onEditButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		self.model = localStatisticsModel

		self.onAddStateButtonTap = onAddStateButtonTap
		self.onAddDistrict = onAddDistrict
		self.onDismissState = onDismissState
		self.onDismissDistrict = onDismissDistrict
		self.onFetchGroupData = onFetchGroupData
		self.onEditButtonTap = onEditButtonTap
		self.onAccessibilityFocus = onAccessibilityFocus

		// FIXME: development code
		updateUI(for: .notYetFull /*availableCardsState*/)
	}

	@IBAction func onAddLocalIncidenceButtonPressed(_ sender: Any) {
		guard let model = self.model else {
			Log.warning("AddStatistics model is nil", log: .localStatistics)
			return
		}
		viewModel = ManageStatisticsCardsViewModel(
			localStatisticsModel: model,
			presentFederalStatesList: { selectedStateValueViewModel in
				self.presentAddLocalStatistics(selectValueViewModel: selectedStateValueViewModel)
			},
			presentSelectDistrictsList: { selectedDistrictValueViewModel in
				self.presentAddLocalStatisticsDistrict(selectValueViewModel: selectedDistrictValueViewModel)
				
			}, onFetchGroupData: { [weak self] district in
				self?.onFetchGroupData?(district)
			}
		)
		viewModel?.presentStateSelection()
	}

	@IBOutlet weak var stackView: UIStackView!
	// TODO: These two guys will move to the `CustomDashedView`
	// @IBOutlet weak var addLocalIncidenceLabel: ENALabel!
	// @IBOutlet weak var addLocalIncidencesButton: UIButton!

	func updateUI(for state: LocalStatisticsState) {
		// clear
		stackView.arrangedSubviews.forEach { subview in
			stackView.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}

		switch state {
		case .empty:
			// just 'add'
			let add = CustomDashedView.instance(for: .add)
			add.tapHandler = {
				Log.debug("add…", log: .ui)
			}
			stackView.addArrangedSubview(add)
		case .notYetFull:
			// 'add' & 'modify'
			let add = CustomDashedView.instance(for: .add)
			add.tapHandler = {
				Log.debug("add…", log: .ui)
			}
			stackView.addArrangedSubview(add)

			let modify = CustomDashedView.instance(for: .modify)
			modify.tapHandler = {
				Log.debug("modify…", log: .ui)
			}
			stackView.addArrangedSubview(modify)
		case .full:
			// just 'modify'
			let modify = CustomDashedView.instance(for: .modify)
			modify.tapHandler = {
				Log.debug("modify…", log: .ui)
			}
			stackView.addArrangedSubview(modify)
		}
	}
	
	// MARK: - Private

	private func presentAddLocalStatistics(selectValueViewModel: SelectValueViewModel) {
		let selectValueViewController = SelectValueTableViewController(
			selectValueViewModel,
			closeOnSelection: false,
			dismiss: { [weak self] in
				self?.onDismissState?()
			})
		onAddStateButtonTap?(selectValueViewController)
	}

	private func presentAddLocalStatisticsDistrict(selectValueViewModel: SelectValueViewModel) {
		let selectValueViewController = SelectValueTableViewController(
			selectValueViewModel,
			closeOnSelection: true,
			dismiss: { [weak self] in
				let dismissToRoot = self?.viewModel?.district != nil
				self?.onDismissDistrict?(dismissToRoot)
			}
		)
		onAddDistrict?(selectValueViewController)
	}

	private var onAddStateButtonTap: ((SelectValueTableViewController) -> Void)?
	private var onAddDistrict: ((SelectValueTableViewController) -> Void)?
	private var onDismissState: (() -> Void)?
	private var onDismissDistrict: ((Bool) -> Void)?
	private var onFetchGroupData: ((LocalStatisticsDistrict) -> Void)?
	private var onEditButtonTap: (() -> Void)?
	private var onAccessibilityFocus: (() -> Void)?
	private var viewModel: ManageStatisticsCardsViewModel?
	private var model: LocalStatisticsModel?
}

enum LocalStatisticsState {
	/// No local stats selected
	case empty
	/// Can add more local statistics
	case notYetFull
	/// The maximum number of local statistics selected
	case full
}
