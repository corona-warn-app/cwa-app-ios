////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		captionLabel.text = AppStrings.HealthCertificate.Home.Person.caption
		titleLabel.text = AppStrings.HealthCertificate.Home.Person.title

		backgroundGradientView.layer.cornerRadius = 14

		if #available(iOS 13.0, *) {
			backgroundGradientView.layer.cornerCurve = .continuous
		}
		setupAccessibility()
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		containerView.setHighlighted(highlighted, animated: animated)
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		subscriptions = []
	}

	// MARK: - Internal

	func configure(with cellModel: HomeHealthCertifiedPersonCellModel) {
		cellModel.$vaccinationState
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: vaccinationStateLabel)
			.store(in: &subscriptions)

		cellModel.$vaccinationState
			.receive(on: DispatchQueue.main.ocombine)
			.map { $0 == nil }
			.assign(to: \.isHidden, on: vaccinationStateLabel)
			.store(in: &subscriptions)

		cellModel.$name
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: nameLabel)
			.store(in: &subscriptions)

		cellModel.$iconImage
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.image, on: iconView)
			.store(in: &subscriptions)

		cellModel.$backgroundGradientType
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.type, on: backgroundGradientView)
			.store(in: &subscriptions)
	}
	
	// MARK: - Private

	@IBOutlet private weak var captionLabel: ENALabel!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var vaccinationStateLabel: ENALabel!
	@IBOutlet private weak var nameLabel: ENALabel!

	@IBOutlet private weak var iconView: UIImageView!

	@IBOutlet private weak var containerView: HomeCardView!
	@IBOutlet private weak var backgroundGradientView: GradientView!

	private var isConfigured: Bool = false
	private var subscriptions = Set<AnyCancellable>()

	private func setupAccessibility() {
		containerView.accessibilityElements = [captionLabel as Any, titleLabel as Any, vaccinationStateLabel as Any, nameLabel as Any]

		captionLabel.accessibilityTraits = [.header, .button]

	}
}
