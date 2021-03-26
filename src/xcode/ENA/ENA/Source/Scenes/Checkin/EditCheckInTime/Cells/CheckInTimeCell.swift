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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
		}
	}

	// MARK: - Public

	// MARK: - Internal

	func configure(_ cellModel: CheckInTimeModel) {
		self.cellModel = cellModel
		typeLabel.text = cellModel.type

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
	private let stackView = UIStackView()
	private var cellModel: CheckInTimeModel?
	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		typeLabel.translatesAutoresizingMaskIntoConstraints = false
		typeLabel.font = .enaFont(for: .subheadline)
		typeLabel.textColor = .enaColor(for: .textPrimary1)

		dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		dateTimeLabel.font = .enaFont(for: .subheadline)
		dateTimeLabel.textColor = .enaColor(for: .textPrimary1)
		dateTimeLabel.textAlignment = .right
		dateTimeLabel.numberOfLines = 1

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .background)
		contentView.addSubview(tileView)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(typeLabel)
		stackView.addArrangedSubview(dateTimeLabel)
		stackView.spacing = 36.0
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
		tileView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				stackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 12.0),
				stackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -12.0),
				stackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				stackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

}
