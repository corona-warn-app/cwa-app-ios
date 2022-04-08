//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class FamilyMemberCoronaTestCellModel {

	// MARK: - Init

	init(
		coronaTest: FamilyMemberCoronaTest,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		appConfigurationProvider: AppConfigurationProviding,
		onUpdate: @escaping () -> Void
	) {
		self.coronaTest = coronaTest
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.appConfigurationProvider = appConfigurationProvider
		self.onUpdate = onUpdate

		setup()
	}

	// MARK: - Internal

	@OpenCombine.Published var name: String! = ""
	@OpenCombine.Published var caption: String! = ""
	@OpenCombine.Published var topDiagnosis: String! = ""
	@OpenCombine.Published var bottomDiagnosis: String?
	@OpenCombine.Published var bottomDiagnosisColor: UIColor?
	@OpenCombine.Published var description: String?
	@OpenCombine.Published var footnote: String?
	@OpenCombine.Published var buttonTitle: String?
	@OpenCombine.Published var image: UIImage?
	@OpenCombine.Published var isUnseenNewsIndicatorHidden: Bool = true
	@OpenCombine.Published var isDisclosureIndicatorHidden: Bool = false
	@OpenCombine.Published var isUserInteractionEnabled: Bool = false
	@OpenCombine.Published var isCellTappable: Bool = true
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.TestResultCell.unconfiguredButton

	var coronaTest: FamilyMemberCoronaTest

	// MARK: - Private

	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private let appConfigurationProvider: AppConfigurationProviding
	private let onUpdate: () -> Void

	private var isConfigured = false
	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		familyMemberCoronaTestService.coronaTests
			.sink { [weak self] _ in
				guard let self = self, let updatedCoronaTest = self.familyMemberCoronaTestService.upToDateTest(for: self.coronaTest) else {
					return
				}

				if !self.isConfigured || updatedCoronaTest != self.coronaTest {
					self.coronaTest = updatedCoronaTest
					self.configure()
					self.onUpdate()
				}
			}
			.store(in: &subscriptions)
	}

	private func configure() {
		name = coronaTest.displayName
		isUnseenNewsIndicatorHidden = !coronaTest.hasUnseenNews

		switch coronaTest.type {
		case .pcr:
			caption = AppStrings.FamilyMemberCoronaTest.pcrCaption
		case .antigen:
			caption = AppStrings.FamilyMemberCoronaTest.antigenCaption
		}

		guard !coronaTest.isOutdated else {
			configureTestResultOutdated()
			return
		}

		switch coronaTest.testResult {
		case .invalid: configureTestResultInvalid()
		case .pending: configureTestResultPending()
		case .negative: configureTestResultNegative()
		case .positive: configureTestResultPositive()
		case .expired: configureTestResultExpired()
		}

		isConfigured = true
	}

	private func configureTestResultPending() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.pendingDiagnosis
		bottomDiagnosis = nil
		bottomDiagnosisColor = nil

		switch coronaTest.type {
		case .pcr:
			description = AppStrings.FamilyMemberCoronaTest.pendingPCRDescription
		case .antigen:
			description = AppStrings.FamilyMemberCoronaTest.pendingAntigenDescription
		}

		footnote = formattedFootnote
		buttonTitle = nil
		image = UIImage(named: "FamilyMember_CoronaTest_pending")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.pendingPCR
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.pendingAntigen
		}
	}

	private func configureTestResultNegative() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.negativeTopDiagnosis
		bottomDiagnosis = AppStrings.FamilyMemberCoronaTest.negativeBottomDiagnosis
		bottomDiagnosisColor = .enaColor(for: .riskLow)
		description = nil
		footnote = formattedFootnote
		buttonTitle = nil
		image = UIImage(named: "FamilyMember_CoronaTest_negative")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.negativePCR
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.negativeAntigen
		}
	}

	private func configureTestResultInvalid() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.invalidDiagnosis
		bottomDiagnosis = nil
		bottomDiagnosisColor = nil
		description = AppStrings.FamilyMemberCoronaTest.invalidDescription
		footnote = nil
		buttonTitle = nil
		image = UIImage(named: "FamilyMember_CoronaTest_invalid_expired")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.invalidPCR
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.invalidAntigen
		}
	}

	private func configureTestResultPositive() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.positiveTopDiagnosis
		bottomDiagnosis = AppStrings.FamilyMemberCoronaTest.positiveBottomDiagnosis
		bottomDiagnosisColor = .enaColor(for: .riskHigh)
		description = nil
		footnote = formattedFootnote
		buttonTitle = nil
		image = UIImage(named: "FamilyMember_CoronaTest_positive")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.positivePCR
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.positiveAntigen
		}
	}

	private func configureTestResultExpired() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.expiredDiagnosis
		bottomDiagnosis = nil
		bottomDiagnosisColor = nil
		description = AppStrings.FamilyMemberCoronaTest.expiredDescription
		footnote = nil
		buttonTitle = AppStrings.FamilyMemberCoronaTest.expiredButtonTitle
		image = UIImage(named: "FamilyMember_CoronaTest_invalid_expired")
		isDisclosureIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.expiredPCR
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.expiredAntigen
		}
	}

	private func configureTestResultOutdated() {
		topDiagnosis = AppStrings.FamilyMemberCoronaTest.outdatedDiagnosis
		bottomDiagnosis = nil
		bottomDiagnosisColor = nil
		description = String(
			format: AppStrings.FamilyMemberCoronaTest.outdatedDescription,
			appConfigurationProvider.currentAppConfig.value.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated
		)
		footnote = nil
		buttonTitle = AppStrings.FamilyMemberCoronaTest.outdatedButtonTitle
		image = UIImage(named: "FamilyMember_CoronaTest_outdated")
		isDisclosureIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false
		accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.outdatedAntigen
	}

	private var formattedFootnote: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		let dateTemplate: String
		switch coronaTest.type {
		case .pcr:
			dateTemplate = AppStrings.FamilyMemberCoronaTest.pcrDate
		case .antigen:
			dateTemplate = AppStrings.FamilyMemberCoronaTest.antigenDate
		}

		let formattedTestDate = dateFormatter.string(from: coronaTest.testDate)

		return String(format: dateTemplate, formattedTestDate)
	}

}
