//
// 🦠 Corona-Warn-App
//


import UIKit
import OpenCombine

final class StatisticsViewController: UIViewController, UICollectionViewDataSource {

	static let height: CGFloat = 239 // from old satistics cell
	static let width: CGFloat = 250 // from old satistics cell

	var statistics: [SAP_Internal_Stats_KeyFigureCard] = []

	lazy var collectionView: UICollectionView = {
		let layout = PagingCollectionViewLayout()
		layout.sectionInset = .init(top: 0, left: spacing, bottom: 0, right: spacing)
		layout.minimumLineSpacing = cellSpacing
		layout.itemSize = .init(width: Self.width, height: Self.height - 20)
		layout.scrollDirection = .horizontal

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.decelerationRate = .fast
		collectionView.dataSource = self
		collectionView.backgroundColor = .magenta.withAlphaComponent(0.3) // debug!

		collectionView.register(UINib(nibName: "StatisticCell", bundle: nil), forCellWithReuseIdentifier: StatisticCell.reuseIdentifier)

		return collectionView
	}()

	// clamped: shortest side or 300pt max
	private lazy var width = {
		min(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), 300)
	}()
	private lazy var cellWidth = { 0.85 * width }()
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
	}

	// MARK: - UICollectionViewDataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return statistics.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticCell.reuseIdentifier, for: indexPath) as? StatisticCell else {
			preconditionFailure()
		}
		cell.label.text = indexPath.debugDescription
		cell.backgroundColor = .green
		Log.debug("configuring stat @ \(indexPath)", log: .ui)
		return cell
	}
}


private extension UICollectionViewCell {
	func addStyling() {
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
