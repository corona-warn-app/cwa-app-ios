//
// 🦠 Corona-Warn-App
//


import UIKit
import OpenCombine

final class StatisticsViewController: UIViewController, UICollectionViewDataSource {

	enum DataStructureError: Error {
		case invalidIndex
	}

	static let height: CGFloat = 300
	let width: CGFloat = UIScreen.main.bounds.width * 0.8

	/// User-selected 'local/regional' statistics
	var userDefinedStatistics: [SAP_Internal_Stats_KeyFigureCard] = []
	/// The global statistics for everybody
	var statistics: [SAP_Internal_Stats_KeyFigureCard] = []

	lazy var collectionView: UICollectionView = {
		let layout = PagingCollectionViewLayout()
		layout.sectionInset = .init(top: 0, left: spacing, bottom: 0, right: spacing)
		layout.minimumLineSpacing = cellSpacing
		layout.itemSize = .init(width: width, height: Self.height - 20) // '20' = shadow offset
		layout.scrollDirection = .horizontal

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.decelerationRate = .fast
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.backgroundColor = .enaColor(for: .darkBackground)
		collectionView.register(UINib(nibName: "StatisticCell", bundle: nil), forCellWithReuseIdentifier: StatisticCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "ManageStatisticCell", bundle: nil), forCellWithReuseIdentifier: ManageStatisticCell.reuseIdentifier)

		return collectionView
	}()

	private let maxCountUserdefinedStatistics = 5
	private lazy var spacing = { 1 / 8 * width }()
	private lazy var cellSpacing = { 1 / 16 * width }()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(collectionView)

		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			collectionView.heightAnchor.constraint(equalToConstant: StatisticsViewController.height)
		])

		setEditing(true, animated: true)
	}

	// MARK: - UICollectionViewDataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		// We currently stick to one section although it could make sense to go to two:
		// 1. 'configurable' local statistics
		// 2. 'fixed' global statistics
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// general structure:
		// [add button/cell, if available] | [user defined statistics, if any] | [global statistics]
		return (canAddMoreStats() ? 1 : 0) + userDefinedStatistics.count + statistics.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.row == 0 {
			guard let managementCell = collectionView.dequeueReusableCell(withReuseIdentifier: ManageStatisticCell.reuseIdentifier, for: indexPath) as? ManageStatisticCell else {
				preconditionFailure()
			}
			return managementCell
		}

		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticCell.reuseIdentifier, for: indexPath) as? StatisticCell else {
			preconditionFailure()
		}

		do {
			let data = try statisticData(for: indexPath)
			let model = HomeStatisticsCardViewModel(for: data.statistic)
			cell.configure(
				viewModel: model,
				onInfoButtonTap: {},
				onAccessibilityFocus: {})
			cell.addStyling()
			return cell
		} catch {
			preconditionFailure("Invalid configuration") // needs a better description...
		}
	}

	func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
		true
	}

	// MARK: - Cell Management

	private func canAddMoreStats() -> Bool {
		return userDefinedStatistics.count < maxCountUserdefinedStatistics
	}

	private func insertLocalStatisticCell() {
		userDefinedStatistics.append(SAP_Internal_Stats_KeyFigureCard())
		// insert on 2nd position
		collectionView.insertItems(at: [IndexPath(row: 1, section: 0)])
	}

	private func statisticData(for indexPath: IndexPath) throws -> (statistic: SAP_Internal_Stats_KeyFigureCard, isUser: Bool) {
		guard indexPath.row > 0 else {
			// management cell
			throw DataStructureError.invalidIndex
		}

		let row = indexPath.row - 1 // management cell
		if row < userDefinedStatistics.count {
			// 'userdefined' statistics
			return (userDefinedStatistics[row], true)
		} else {
			// 'fixed' statistics
			return (statistics[row - userDefinedStatistics.count], false)
		}
	}
}

extension StatisticsViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if canAddMoreStats(), indexPath.section == 0, indexPath.row == 0 {
			// TODO: selection dialog
			insertLocalStatisticCell(/* params... */)
		}
	}
}

private extension UICollectionViewCell {
	func addStyling() {
		#warning("mock!")
		layer.borderWidth = 0.5
		layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor

		layer.shadowColor = UIColor.darkGray.cgColor
		layer.shadowOffset = CGSize(width: 3, height: 3)
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.4
		layer.masksToBounds = false

		isOpaque = false
	}
}
