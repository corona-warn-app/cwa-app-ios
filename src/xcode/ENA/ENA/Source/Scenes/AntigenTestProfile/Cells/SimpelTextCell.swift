////
// 🦠 Corona-Warn-App
//

import UIKit

class SimpelTextCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public

	// MARK: - Internal

	func configure(with cellViewModel: SimpelTextCellViewModel) {
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor ?? .clear
		contentTextLabel.textColor = cellViewModel.textColor
		contentTextLabel.textAlignment = cellViewModel.textAlignment
		contentTextLabel.text = cellViewModel.text
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let contentTextLabel = UILabel()

	private func setupView() {
		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(contentTextLabel)

	}

}
