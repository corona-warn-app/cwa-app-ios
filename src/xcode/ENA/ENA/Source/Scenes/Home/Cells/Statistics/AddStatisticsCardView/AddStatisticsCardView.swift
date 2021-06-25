////
// 🦠 Corona-Warn-App
//

import UIKit

class AddStatisticsCardView: CustomDashedView {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let borderColor: UIColor = .enaColor(for: .backgroundLightGray)
		layer.borderColor = borderColor.cgColor
		addLocalIncidenceLabel.text = AppStrings.Statistics.AddCard.sevenDayIncidence
		addLocalIncidenceLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}
	}
	// if local cards = 0: only show add button
	// if 0 < local cards < 5: show add and edit
	// if local cards = 5: show add and edit {disable add}
	// we can also pass store or something else to check the number or create enum for case
	
	// swiftlint:disable:next function_parameter_count
	func configure(
		localStatisticsModel: AddLocalStatisticsModel,
		availableCardsState: CreatedLocalStatisticsState,
		onAddStateButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onEditButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		self.model = localStatisticsModel

		self.onAddStateButtonTap = onAddStateButtonTap
		self.onAddDistrict = onAddDistrict
		self.onDismissState = onDismissState
		self.onDismissDistrict = onDismissDistrict
		self.onEditButtonTap = onEditButtonTap
		self.onAccessibilityFocus = onAccessibilityFocus
	}

	@IBAction func onAddLocalIncidenceButtonPressed(_ sender: Any) {
		guard let model = self.model else {
			Log.warning("AddStatistics model is nil", log: .localStatistics)
			return
		}
		viewModel = AddStatisticsCardsViewModel(
			localStatisticsModel: model,
			presentSelectStateList: { selectedStateValueViewModel in
				self.presentAddLocalStatistics(selectValueViewModel: selectedStateValueViewModel)
			},
			presentSelectDistrictList: { selectedDistrictValueViewModel in
				self.presentAddLocalStatisticsDistrict(selectValueViewModel: selectedDistrictValueViewModel)
				
			}
		)
		viewModel?.presentStateSelection()
	}
	
	@IBOutlet weak var addLocalIncidenceLabel: ENALabel!

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
	private var onEditButtonTap: (() -> Void)?
	private var onAccessibilityFocus: (() -> Void)?
	private var viewModel: AddStatisticsCardsViewModel?
	private var model: AddLocalStatisticsModel?
}

enum CreatedLocalStatisticsState {
	case empty // 0
	case notYetFull // 0 < number of local statistics cards < 5
	case full // 5
}
