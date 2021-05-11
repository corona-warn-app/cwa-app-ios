////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeVaccinationTableViewCell: UITableViewCell {
	
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

		cellModel.$isVerified.sink { [weak self] isVerified in
			DispatchQueue.main.async {
				if isVerified {
					self?.containerView.backgroundColor = .enaColor(for: .buttonPrimary)
					self?.inProgressLabel.isHidden = true
					self?.iconView.image = UIImage(named: "Vaccination_full")
				} else {
					self?.containerView.backgroundColor = .enaColor(for: .riskNeutral)
					self?.inProgressLabel.isHidden = false
					self?.iconView.image = UIImage(named: "Vacc_Incomplete")
				}
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
