//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		// quick hack
		contentView.heightAnchor.constraint(equalToConstant: StatisticsViewController.height).isActive = true
	}

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
	}

	// MARK: - Internal

	func configure(
		with cellModel: HomeStatisticsCellModel,
		onInfoButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard !isConfigured else { return }

		cellModel.$keyFigureCards
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] in
				self?.configure(
					for: $0,
					onInfoButtonTap: onInfoButtonTap,
					onAccessibilityFocus: onAccessibilityFocus
				)
				self?.statisticsViewController.collectionView.reloadData()
				onUpdate()
			}
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel

		isConfigured = true
	}

	func add(statisticsViewController: StatisticsViewController, for parent: UIViewController) {
		assert(superview != nil)
		self.statisticsViewController = statisticsViewController
		statisticsViewController.loadViewIfNeeded()
		statisticsViewController.willMove(toParent: parent)
		contentView.addSubview(statisticsViewController.view)
		statisticsViewController.didMove(toParent: parent)

		NSLayoutConstraint.activate([
			statisticsViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
			statisticsViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			statisticsViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			statisticsViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			statisticsViewController.view.heightAnchor.constraint(equalToConstant: StatisticsViewController.height)
		])

		statisticsViewController.collectionView.reloadData()
		statisticsViewController.collectionView.setContentOffset(CGPoint(x: 100, y: 0), animated: false)
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

	lazy var statisticsViewController = StatisticsViewController()

	private func configure(
		for keyFigureCards: [SAP_Internal_Stats_KeyFigureCard],
		onInfoButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		statisticsViewController.statistics = keyFigureCards
		Log.debug("Added \(keyFigureCards.count) statistic entities", log: .ui)
		/*
		stackView.arrangedSubviews.forEach {
		stackView.removeArrangedSubview($0)
		$0.removeFromSuperview()
		}
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
		*/
	}
}
