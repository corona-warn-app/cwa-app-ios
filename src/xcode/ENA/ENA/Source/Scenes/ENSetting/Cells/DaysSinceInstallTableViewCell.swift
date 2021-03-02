//
// 🦠 Corona-Warn-App
//

import UIKit

class DaysSinceInstallTableViewCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		createAndLayoutViewHierarchy()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		let y = line.lineWidth / 2
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: y))
		path.addLine(to: CGPoint(x: contentView.bounds.width, y: y))
		line.path = path.cgPath
	}

	// MARK: - Internal

	func configure(daysSinceInstall: Int) {
		if daysSinceInstall < 14 {
			p2Label.text = String(format: AppStrings.Settings.daysSinceInstallP2a, daysSinceInstall)
		} else {
			p2Label.text = AppStrings.Settings.daysSinceInstallP1
		}
	}

	// MARK: - Private

	private let stackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 16
		return stackView
	}()

	private let titleLabel: ENALabel = {
		let label = ENALabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.style = .title2
		label.numberOfLines = 0
		label.text = AppStrings.Settings.daysSinceInstallTitle
		return label
	}()

	private let subTitleLabel: ENALabel = {
		let label = ENALabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.style = .subheadline
		label.textColor = .enaColor(for: .textPrimary2)
		label.numberOfLines = 0
		label.text = AppStrings.Settings.daysSinceInstallSubTitle
		return label
	}()

	private let p1Label: ENALabel = {
		let label = ENALabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.style = .body
		label.numberOfLines = 0
		label.text = AppStrings.Settings.daysSinceInstallP1
		return label
	}()

	private let p2Label: ENALabel = {
		let label = ENALabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.style = .body
		label.numberOfLines = 0
		label.text = AppStrings.Settings.daysSinceInstallSubTitle
		return label
	}()

	private var line = SeperatorLineLayer()

	private func createAndLayoutViewHierarchy() {
		addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
		])

		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(0, after: titleLabel)
		stackView.addArrangedSubview(subTitleLabel)
		stackView.addArrangedSubview(p1Label)
		stackView.addArrangedSubview(p2Label)
	}
}
