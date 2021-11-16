//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import PDFKit

enum ParentingViewController {
	case push(UINavigationController)
	case present(UIViewController)
}

// swiftlint:disable type_body_length

final class HealthCertificateCoordinator {
	
	// MARK: - Init
	
	init(
		parentingViewController: ParentingViewController,
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		markAsSeenOnDisappearance: Bool
	) {
		self.parentingViewController = parentingViewController
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificate = healthCertificate
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		self.markAsSeenOnDisappearance = markAsSeenOnDisappearance

		#if DEBUG
		if isUITesting {
			store.healthCertificateInfoScreenShown = LaunchArguments.infoScreen.healthCertificateInfoScreenShown.boolValue
		}
		#endif
	}
	
	// MARK: - Internal

	lazy var rootNavigationController: UINavigationController = {
		if !infoScreenShown {
			return UINavigationController(
				rootViewController: infoScreen(
					hidesCloseButton: true,
					dismissAction: { [weak self] in
						guard let self = self else {
							Log.error("Could not create self reference")
							return
						}

						self.navigationController.pushViewController(self.healthCertificateViewController, animated: true)
						// Set CertificateViewController as the only controller on the navigation stack to avoid back gesture etc.
						self.navigationController.setViewControllers([self.healthCertificateViewController], animated: false)

						self.infoScreenShown = true
					},
					showDetail: { detailViewController in
						self.navigationController.pushViewController(detailViewController, animated: true)
					}
				)
			)
		} else {
			return DismissHandlingNavigationController(rootViewController: healthCertificateViewController)
		}
	}()
	
	func start() {
		switch parentingViewController {
		case let .push(navController):
			navigationController = navController
			// for push we know the consent screen was already shown so we can push directly the healthCertificateViewController
			navController.pushViewController(healthCertificateViewController, animated: true)
		case let .present(viewController):
			navigationController = rootNavigationController
			viewController.present(navigationController, animated: true)
		}
	}
	
	// MARK: - Private
	
	private let parentingViewController: ParentingViewController
	private let store: HealthCertificateStoring
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificate: HealthCertificate
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding

	private let markAsSeenOnDisappearance: Bool
	
	private var navigationController: UINavigationController!
	private var printNavigationController: UINavigationController!
	private var validationCoordinator: HealthCertificateValidationCoordinator?
	
	private var infoScreenShown: Bool {
		get { store.healthCertificateInfoScreenShown }
		set { store.healthCertificateInfoScreenShown = newValue }
	}
	
	private lazy var healthCertificateViewController: TopBottomContainerViewController<HealthCertificateViewController, FooterViewController> = {
		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.HealthCertificate.Details.validationButtonTitle,
			secondaryButtonName: AppStrings.HealthCertificate.Details.moreButtonTitle,
			isPrimaryButtonEnabled: true,
			isSecondaryButtonEnabled: true,
			isSecondaryButtonHidden: false,
			primaryButtonInverted: false,
			secondaryButtonInverted: true,
			backgroundColor: .enaColor(for: .cellBackground)
		)

		let footerViewController = FooterViewController(footerViewModel)

