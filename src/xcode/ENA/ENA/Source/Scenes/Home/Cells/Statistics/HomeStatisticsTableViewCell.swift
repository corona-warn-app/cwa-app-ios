//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override var accessibilityElements: [Any]? {
		get {
			stackView.arrangedSubviews
		}

		// swiftlint:disable:next unused_setter_value
		set {
			preconditionFailure("This property is computed by the contents of the stack view")
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()

		self.addGestureRecognizer(scrollView.panGestureRecognizer)

		accessibilityIdentifier = AccessibilityIdentifiers.Statistics.General.tableViewCell
    }

	override func layoutSubviews() {
		super.layoutSubviews()

		// Scroll to first statistics card initially and when entering/leaving edit mode
		if scrollView.bounds.origin.x == 0, let firstStatisticsCard = stackView.arrangedSubviews[safe: 1] {
			DispatchQueue.main.async {
				self.scrollView.scrollRectToVisible(firstStatisticsCard.frame, animated: self.wasAlreadyShown)
				self.wasAlreadyShown = true
			}
		}
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		Self.editingStatistics = editing
		
		stackView.arrangedSubviews.forEach { view in
			let card = view as? HomeStatisticsCardView
			card?.setEditMode(editing, animated: animated)
		}
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let child = super.hitTest(point, with: event)

		// Forward tap events to the correct home statistics card view (needed for deletion of cards that are not currently in focus).
		if child == contentView {
			for arrangedSubview in stackView.arrangedSubviews {
				let convertedPoint = contentView.convert(point, to: arrangedSubview)
				if let staticsCardView = arrangedSubview as? HomeStatisticsCardView,
				   staticsCardView.point(inside: convertedPoint, with: event) {
					return staticsCardView.hitTest(convertedPoint, with: event)
				}
			}
		}

		return child
	}

	// MARK: - Internal
	// swiftlint:disable:next function_parameter_count
	func configure(
		with keyFigureCellModel: HomeStatisticsCellModel,
		store: Store,
		onInfoButtonTap: @escaping () -> Void,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard cellModel == nil else { return }
		
		keyFigureCellModel.$keyFigureCards
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.configureStatisticsCards(
					with: keyFigureCellModel,
					store: store,
					onInfoButtonTap: onInfoButtonTap,
					onAddLocalStatisticsButtonTap: onAddLocalStatisticsButtonTap,
					onAddDistrict: onAddDistrict,
					onDismissState: onDismissState,
					onDismissDistrict: onDismissDistrict,
					onAccessibilityFocus: onAccessibilityFocus,
					onUpdate: onUpdate
				)
			}
			.store(in: &subscriptions)
		
		keyFigureCellModel.$selectedLocalStatistics
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.configureStatisticsCards(
					with: keyFigureCellModel,
					store: store,
					onInfoButtonTap: onInfoButtonTap,
					onAddLocalStatisticsButtonTap: onAddLocalStatisticsButtonTap,
					onAddDistrict: onAddDistrict,
					onDismissState: onDismissState,
					onDismissDistrict: onDismissDistrict,
					onAccessibilityFocus: onAccessibilityFocus,
					onUpdate: onUpdate
				)
			}
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = keyFigureCellModel
	}

	// swiftlint:disable:next function_parameter_count
	func configureStatisticsCards(
		with keyFigureCellModel: HomeStatisticsCellModel,
		store: Store,
		onInfoButtonTap: @escaping () -> Void,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		clearStackView()

		configureManageLocalStatisticsCell(
			store: store,
			onAddLocalStatisticsButtonTap: onAddLocalStatisticsButtonTap,
			onAddDistrict: onAddDistrict,
			onDismissState: onDismissState,
			onDismissDistrict: onDismissDistrict,
			onAccessibilityFocus: onAccessibilityFocus
		)
		configureLocalStatisticsCards(
			store: store,
			onInfoButtonTap: onInfoButtonTap,
			onAccessibilityFocus: onAccessibilityFocus,
			onUpdate: onUpdate
		)
		configureKeyFigureCells(
			for: keyFigureCellModel.keyFigureCards,
			onInfoButtonTap: onInfoButtonTap,
			onAccessibilityFocus: onAccessibilityFocus
		)

		onUpdate()
	}

	func configureLocalStatisticsCards(
		store: Store,
		onInfoButtonTap:  @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard let cellModel = cellModel else {
			return
		}

		Log.debug("update with \(cellModel.selectedLocalStatistics.count) local stats", log: .localStatistics)

		removeLocalStatisticsCards()

		for singleSelectedLocalStatistics in cellModel.selectedLocalStatistics {
			localStatisticsRegion = singleSelectedLocalStatistics.localStatisticsRegion
			let regionName = singleSelectedLocalStatistics.localStatisticsRegion.name
			let regionStatistics: RegionStatisticsData
			guard let region = localStatisticsRegion else {
				Log.error("Could not assign localFederalState or localFederalState name", log: .localStatistics)
				return
			}

			switch region.regionType {
			case .federalState:
				let localFederalState = singleSelectedLocalStatistics.federalStateAndDistrictsData.federalStateData.first {
					$0.federalState.rawValue == Int(localStatisticsRegion?.id ?? "0")
				}
				guard let federalState = localFederalState else {
					Log.error("Could not assign localFederalState or localFederalState name", log: .localStatistics)
					return
				}
				regionStatistics = RegionStatisticsData(
					regionName: regionName,
					id: federalState.federalState.rawValue,
					updatedAt: federalState.updatedAt,
					sevenDayIncidence: federalState.sevenDayIncidence
				)

			case .administrativeUnit:
				let administrativeUnit = singleSelectedLocalStatistics.federalStateAndDistrictsData.administrativeUnitData.first {
					$0.administrativeUnitShortID == UInt32(localStatisticsRegion?.id ?? "0")
				}
				guard let adminUnit = administrativeUnit else {
					Log.error("Could not assign administrative unit or district name", log: .localStatistics)
					return
				}

				regionStatistics = RegionStatisticsData(
					regionName: regionName,
					id: Int(adminUnit.administrativeUnitShortID),
					updatedAt: adminUnit.updatedAt,
					sevenDayIncidence: adminUnit.sevenDayIncidence
				)
			}

			insertLocalStatistics(
				store: store,
				regionData: regionStatistics,
				onInfoButtonTap: onInfoButtonTap,
				onAccessibilityFocus: onAccessibilityFocus
			)
			onUpdate()
		}
	}
	
	func insertLocalStatistics(
		store: Store,
		regionData: RegionStatisticsData,
		onInfoButtonTap:  @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		let nibName = String(describing: HomeStatisticsCardView.self)
		let nib = UINib(nibName: nibName, bundle: .main)

		if let statisticsCardView = nib.instantiate(withOwner: self, options: nil).first as? HomeStatisticsCardView {
			if !stackView.arrangedSubviews.isEmpty {
				statisticsCardView.tag = 2
				stackView.insertArrangedSubview(statisticsCardView, at: 1)
				statisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
				statisticsCardView.configure(
					viewModel: HomeStatisticsCardViewModel(regionStatisticsData: regionData),
					onInfoButtonTap: {
						onInfoButtonTap()
					},
					onAccessibilityFocus: { [weak self] in
						self?.scrollView.scrollRectToVisible(statisticsCardView.frame, animated: true)
						onAccessibilityFocus()
						UIAccessibility.post(notification: .layoutChanged, argument: nil)
					},
					onDeleteTap: { [weak self] in
						guard let region = self?.localStatisticsRegion else {
							Log.error("Region can't be nil", log: .localStatistics, error: nil)
							return
						}
						Log.info("removing \(private: regionData.id, public: "administrative unit") @ \(private: region.name, public: "district id")", log: .ui)

						DispatchQueue.main.async { [weak self] in
							self?.stackView.removeArrangedSubview(statisticsCardView)
							statisticsCardView.removeFromSuperview()
						}

						// removing the district from the store
						store.selectedLocalStatisticsRegions = store.selectedLocalStatisticsRegions.filter { $0.id != String(regionData.id) }
						if let cellModel = self?.cellModel {
							cellModel.homeState.selectedLocalStatistics = cellModel.homeState.selectedLocalStatistics.filter { $0.localStatisticsRegion.id != String(regionData.id) }
						}

						self?.updateManagementCellState()
					}
				)
				statisticsCardView.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard
				statisticsCardView.setEditMode(Self.editingStatistics, animated: false)

				configureBaselines(statisticsCardView: statisticsCardView)
			}
		}
	}

	// MARK: - Private

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var trailingConstraint: NSLayoutConstraint!

	private var cellModel: HomeStatisticsCellModel?
	private var subscriptions = Set<AnyCancellable>()
	private var localStatisticsRegion: LocalStatisticsRegion?
	private var localStatisticsCache: LocalStatisticsCaching?

	private var wasAlreadyShown = false

	/// Keeping `editingStatistics` locally would reset it on reloading of this cell.
	/// Terrible design but simpler to handle than states passed through n layers of models, view controllers and views…
	static var editingStatistics: Bool = false

	private func clearStackView() {
		stackView.arrangedSubviews.forEach {
			stackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
	}
	
	private func removeLocalStatisticsCards() {
		stackView.arrangedSubviews.forEach {
			if $0.tag == 2 {
				stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}
		}
		stackView.layoutIfNeeded()
	}
	
	private func configureManageLocalStatisticsCell(
		store: Store,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		let localStatisticsModel = LocalStatisticsModel()

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
					// reset state
					self.setEditing(false, animated: true)
				}, onAddDistrict: { selectValueViewController in
					onAddDistrict(selectValueViewController)
				}, onDismissState: {
					onDismissState()
				}, onDismissDistrict: { dismissToRoot in
					onDismissDistrict(dismissToRoot)
				}, onFetchGroupData: { region in
					self.localStatisticsRegion = region
					self.cellModel?.homeState.fetchLocalStatistics(region: region)
				}, onEditButtonTap: {
					DispatchQueue.main.async {
						self.setEditing(!Self.editingStatistics, animated: true)
					}
				}, onAccessibilityFocus: { [weak self] in
					self?.scrollView.scrollRectToVisible(manageLocalStatisticsCardView.frame, animated: true)
					onAccessibilityFocus()
					UIAccessibility.post(notification: .layoutChanged, argument: nil)
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
						self?.scrollView.scrollRectToVisible(statisticsCardView.frame, animated: true)
						onAccessibilityFocus()
						UIAccessibility.post(notification: .layoutChanged, argument: nil)
					}
				)
				configureBaselines(statisticsCardView: statisticsCardView)
			}
		}
		
		if UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.size.width <= 320 {
			trailingConstraint.constant = 12
		} else {
			trailingConstraint.constant = 65
		}
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

	func updateManagementCellState() {
		guard
			let store = localStatisticsCache,
			let cell = stackView.arrangedSubviews.first as? ManageStatisticsCardView
		else {
			Log.error("Error because the store is Nil or the first card is not the ManageStatisticsCardView", log: .localStatistics, error: nil)
			return
		}

		let state = LocalStatisticsState.with(store)
		Log.debug("management state: \(state), \(store.selectedLocalStatisticsRegions.count)/\(store.localStatistics.count)", log: .localStatistics)
		cell.updateUI(for: state)
	}
}
