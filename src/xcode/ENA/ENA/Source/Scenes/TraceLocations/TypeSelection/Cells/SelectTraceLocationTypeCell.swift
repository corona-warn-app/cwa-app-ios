////
// 🦠 Corona-Warn-App
//

import UIKit

class SelectTraceLocationTypeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	// MARK: - Protocol <#Name#>

	func configure(cellViewModel: TraceLocationType) {
		titleLabel.text = cellViewModel.title
		subTitleLabel.text = cellViewModel.subtitle
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private#

	private let titleLabel = ENALabel()
	private let subTitleLabel = ENALabel()

	private func setupView() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .enaFont(for: .body)

		subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		subTitleLabel.font = .enaFont(for: .subheadline)

		let stackView = UIStackView(arrangedSubviews: [
			titleLabel,
			subTitleLabel
		])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 4.0
		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23.0),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0)
		])
	}


}