		let healthCertificateViewController = HealthCertificateViewController(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: markAsSeenOnDisappearance,
			dismiss: {
				self.navigationController.dismiss(animated: true)
			},
			didTapValidationButton: { [weak self] in
				guard let self = self else {
					Log.error("Could not create self reference")
					return
				}
				
				footerViewModel.setLoadingIndicator(true, disable: true, button: .primary)
				footerViewModel.setLoadingIndicator(false, disable: true, button: .secondary)

				self.healthCertificateValidationOnboardedCountriesProvider.onboardedCountries { result in
					footerViewModel.setLoadingIndicator(false, disable: false, button: .primary)
					footerViewModel.setLoadingIndicator(false, disable: false, button: .secondary)

					switch result {
					case .success(let countries):
						self.showValidationFlow(
							healthCertificate: self.healthCertificate,
							countries: countries
						)
					case .failure(let error):
						self.showErrorAlert(
							title: AppStrings.HealthCertificate.Validation.Error.title,
							error: error,
							from: self.navigationController
						)
					}
				}
			},
			didTapMoreButton: { [weak self] in
				guard let self = self else {
					Log.error("Could not create self reference")
					return
				}
				self.showActionSheet(
					healthCertificate: self.healthCertificate,
					removeAction: { [weak self] in
						guard let self = self else {
							Log.error("Could not create self reference")
							return
						}
						// pass this as closure instead of passing several properties to showActionSheet().
						self.showDeleteAlert(
							certificateType: self.healthCertificate.type,
							submitAction: UIAlertAction(
								title: AppStrings.HealthCertificate.Alert.deleteButton,
								style: .destructive,
								handler: { _ in
									self.healthCertificateService.removeHealthCertificate(self.healthCertificate)

									switch self.parentingViewController {
									case .push(let navigationController):
										navigationController.popViewController(animated: true)
									case .present(let viewController):
										viewController.dismiss(animated: true)
									}
								}
							)
						)
					}
				)
			},
			showInfoHit: { [weak self] in
				self?.presentCovPassInfoScreen()
			}
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}()

