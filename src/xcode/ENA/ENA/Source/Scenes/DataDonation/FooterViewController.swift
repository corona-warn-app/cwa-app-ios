////
// 🦠 Corona-Warn-App
//

import UIKit

class FooterViewController: UIViewController {

	// MARK: - Init
	init(
		didTapPrimaryButton: @escaping () -> Void,
		didTapSecondaryButton: @escaping () -> Void
	) {
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapSecondaryButton = didTapSecondaryButton
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPrimaryButton()
		setupSecondaryButton()

		view.insetsLayoutMarginsFromSafeArea = false
		view.preservesSuperviewLayoutMargins = false
		view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		view.addSubview(primaryButton)
		view.addSubview(secondaryButton)

		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		primaryButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
		primaryButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
		primaryButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true

		secondaryButton.translatesAutoresizingMaskIntoConstraints = false
		secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: spacing).isActive = true
		secondaryButton.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor).isActive = true
		secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor).isActive = true

	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void
	private let spacing: CGFloat = 8
	
	private let primaryButton: ENAButton = ENAButton(type: .custom)
	private let secondaryButton: ENAButton = ENAButton(type: .custom)

	private func setupPrimaryButton() {
		primaryButton.setTitle("Primary Button", for: .normal)
		primaryButton.addTarget(self, action: #selector(didHitPrimaryButton), for: .primaryActionTriggered)
		primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.primaryFooterButton
	}

	private func setupSecondaryButton() {
		secondaryButton.setTitle("Secondary Button", for: .normal)
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didHitSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.secondaryFooterButton
	}

	@objc
	private func didHitPrimaryButton() {
		didTapPrimaryButton()
	}

	@objc
	private func didHitSecondaryButton() {
		didTapSecondaryButton()
	}
}
