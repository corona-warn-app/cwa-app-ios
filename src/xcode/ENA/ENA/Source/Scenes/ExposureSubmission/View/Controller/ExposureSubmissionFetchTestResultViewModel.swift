//
// 🦠 Corona-Warn-App
//
//  ExposureSubmissionFetchTestResultViewModel.swift

import Foundation
import UIKit
//import Combine

class ExposureSubmissionFetchTestResultViewModel {

	// MARK: - Init
	
	init(
		onQRCodeButtonTap: @escaping () -> Void,
		onTANButtonTap: @escaping () -> Void,
		onHotlineButtonTap: @escaping () -> Void
	) {
		self.onQRCodeButtonTap = onQRCodeButtonTap
		self.onTANButtonTap = onTANButtonTap
		self.onHotlineButtonTap = onHotlineButtonTap
	}
	
	let onQRCodeButtonTap: () -> Void
	let onTANButtonTap: () -> Void
	let onHotlineButtonTap: () -> Void
		
	
//	var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	var dynamicTableData: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(DynamicSection.section(cells: [
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription,
					image: UIImage(named: "Illu_Submission_QRCode"),
					action: .execute { [weak self] _ in self?.onQRCodeButtonTap() },
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.qrCodeButtonDescription
				),
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
					description: AppStrings.ExposureSubmissionDispatch.tanButtonDescription,
					image: UIImage(named: "Illu_Submission_TAN"),
					action: .execute { [weak self] _ in self?.onTANButtonTap() },
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription
				),
				.imageCard(
					title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
					attributedDescription: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription.inserting(emphasizedString: AppStrings.ExposureSubmissionDispatch.positiveWord),
					image: UIImage(named: "Illu_Submission_Anruf"),
					action: .execute { [weak self] _ in self?.onHotlineButtonTap() },
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
		action: DynamicAction,
		accessibilityIdentifier: String? = nil) -> Self {
		.identifier(ExposureSubmissionOverviewViewController.CustomCellReuseIdentifiers.imageCard, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionImageCardCell else { return }
			cell.configure(
				title: title,
				description: description ?? "",
				attributedDescription: attributedDescription,
				image: image,
				accessibilityIdentifier: accessibilityIdentifier)
		}
	}
}
