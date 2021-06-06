////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateRequestTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell

		titleLabel.accessibilityTraits = [.header]
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		subscriptions = []
		cellModel = nil
	}

	// MARK: - Internal

	func configure(with cellModel: TestCertificateRequestCellModel, onUpdate: @escaping () -> Void) {
		titleLabel.text = cellModel.title
		subtitleLabel.text = cellModel.subtitle
		registrationDateLabel.text = cellModel.registrationDate

		loadingStateLabel.text = cellModel.loadingStateDescription

		cellModel.$isLoadingStateHidden
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.loadingStateStackView.isHidden = $0
				self?.loadingActivityIndicator.startAnimating()
				self?.updateAccessibilityElements()
				onUpdate()
			}
			.store(in: &subscriptions)

		tryAgainButton.setTitle(cellModel.buttonTitle, for: .normal)

		cellModel.$isTryAgainButtonHidden
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.tryAgainButton.isHidden = $0
				self?.updateAccessibilityElements()
				onUpdate()
			}
			.store(in: &subscriptions)

		self.cellModel = cellModel
	}
	
	// MARK: - Private

	private var cellModel: TestCertificateRequestCellModel?
	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var registrationDateLabel: ENALabel!

	@IBOutlet private weak var loadingStateStackView: UIStackView!
	@IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var loadingStateLabel: ENALabel!

	@IBOutlet private weak var tryAgainButton: ENAButton!

	@IBOutlet private weak var containerView: CardView!

	@IBAction private func didTapTryAgainButton(_ sender: Any) {
		cellModel?.didTapButton()
	}

	private func updateAccessibilityElements() {
		guard let cellModel = cellModel else {
			return
		}

		containerView.accessibilityElements = [titleLabel as Any, subtitleLabel as Any, registrationDateLabel as Any]

		if !cellModel.isLoadingStateHidden {
			containerView.accessibilityElements?.append(loadingStateLabel as Any)
		}

		if !cellModel.isTryAgainButtonHidden {
			containerView.accessibilityElements?.append(tryAgainButton as Any)
		}
	}

}
