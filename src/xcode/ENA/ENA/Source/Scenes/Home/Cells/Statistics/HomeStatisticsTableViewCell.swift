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

	// MARK: - Internal
	override func layoutSubviews() {
		super.layoutSubviews()
		self.scrollView.bounds.origin.x = self.scrollView.frame.size.width

	}
	
	// swiftlint:disable:next function_parameter_count
	func configure(
		with keyFigureCellModel: HomeStatisticsCellModel,
		store: Store,
		onInfoButtonTap: @escaping () -> Void,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onFetchFederalState: @escaping (LocalStatisticsDistrict) -> Void,
		onEditLocalStatisticsButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard !isConfigured else { return }

		keyFigureCellModel.$keyFigureCards
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] in
				self?.clearStackView()
				self?.configureAddLocalStatisticsCell(
					store: store,
					onAddLocalStatisticsButtonTap: onAddLocalStatisticsButtonTap,
					onAddDistrict: onAddDistrict,
					onDismissState: onDismissState,
					onDismissDistrict: onDismissDistrict,
					onFetchFederalState: onFetchFederalState,
					onEditLocalStatisticsButtonTap: onEditLocalStatisticsButtonTap,
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
	
	private func clearStackView() {
		stackView.arrangedSubviews.forEach {
			stackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
	}
	
	private func configureAddLocalStatisticsCell(
		store: Store,
		onAddLocalStatisticsButtonTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void,
		onFetchFederalState: @escaping (LocalStatisticsDistrict) -> Void,
		onEditLocalStatisticsButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		guard let jsonFileURL = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}
		let localStatisticsModel = AddLocalStatisticsModel(store: store, jsonFileURL: jsonFileURL)

		let addNibName = String(describing: AddStatisticsCardView.self)
		let addNib = UINib(nibName: addNibName, bundle: .main)
		if let addLocalStatisticsCardView = addNib.instantiate(withOwner: self, options: nil).first as? AddStatisticsCardView {
			stackView.addArrangedSubview(addLocalStatisticsCardView)
			addLocalStatisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
			addLocalStatisticsCardView.configure(
				localStatisticsModel: localStatisticsModel,
				availableCardsState: .empty, // TODO get state based on the current number of local statistics cards
				onAddStateButtonTap: { selectValueViewController in
					onAddLocalStatisticsButtonTap(selectValueViewController)
				}, onAddDistrict: { selectValueViewController in
					onAddDistrict(selectValueViewController)
				}, onDismissState: {
					onDismissState()
				}, onDismissDistrict: { dismissToRoot in
					onDismissDistrict(dismissToRoot)
				}, onFetchFederalState: { district in
					self.district = district
					onFetchFederalState(district)
				},
				onEditButtonTap: {
					onEditLocalStatisticsButtonTap()
				}, onAccessibilityFocus: {
					onAccessibilityFocus()
				}
			)
		}
	}
	private (set)var district: LocalStatisticsDistrict?

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
		topConstraint.constant = keyFigureCards.isEmpty ? 0 : 12
		bottomConstraint.constant = keyFigureCards.isEmpty ? 0 : 12
		
		if UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.size.width <= 320 {
			trailingConstraint.constant = 12
		} else {
			trailingConstraint.constant = 65
		}

		accessibilityElements = stackView.arrangedSubviews
	}
}
