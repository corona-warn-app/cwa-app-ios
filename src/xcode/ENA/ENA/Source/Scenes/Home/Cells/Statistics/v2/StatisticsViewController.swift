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
		collectionView.backgroundColor = .clear
		collectionView.register(UINib(nibName: "StatisticCell", bundle: nil), forCellWithReuseIdentifier: StatisticCell.reuseIdentifier)
		collectionView.register(UINib(nibName: "ManageStatisticCell", bundle: nil), forCellWithReuseIdentifier: ManageStatisticCell.reuseIdentifier)

		return collectionView
	}()

	private let maxCountUserdefinedStatistics = 5
	private lazy var spacing = { 1 / 8 * width }()
	private lazy var cellSpacing = { 1 / 16 * width }()

	/// Is the collection view in edit mode
	///
	/// Don't confuse this with iOS 14's `isEditing` which is not used here!
	private var isEditMode: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(collectionView)

		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			collectionView.heightAnchor.constraint(equalToConstant: StatisticsViewController.height)
		])
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
			managementCell.handleAdd = {
				// TODO: handler for add element call
			}
			managementCell.handleModify = {
				// TODO: handler for modify element call
				self.isEditMode.toggle()
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
			// TODO: baselines
			return cell
		} catch {
			preconditionFailure("Invalid configuration") // needs a better description...
		}
	}

	/// Determines if a cell can be edited or not
	/// - Parameters:
	///   - collectionView: The context collection view
	///   - indexPath: The current IndexPath to check
	/// - Returns: `true` if the view can be edited, `false` if not
	private func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
		do {
			let result = try statisticData(for: indexPath)
			return result.isUser
		} catch {
			// intentionally ignoring the error here as it can happen for cell 0,0
			return false
		}
	}

	// MARK: - Cell Management

	private func canAddMoreStats() -> Bool {
		return userDefinedStatistics.count < maxCountUserdefinedStatistics
	}

	private func insertLocalStatisticCell() {
		userDefinedStatistics.append(SAP_Internal_Stats_KeyFigureCard())
		// insert always on 2nd position
		collectionView.insertItems(at: [IndexPath(row: 1, section: 0)])
		// TODO: update management cell
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

private extension UICollectionViewCell {
	func addStyling() {
		// FIXME: needs update to real values!
		layer.shadowColor = UIColor.darkGray.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowRadius = 6
		layer.shadowOpacity = 0.2
		layer.masksToBounds = false
	}
}
