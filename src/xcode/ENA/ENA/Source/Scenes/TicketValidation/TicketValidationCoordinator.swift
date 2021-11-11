//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TicketValidationCoordinator {
	
	// MARK: - Init
	
	init(
		parentViewController: UIViewController
	) {
		self.parentViewController = parentViewController
	}
	
	// MARK: - Internal

	func start(initializationData: TicketValidationInitializationData) {
		navigationController = DismissHandlingNavigationController(
			rootViewController: firstConsentScreen(
				initializationData: initializationData
			),
			transparent: true
		)
		parentViewController.present(navigationController, animated: true)
	}
	
	// MARK: - Private
	
	private weak var parentViewController: UIViewController!
	private var navigationController: UINavigationController!
	
	private func firstConsentScreen(
		initializationData: TicketValidationInitializationData
	) -> UIViewController {
		let firstConsentViewController = FirstTicketValidationConsentViewController(
			viewModel: FirstTicketValidationConsentViewModel(
				initializationData: initializationData,
				onDataPrivacyTap: {
					self.showDataPrivacy()
				}
			),
			onPrimaryButtonTap: {

			},
			onDismiss: {
				self.showDismissAlert()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TicketValidation.FirstConsent.primaryButtonTitle,
				secondaryButtonName: AppStrings.TicketValidation.FirstConsent.secondaryButtonTitle,
				isSecondaryButtonEnabled: true,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: firstConsentViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}

	private func showDataPrivacy() {
		let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
		detailViewController.title = AppStrings.AppInformation.privacyTitle
		detailViewController.isDismissable = false
		if #available(iOS 13.0, *) {
			detailViewController.isModalInPresentation = true
		}

		navigationController.pushViewController(detailViewController, animated: true)
	}

	private func showDismissAlert() {

	}

}
