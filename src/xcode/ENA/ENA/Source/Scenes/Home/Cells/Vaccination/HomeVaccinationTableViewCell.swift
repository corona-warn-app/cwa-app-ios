////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeVaccinationTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		certificateTitle.text = AppStrings.HealthCertificate.Info.Home.title
		certificateBody.text = AppStrings.HealthCertificate.Info.Home.body
		inProgressLabel.text = AppStrings.HealthCertificate.Info.Home.inProgress
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		containerView.setHighlighted(highlighted, animated: animated)
	}
	// MARK: - Internal

	func configure(with cellModel: HomeVaccinationCellModel) {
		guard !isConfigured else { return }

		cellModel.$vaccinatedPersonName.assign(to: \.text, on: nameLabel).store(in: &subscriptions)
		cellModel.$isProgressLabelHidden.assign(to: \.isHidden, on: inProgressLabel).store(in: &subscriptions)
		cellModel.$iconimage.assign(to: \.image, on: iconView).store(in: &subscriptions)
		cellModel.$backgroundColor.sink { [weak self] color in
			DispatchQueue.main.async {
				self?.containerView.backgroundColor = color
			}
		}.store(in: &subscriptions)
		isConfigured = true
	}
	
	// MARK: - Private

	@IBOutlet private weak var certificateTitle: ENALabel!
	@IBOutlet private weak var certificateBody: ENALabel!
	@IBOutlet private weak var inProgressLabel: ENALabel!
	@IBOutlet private weak var nameLabel: ENALabel!
	@IBOutlet private weak var iconView: UIImageView!
	@IBOutlet private weak var containerView: HomeCardView!

	private var isConfigured: Bool = false
	private var subscriptions = Set<AnyCancellable>()
}
