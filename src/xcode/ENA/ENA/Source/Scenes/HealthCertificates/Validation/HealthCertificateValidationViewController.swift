//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateValidationViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		countries: [Country],
		store: HealthCertificateStoring,
		onValidationButtonTap: @escaping (Country, Date) -> Void,
		onDisclaimerButtonTap: @escaping () -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onInfoButtonTap = onInfoButtonTap
		self.onDismiss = onDismiss

		self.viewModel = HealthCertificateValidationViewModel(
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			onValidationButtonTap: onValidationButtonTap,
			onDisclaimerButtonTap: onDisclaimerButtonTap,
			onInfoButtonTap: onInfoButtonTap
		)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton(.normal)]
		parent?.navigationItem.title = AppStrings.HealthCertificate.Validation.title

		setupTableView()
		setupKeyboardAvoidance()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else { return }

		viewModel.validate()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let onInfoButtonTap: () -> Void
	private let onDismiss: () -> Void
	private let viewModel: HealthCertificateValidationViewModel
	private var subscriptions = Set<AnyCancellable>()

	@IBAction private func infoButtonTapped() {
		onInfoButtonTap()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.register(
			CountrySelectionCell.self,
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.countrySelectionCell.rawValue
		)

		tableView.register(
			ValidationDateSelectionCell.self,
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.validationDateSelectionCell.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.legalDetails.rawValue
		)
	}

	private func setupKeyboardAvoidance() {
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillShowNotification)
			.append(NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillChangeFrameNotification))
			.sink { [weak self] notification in

				guard let self = self,
					  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
					  let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) else {
					return
				}

				var targetRect: CGRect?
				if let currentResponder = self.view.firstResponder as? UIView {
					let rect = currentResponder.convert(currentResponder.bounds, to: self.view)
					if keyboardFrame.intersects(rect) {
						targetRect = rect
					}
				}

				let animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) { [weak self] in
					self?.tableView.scrollIndicatorInsets.bottom = keyboardFrame.height
					self?.tableView.contentInset.bottom = keyboardFrame.height
					if let targetRect = targetRect {
						self?.tableView.scrollRectToVisible(targetRect, animated: false)
					}
				}
				animator.startAnimation()
			}
			.store(in: &subscriptions)

		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillHideNotification)
			.sink { [weak self] notification in

				guard let self = self,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
					  let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) else {
					return
				}

				let animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) { [weak self] in
					self?.tableView.scrollIndicatorInsets.bottom = 0
					self?.tableView.contentInset.bottom = 0
				}
				animator.startAnimation()
			}
			.store(in: &subscriptions)
	}

}
