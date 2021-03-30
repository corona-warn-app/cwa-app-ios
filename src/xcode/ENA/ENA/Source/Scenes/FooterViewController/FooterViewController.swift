////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

/**
	If the ViewController and the FooterViewController are composed inside a TopBottomContainer,
	ViewController that implement this protocol get called if a button gets tapped in the footerViewController
*/
protocol FooterViewHandling {
	var footerView: FooterViewUpdating? { get }
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType)
}

extension FooterViewHandling where Self: UIViewController {
	var footerView: FooterViewUpdating? {
		return parent as? FooterViewUpdating
	}
}

class FooterViewController: UIViewController {

	// MARK: - Init
	init(
		_ viewModel: FooterViewModel,
		didTapPrimaryButton: @escaping () -> Void = {},
		didTapSecondaryButton: @escaping () -> Void = {}
	) {
		self.viewModel = viewModel
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

		view.insetsLayoutMarginsFromSafeArea = false
		view.preservesSuperviewLayoutMargins = false
		view.layoutMargins = UIEdgeInsets(
			top: viewModel.topBottomInset,
			left: viewModel.leftRightInset,
			bottom: viewModel.topBottomInset,
			right: viewModel.leftRightInset
		)

		view.addSubview(primaryButton)
		view.addSubview(secondaryButton)

		primaryButton.hasBackground = true
		primaryButton.addTarget(self, action: #selector(didHitPrimaryButton), for: .primaryActionTriggered)
		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didHitSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.translatesAutoresizingMaskIntoConstraints = false

		updateViewModel()
	}

	// MARK: - Internal

	var viewModel: FooterViewModel {
		didSet {
			updateViewModel()
		}
	}

	// MARK: - Private

	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void

	private let primaryButton: ENAButton = ENAButton(type: .custom)
	private let secondaryButton: ENAButton = ENAButton(type: .custom)

	private var buttonConstraints = [NSLayoutConstraint]()
	private var subscription: [AnyCancellable] = []

	@objc
	private func didHitPrimaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapPrimaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.primary)
	}

	@objc
	private func didHitSecondaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapSecondaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.secondary)
	}
	
	private func updateViewModel() {
		
		// clear and reset
		
		subscription.forEach { $0.cancel() }
		subscription.removeAll()
		
		NSLayoutConstraint.deactivate(buttonConstraints)
		buttonConstraints.removeAll()
		
		// background color
		
		view.backgroundColor = viewModel.backgroundColor
		
		// primary button
		
		primaryButton.color = viewModel.primaryButtonColor
		primaryButton.hasBackground = !viewModel.primaryButtonInverted
		primaryButton.setTitle(viewModel.primaryButtonName, for: .normal)
		primaryButton.accessibilityIdentifier = viewModel.primaryIdentifier
		primaryButton.alpha = viewModel.isPrimaryButtonHidden ? 0.0 : 1.0
		primaryButton.isHidden = !viewModel.isPrimaryButtonEnabled
		primaryButton.isEnabled = viewModel.isPrimaryButtonEnabled
		
		// secondary button
		
		secondaryButton.color = viewModel.secondaryButtonColor
		secondaryButton.hasBackground = !viewModel.secondaryButtonInverted
		secondaryButton.setTitle(viewModel.secondaryButtonName, for: .normal)
		secondaryButton.accessibilityIdentifier = viewModel.secondaryIdentifier
		secondaryButton.alpha = viewModel.isSecondaryButtonHidden ? 0.0 : 1.0
		secondaryButton.isHidden = !viewModel.isSecondaryButtonEnabled
		secondaryButton.isEnabled = viewModel.isSecondaryButtonEnabled
		
		// update button constraints

		buttonConstraints = [
			// primaryButton
			primaryButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			primaryButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
			primaryButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
			primaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight),
			// secondaryButton
			secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: viewModel.spacer),
			secondaryButton.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
			secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor),
			secondaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight)
		]
		
		NSLayoutConstraint.activate(buttonConstraints)
		
		// subscribe to view model properties

		viewModel.$height
			.receive(on: DispatchQueue.main.ocombine)
			.sink { height in
				
				// hide and show buttons by alpha to make it animatable
				
				let alpha: CGFloat = height > 0.0 ? 1.0 : 0.0
				let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut) { [weak self] in
					guard let self = self else {
						return
					}
					self.primaryButton.alpha = alpha
					self.secondaryButton.alpha = alpha
				}
				animator.startAnimation()
			}
			.store(in: &subscription)

		// update loading indicators on model change

		viewModel.$isPrimaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isLoading, on: primaryButton)
			.store(in: &subscription)

		viewModel.$isSecondaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isLoading, on: secondaryButton)
			.store(in: &subscription)

		// update enabled state on model change

		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isEnabled, on: primaryButton)
			.store(in: &subscription)

		viewModel.$isSecondaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isEnabled, on: secondaryButton)
			.store(in: &subscription)

		// update hidden state on model change

		viewModel.$isPrimaryButtonHidden
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: primaryButton)
			.store(in: &subscription)

		viewModel.$isSecondaryButtonHidden
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: secondaryButton)
			.store(in: &subscription)

		viewModel.$backgroundColor
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.backgroundColor, on: view)
			.store(in: &subscription)
	}
}
