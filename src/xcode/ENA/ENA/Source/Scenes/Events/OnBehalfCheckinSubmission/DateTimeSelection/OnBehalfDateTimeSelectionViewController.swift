//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfDateTimeSelectionViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		onPrimaryButtonTap: @escaping (Checkin) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss

		self.viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: traceLocation,
			onPrimaryButtonTap: onPrimaryButtonTap
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
		parent?.navigationItem.title = AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.title

		setupTableView()
		setupKeyboardAvoidance()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else { return }

		viewModel.createCheckin()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let onDismiss: () -> Void

	private let viewModel: OnBehalfDateTimeSelectionViewModel
	private var subscriptions = Set<AnyCancellable>()

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: EventTableViewCell.reuseIdentifier
		)

		tableView.register(
			OnBehalfDateSelectionCell.self,
			forCellReuseIdentifier: OnBehalfDateSelectionCell.reuseIdentifier
		)

		tableView.register(
			OnBehalfDurationSelectionCell.self,
			forCellReuseIdentifier: OnBehalfDurationSelectionCell.reuseIdentifier
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
