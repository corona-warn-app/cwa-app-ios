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
		
		keyFigureCellModel.$regionStatisticsData
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

		Log.debug("update with \(cellModel.regionStatisticsData.count) local stats", log: .localStatistics)

		for regionStatisticsData in cellModel.regionStatisticsData {
			insertLocalStatistics(
				store: store,
				regionData: regionStatisticsData,
				onInfoButtonTap: onInfoButtonTap,
				onAccessibilityFocus: onAccessibilityFocus
			)
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

				let widthConstraint = statisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
				widthConstraint.isActive = true

				var baselineConstraints: [NSLayoutConstraint] = []

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
						Log.info("removing \(private: regionData.region.id, public: "administrative unit") @ \(private: regionData.region.name, public: "district id")", log: .ui)

						widthConstraint.isActive = false
						baselineConstraints.forEach { $0.isActive = false }

						UIView.animate(
							withDuration: 0.25,
							animations: {
								statisticsCardView.isHidden = true
								statisticsCardView.alpha = 0
							},
							completion: { _ in
								self?.cellModel?.remove(regionData.region)
								self?.updateManagementCellState()
							}
						)
					}
				)
				statisticsCardView.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard
				statisticsCardView.setEditMode(Self.editingStatistics, animated: false)

				baselineConstraints = configureBaselines(statisticsCardView: statisticsCardView)
			}
		}
	}

	// MARK: - Private

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var trailingConstraint: NSLayoutConstraint!

	private var cellModel: HomeStatisticsCellModel?
	private var subscriptions = Set<AnyCancellable>()
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
					self.cellModel?.addLocalStatistics(region: region)
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

	@discardableResult
	private func configureBaselines(statisticsCardView: HomeStatisticsCardView) -> [NSLayoutConstraint] {
		let cardViewCount = stackView.arrangedSubviews.count
		if cardViewCount > 1, let previousCardView = stackView.arrangedSubviews[cardViewCount - 2] as? HomeStatisticsCardView {
			let constraints = [
				statisticsCardView.titleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.titleLabel.firstBaselineAnchor),
				statisticsCardView.primaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.primaryTitleLabel.firstBaselineAnchor),
				statisticsCardView.secondaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.secondaryTitleLabel.firstBaselineAnchor),
				statisticsCardView.primarySubtitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.primarySubtitleLabel.firstBaselineAnchor),
				statisticsCardView.tertiaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.tertiaryTitleLabel.firstBaselineAnchor)
			]

			NSLayoutConstraint.activate(constraints)

			return constraints
		}

		return []
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
