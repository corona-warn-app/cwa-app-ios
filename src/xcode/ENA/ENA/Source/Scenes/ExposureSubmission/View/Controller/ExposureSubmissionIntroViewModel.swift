//
// 🦠 Corona-Warn-App
//
//  ExposureSubmissionIntroViewModel.swift

import Foundation
import UIKit
import OpenCombine

class ExposureSubmissionIntroViewModel {

	// MARK: - Init
	
	init(
		onQRCodeButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onFindTestCentersTap: @escaping () -> Void,
		onTANButtonTap: @escaping () -> Void,
		onHotlineButtonTap: @escaping () -> Void,
		onRapidTestProfileTap: @escaping () -> Void,
		antigenTestProfileStore: AntigenTestProfileStoring
	) {
		self.onQRCodeButtonTap = onQRCodeButtonTap
		self.onFindTestCentersTap = onFindTestCentersTap
		self.onTANButtonTap = onTANButtonTap
		self.onHotlineButtonTap = onHotlineButtonTap
		self.onRapidTestProfileTap = onRapidTestProfileTap
		self.antigenTestProfileStore = antigenTestProfileStore
	}
	
	// MARK: - Internal
	
	let onQRCodeButtonTap: (@escaping (Bool) -> Void) -> Void
	let onFindTestCentersTap: () -> Void
	let onTANButtonTap: () -> Void
	let onHotlineButtonTap: () -> Void
	let onRapidTestProfileTap: () -> Void
	let antigenTestProfileStore: AntigenTestProfileStoring

	// MARK: - Private

	var dynamicTableModel: DynamicTableViewModel {
		let profileCell: DynamicCell

		let gradientView = GradientView()
		gradientView.type = .blueOnly

		profileCell = DynamicCell.imageCard(
			title: AppStrings.ExposureSubmission.AntigenTest.Profile.profileTile_Title,
			description: AppStrings.ExposureSubmission.AntigenTest.Profile.profileTile_Description,
			image: UIImage(named: "Illu_Submission_AntigenTest_Profile"),
			backgroundView: gradientView,
			textColor: .enaColor(for: .textContrast),
			action: .execute { [weak self] _, _ in
				self?.onRapidTestProfileTap()
			},
			accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description,
			tag: "AntigenTestProfileCard" // Used for unit testing.
		)

		return DynamicTableViewModel.with {
			$0.add(.section(
				header: .image(
					UIImage(named: "Illu_Test_registration"),
					accessibilityLabel: AppStrings.ExposureSubmissionDispatch.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.General.image,
					height: 200
				),
				separators: .none,
				cells: []
			))
			$0.add(.section(cells: [
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription,
					image: UIImage(named: "Illu_Submission_QRCode"),
					action: .execute { [weak self] _, cell in
						self?.onQRCodeButtonTap { isLoading in
							// Disable repeated tapping again while country list is loading
							cell?.isUserInteractionEnabled = !isLoading
						}
					},
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.qrCodeButtonDescription
				),
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.findTestCentersButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.findTestCentersButtonDescription,
					image: UIImage(named: "Illu_Submission_Test_Centers"),
					action: .execute { [weak self] _, _ in self?.onFindTestCentersTap() },
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.findTestCentersButtonDescription
				),
				profileCell,
				.title2(
					text: AppStrings.ExposureSubmissionDispatch.sectionHeadline2,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.sectionHeadline2
				),
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.tanButtonDescription,
					image: UIImage(named: "Illu_Submission_TAN"),
					action: .execute { [weak self] _, _ in self?.onTANButtonTap() },
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription
				),
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription,
					image: UIImage(named: "Illu_Submission_Anruf"),
					action: .execute { [weak self] _, _ in self?.onHotlineButtonTap() },
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.hotlineButtonDescription
				)
			]))
		}
	}
}

private extension DynamicCell {
	static func imageCard(
		title: String,
		description: String? = nil,
		attributedDescription: NSAttributedString? = nil,
		image: UIImage?,
		imageLayout: ExposureSubmissionImageCardCell.ImageLayout = .right,
		backgroundView: UIView? = nil,
		textColor: UIColor? = nil,
		action: DynamicAction,
		accessibilityIdentifier: String? = nil,
		tag: String? = nil) -> Self {

		.identifier(
			ExposureSubmissionIntroViewController.CustomCellReuseIdentifiers.imageCard,
			action: action,
			tag: tag,
			configure: { _, cell, _ in
				guard let cell = cell as? ExposureSubmissionImageCardCell else { return }
				cell.configure(
					title: title,
					description: description ?? "",
					attributedDescription: attributedDescription,
					image: image,
					imageLayout: imageLayout,
					backgroundView: backgroundView,
					textColor: textColor,
					accessibilityIdentifier: accessibilityIdentifier
				)
			}
		)
	}
}
