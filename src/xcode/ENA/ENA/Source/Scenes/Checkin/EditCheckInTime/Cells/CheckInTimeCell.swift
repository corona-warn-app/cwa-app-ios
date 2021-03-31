////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckInTimeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(_ cellModel: CheckInTimeModel) {
		self.cellModel = cellModel
		typeLabel.text = cellModel.type
		topSeparatorView.isHidden = !cellModel.hasTopSeparator
		topLayoutConstraint.constant = cellModel.hasTopSeparator ? 16.0 : 0.0
		bottomLayoutConstraint.constant = cellModel.hasTopSeparator ? 0.0 : -16.0
		setNeedsLayout()
		cellModel.$date
			.receive(on: DispatchQueue.main.ocombine)
			.sink { _ in
				self.dateTimeLabel.text = cellModel.dateString
			}
			.store(in: &subscriptions)
	}

	// MARK: - Private

	private let typeLabel = ENALabel()
	private let dateTimeLabel = ENALabel()
	private let topSeparatorView = UIView()
	private var topLayoutConstraint: NSLayoutConstraint!
	private var bottomLayoutConstraint: NSLayoutConstraint!
	private var cellModel: CheckInTimeModel?
	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		typeLabel.font = .enaFont(for: .subheadline)
		typeLabel.textColor = .enaColor(for: .textPrimary1)

		dateTimeLabel.font = .enaFont(for: .subheadline)
		dateTimeLabel.textColor = .enaColor(for: .textPrimary1)
		dateTimeLabel.textAlignment = .right
		dateTimeLabel.numberOfLines = 1

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		contentView.addSubview(tileView)

		topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		topSeparatorView.backgroundColor = .enaColor(for: .hairline)
		tileView.addSubview(topSeparatorView)

		let stackView = AccessibleStackView(arrangedSubviews: [typeLabel, dateTimeLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 36.0
		stackView.distribution = .fill
		stackView.alignment = .center
		tileView.addSubview(stackView)

		topLayoutConstraint = stackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 12.0)
		bottomLayoutConstraint = stackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -12.0)
		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				topSeparatorView.topAnchor.constraint(equalTo: tileView.topAnchor),
				topSeparatorView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				topSeparatorView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0),
				topSeparatorView.heightAnchor.constraint(equalToConstant: 1.0),

				topLayoutConstraint,
				bottomLayoutConstraint,
				stackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				stackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

}
