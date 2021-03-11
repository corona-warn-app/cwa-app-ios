////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayAddTableViewCell: UITableViewCell {
	
	// MARK: - Init
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	// MARK: - Internal

	func configure(cellModel: DiaryDayAddCellModel) {
		headerView.titleLabel.text = cellModel.text
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	private var headerView: DiaryDayCellHeaderView!
	
	private func setupView() {
		// self
		selectionStyle = .none
		// wrapperView
		let wrapperView = UIView()
		wrapperView.backgroundColor = .enaColor(for: .cellBackground)
		wrapperView.layer.masksToBounds = true
		wrapperView.layer.cornerRadius = 12
		wrapperView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(wrapperView)
		// headerView
		headerView = DiaryDayCellHeaderView()
		headerView.titleLabel.style = .headline
		headerView.iconView.image = UIImage(named: "Diary_Add")
		wrapperView.addSubview(headerView)
		// activate constrinats
		NSLayoutConstraint.activate([
			// wrapperView
			wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
			wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
			// headerView
			headerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
			headerView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
			headerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor)
		])
	}
}