	private func presentCovPassInfoScreen() {
		guard let presentViewController = navigationController else {
			Log.error("Failed to find present view controller")
			return
		}
		let covPassInformationViewController = CovPassCheckInformationViewController(
			onDismiss: {
				presentViewController.dismiss(animated: true)
			}
		)
		let navigationController = DismissHandlingNavigationController(rootViewController: covPassInformationViewController, transparent: true)
		presentViewController.present(navigationController, animated: true)
	}

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> TopBottomContainerViewController<HealthCertificateInfoViewController, FooterViewController> {
		let consentScreen = HealthCertificateInfoViewController(
			viewModel: HealthCertificateInfoViewModel(
				hidesCloseButton: hidesCloseButton,
				didTapDataPrivacy: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false

					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}

					showDetail(detailViewController)
				}
			),
			dismiss: dismissAction
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Info.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: consentScreen,
			bottomController: footerViewController
		)
		return topBottomContainerViewController
	}
	
	private func showActionSheet(
		healthCertificate: HealthCertificate,
		removeAction: @escaping () -> Void
	) {
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		let printAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.showVersion,
			style: .default,
			handler: { [weak self] _ in
				// Check first if the certificate is obtained in DE. If not, show error alert.
				guard healthCertificate.cborWebTokenHeader.issuer == "DE" else {
					self?.showPdfPrintErrorAlert()
					return
				}
				self?.showPdfGenerationInfo(
					healthCertificate: healthCertificate
				)
			}
		)
		printAction.isEnabled = healthCertificate.validityState != .blocked
		actionSheet.addAction(printAction)

		let deleteButtonTitle: String
		switch healthCertificate.type {
		case .vaccination:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.deleteButtonTitle
		case .test:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.TestCertificate.primaryButton
		case .recovery:
			deleteButtonTitle = AppStrings.HealthCertificate.Details.RecoveryCertificate.primaryButton
		}
		
		let removeAction = UIAlertAction(
			title: deleteButtonTitle,
			style: .destructive,
			handler: { _ in
				removeAction()
			}
		)
		actionSheet.addAction(removeAction)

		removeAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Certificate.deleteButton
		
		let cancelAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.cancel,
			style: .cancel,
			handler: nil
		)
		actionSheet.addAction(cancelAction)
		navigationController.present(actionSheet, animated: true, completion: nil)
	}
	
	private func showDeleteAlert(
		certificateType: HealthCertificate.CertificateType,
		submitAction: UIAlertAction
	) {
		let title: String
		let message: String

		switch certificateType {
		case .vaccination:
			title = AppStrings.HealthCertificate.Alert.VaccinationCertificate.title
			message = AppStrings.HealthCertificate.Alert.VaccinationCertificate.message
		case .test:
			title = AppStrings.HealthCertificate.Alert.TestCertificate.title
			message = AppStrings.HealthCertificate.Alert.TestCertificate.message
		case .recovery:
			title = AppStrings.HealthCertificate.Alert.RecoveryCertificate.title
			message = AppStrings.HealthCertificate.Alert.RecoveryCertificate.message
		}

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.cancelButton,
				style: .cancel,
				handler: nil
			)
		)

		alert.addAction(submitAction)
		submitAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Certificate.deletionConfirmationButton

		navigationController.present(alert, animated: true)
	}
	
	private func showErrorAlert(
		title: String,
		error: Error,
		from presentingViewController: UIViewController
	) {
		let alert = UIAlertController(
			title: title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)

		let okayAction = UIAlertAction(
			title: AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		alert.addAction(okayAction)
		DispatchQueue.main.async {
			presentingViewController.present(alert, animated: true)
		}
	}
	
	private func showPdfGenerationInfo(
		healthCertificate: HealthCertificate
	) {
		let healthCertificatePDFGenerationInfoViewController = HealthCertificatePDFGenerationInfoViewController(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			onTapContinue: { [weak self] pdfDocument in
				self?.showPdfGenerationResult(
					healthCertificate: healthCertificate,
					pdfDocument: pdfDocument
				)
			},
			onDismiss: { [weak self] in
				self?.navigationController.dismiss(animated: true)
			},
			showErrorAlert: { [weak self] error in
				guard let self = self else { return }
				
				self.showErrorAlert(
					title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.fetchValueSets.title,
					error: error,
					from: self.printNavigationController
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.PrintPDF.Info.primaryButton,
				primaryIdentifier: AccessibilityIdentifiers.HealthCertificate.PrintPdf.infoPrimaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificatePDFGenerationInfoViewController,
			bottomController: footerViewController
		)
		
		printNavigationController = DismissHandlingNavigationController(
			rootViewController: topBottomContainerViewController,
			transparent: true
		)
		navigationController.present(printNavigationController, animated: true)
	}
	
	private func showPdfGenerationResult(
		healthCertificate: HealthCertificate,
		pdfDocument: PDFDocument
	) {
		let healthCertificatePDFVersionViewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: healthCertificate,
			pdfDocument: pdfDocument
		)
		
		let healthCertificatePDFVersionViewController = HealthCertificatePDFVersionViewController(
			viewModel: healthCertificatePDFVersionViewModel,
			onTapPrintPdf: printPdf,
			onTapExportPdf: exportPdf
		)
		// The call of showPdfGenerationResult is made possibly in the background while generating the pdfDocument
		DispatchQueue.main.async { [weak self] in
			self?.printNavigationController.pushViewController(healthCertificatePDFVersionViewController, animated: true)
		}
	}
	
	private func printPdf(
		pdfData: Data
	) {
		let printController = UIPrintInteractionController.shared
		printController.printingItem = pdfData
		printController.present(animated: true, completionHandler: nil)
	}
	
	private func exportPdf(
		exportItem: PDFExportItem
	) {
		let activityViewController = UIActivityViewController(activityItems: [exportItem], applicationActivities: nil)
		printNavigationController.present(activityViewController, animated: true, completion: nil)
	}
	
	private func showPdfPrintErrorAlert() {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.title,
			message: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.message,
			preferredStyle: .alert
		)
		
		let faqAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.faq,
			style: .default,
			handler: { _ in
				LinkHelper.open(urlString: AppStrings.Links.healthCertificatePrintFAQ)
			}
		)
		faqAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.faqAction
		alert.addAction(faqAction)
		
		let okayAction = UIAlertAction(
			title: AppStrings.HealthCertificate.PrintPDF.ErrorAlert.pdfGeneration.ok,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)
		okayAction.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.okAction
		alert.addAction(okayAction)

		navigationController.present(alert, animated: true, completion: nil)
	}
	
	private func showValidationFlow(
		healthCertificate: HealthCertificate,
		countries: [Country]
	) {
		validationCoordinator = HealthCertificateValidationCoordinator(
			parentViewController: navigationController,
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			healthCertificateValidationService: healthCertificateValidationService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

		validationCoordinator?.start()
	}


}
