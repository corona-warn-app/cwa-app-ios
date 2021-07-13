////
// 🦠 Corona-Warn-App
//

import UIKit

class ManageStatisticsCardView: UIView {

	@IBOutlet weak var stackView: UIStackView!
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let borderColor: UIColor = .enaColor(for: .backgroundLightGray)
		layer.borderColor = borderColor.cgColor
		accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.manageStatisticsCard
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

		updateUI(for: availableCardsState)
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

	func updateUI(for state: LocalStatisticsState) {
		// clear
		stackView.arrangedSubviews.forEach { subview in
			stackView.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}

		let addView = { () -> CustomDashedView in
			let add = CustomDashedView.instance(for: .add)
			add.tapHandler = { [weak self] in
				Log.debug("add…", log: .ui)
				self?.onAddLocalIncidenceButtonPressed(add)
			}
			add.label.onAccessibilityFocus = onAccessibilityFocus
			return add
		}()

		let modifyView = { () -> CustomDashedView in
			let modify = CustomDashedView.instance(for: .modify)
			modify.tapHandler = { [weak self] in
				Log.debug("modify…", log: .ui)
				self?.onEditButtonTap?()
			}
			modify.label.onAccessibilityFocus = onAccessibilityFocus
			return modify
		}()

		switch state {
		case .empty:
			// just 'add'
			stackView.addArrangedSubview(addView)
		case .notYetFull:
			// 'add' & 'modify'
			stackView.addArrangedSubview(addView)
			stackView.addArrangedSubview(modifyView)
		case .full:
			// just 'modify'
			stackView.addArrangedSubview(modifyView)
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

	static func with(_ store: LocalStatisticsCaching) -> Self {
		switch store.selectedLocalStatisticsDistricts.count {
		case 0:
			return .empty
		case let count where count < 5:
			return .notYetFull
		case 5:
			return .full
		default:
			return .empty
		}
	}
}
