////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsTableViewCell: UITableViewCell {

	// MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()

		self.addGestureRecognizer(scrollView.panGestureRecognizer)
    }

	override func layoutSubviews() {
		super.layoutSubviews()
		self.scrollView.bounds.origin.x = self.scrollView.frame.size.width
	}

	// MARK: - Internal
	
	// swiftlint:disable:next function_parameter_count
	func configure(
		with keyFigureCellModel: HomeStatisticsCellModel,
		store: Store,
		onInfoButtonTap: @escaping () -> Void,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDeleteLocalStatistic: @escaping (SAP_Internal_Stats_AdministrativeUnitData, LocalStatisticsDistrict) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onFetchGroupData: @escaping (LocalStatisticsDistrict) -> Void,
		onToggleEditMode: @escaping (_ enabled: Bool) -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard !isConfigured else { return }

		keyFigureCellModel.$keyFigureCards
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] in
				self?.clearStackView()
				self?.configureLocalStatisticsCell(
					store: store,
					onAddLocalStatisticsButtonTap: onAddLocalStatisticsButtonTap,
					onAddDistrict: onAddDistrict,
					onDeleteLocalStatistic: onDeleteLocalStatistic,
					onDismissState: onDismissState,
					onDismissDistrict: onDismissDistrict,
					onFetchGroupData: onFetchGroupData,
					onToggleEditMode: onToggleEditMode,
					onAccessibilityFocus: onAccessibilityFocus
				)
				self?.configureKeyFigureCells(
					for: $0,
					onInfoButtonTap: onInfoButtonTap,
					onAccessibilityFocus: onAccessibilityFocus
				)
				onUpdate()
			}
			.store(in: &subscriptions)
		// Retaining cell model so it gets updated
		self.cellModel = keyFigureCellModel

		isConfigured = true

		keyFigureCellModel.$localAdministrativeUnitStatistics
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { administrativeUnitsData in
				self.insertLocalStatistics(
					store: store,
					administrativeUnitsData: administrativeUnitsData,
					onInfoButtonTap: onInfoButtonTap,
					onAccessibilityFocus: onAccessibilityFocus,
					onDeleteStatistic: onDeleteLocalStatistic
				)
				onUpdate()
			}
			.store(in: &subscriptions)
	}
	
	func insertLocalStatistics(
		store: Store,
		administrativeUnitsData: [SAP_Internal_Stats_AdministrativeUnitData],
		onInfoButtonTap:  @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onDeleteStatistic: @escaping (SAP_Internal_Stats_AdministrativeUnitData, LocalStatisticsDistrict) -> Void
	) {
		let administrativeUnit = administrativeUnitsData.first {
			$0.administrativeUnitShortID == UInt32(district?.districtId ?? "0")
		}
		
		guard let adminUnit = administrativeUnit, let districtName = district?.districtName else {
			// TODO: Error handling
			return
		}

		let nibName = String(describing: HomeStatisticsCardView.self)
		let nib = UINib(nibName: nibName, bundle: .main)

		if let statisticsCardView = nib.instantiate(withOwner: self, options: nil).first as? HomeStatisticsCardView {
			if !stackView.arrangedSubviews.isEmpty {
				stackView.insertArrangedSubview(statisticsCardView, at: 1)
				statisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
				statisticsCardView.configure(
					viewModel: HomeStatisticsCardViewModel(administrativeUnitData: adminUnit, district: districtName),
					onInfoButtonTap: {
						onInfoButtonTap()
					},
					onAccessibilityFocus: { [weak self] in
						self?.scrollView.scrollRectToVisible(statisticsCardView.frame, animated: false)
						onAccessibilityFocus()
						UIAccessibility.post(notification: .layoutChanged, argument: nil)
					},
					onDeleteTap: { [weak self] in
						// TODO: handle state, i.e. remove deselected entity from local statistics
						guard let district = self?.district else {
							assertionFailure("fix this!")
							return
						}
						Log.info("removing \(private: adminUnit.administrativeUnitShortID, public: "administrative unit") @ \(private: district.districtName, public: "district id")", log: .ui)
						onDeleteStatistic(adminUnit, district)

						self?.stackView.removeArrangedSubview(statisticsCardView)
						statisticsCardView.removeFromSuperview()
					}
				)
				// FIXME: dev code
				statisticsCardView.setEditMode(Self.editingStatistics, animated: true)

				configureBaselines(statisticsCardView: statisticsCardView)
			}
		}
	}
	// MARK: - Private

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var topConstraint: NSLayoutConstraint!
	@IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
	@IBOutlet private weak var trailingConstraint: NSLayoutConstraint!

	private var cellModel: HomeStatisticsCellModel?
	private var isConfigured: Bool = false
	private var subscriptions = Set<AnyCancellable>()
	private var district: LocalStatisticsDistrict?

	/// A temporary solution to speed up development
	private static var editingStatistics: Bool = false

	private func clearStackView() {
		stackView.arrangedSubviews.forEach {
			stackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
	}
	
	// swiftlint:disable:next function_parameter_count
	private func configureLocalStatisticsCell(
		store: Store,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDeleteLocalStatistic: @escaping (SAP_Internal_Stats_AdministrativeUnitData, LocalStatisticsDistrict) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onFetchGroupData: @escaping (LocalStatisticsDistrict) -> Void,
		onToggleEditMode: @escaping (_ enabled: Bool) -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		guard let jsonFileURL = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}
		let localStatisticsModel = LocalStatisticsModel(store: store, jsonFileURL: jsonFileURL)

		let nibName = String(describing: ManageStatisticsCardView.self)
		let nib = UINib(nibName: nibName, bundle: .main)
		
		if let manageLocalStatisticsCardView = nib.instantiate(withOwner: self, options: nil).first as? ManageStatisticsCardView {
			stackView.addArrangedSubview(manageLocalStatisticsCardView)
			manageLocalStatisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

			manageLocalStatisticsCardView.configure(
				localStatisticsModel: localStatisticsModel,
				availableCardsState: LocalStatisticsState.with(store),
				onAddStateButtonTap: { selectValueViewController in
					onAddLocalStatisticsButtonTap(selectValueViewController)
				}, onAddDistrict: { selectValueViewController in
					onAddDistrict(selectValueViewController)
				}, onDismissState: {
					onDismissState()
				}, onDismissDistrict: { dismissToRoot in
					onDismissDistrict(dismissToRoot)
				}, onFetchGroupData: { district in
					self.district = district
					onFetchGroupData(district)
				}, onEditButtonTap: {
					// FIXME: the local static var is currently for development. Keeping this locally will reset it on reloading of this cell. `onToggleEditMode` passes the current state to the tableViewController…
					Self.editingStatistics.toggle()
					onToggleEditMode(Self.editingStatistics)
				}, onAccessibilityFocus: {
					onAccessibilityFocus()
				}
			)
		}
	}
	
	private func configureKeyFigureCells(
		for keyFigureCards: [SAP_Internal_Stats_KeyFigureCard],
		onInfoButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		for keyFigureCard in keyFigureCards {
			let nibName = String(describing: HomeStatisticsCardView.self)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let statisticsCardView = nib.instantiate(withOwner: self, options: nil).first as? HomeStatisticsCardView {
				stackView.addArrangedSubview(statisticsCardView)

				statisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
				statisticsCardView.configure(
					viewModel: HomeStatisticsCardViewModel(for: keyFigureCard),
					onInfoButtonTap: {
						onInfoButtonTap()
					},
					onAccessibilityFocus: { [weak self] in
						self?.scrollView.scrollRectToVisible(statisticsCardView.frame, animated: false)
						onAccessibilityFocus()
						UIAccessibility.post(notification: .layoutChanged, argument: nil)
					}
				)
				configureBaselines(statisticsCardView: statisticsCardView)
			}
		}
		topConstraint.constant = keyFigureCards.isEmpty ? 0 : 12
		bottomConstraint.constant = keyFigureCards.isEmpty ? 0 : 12
		
		if UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.size.width <= 320 {
			trailingConstraint.constant = 12
		} else {
			trailingConstraint.constant = 65
		}

		accessibilityElements = stackView.arrangedSubviews
	}
	
	private func configureBaselines(statisticsCardView: HomeStatisticsCardView) {
		let cardViewCount = stackView.arrangedSubviews.count
		if cardViewCount > 1, let previousCardView = stackView.arrangedSubviews[cardViewCount - 2] as? HomeStatisticsCardView {
			NSLayoutConstraint.activate([
				statisticsCardView.titleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.titleLabel.firstBaselineAnchor),
				statisticsCardView.primaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.primaryTitleLabel.firstBaselineAnchor),
				statisticsCardView.secondaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.secondaryTitleLabel.firstBaselineAnchor),
				statisticsCardView.primarySubtitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.primarySubtitleLabel.firstBaselineAnchor),
				statisticsCardView.tertiaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.tertiaryTitleLabel.firstBaselineAnchor)
			])
		}
	}
}
