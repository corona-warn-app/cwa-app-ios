//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIImage
import OpenCombine
import HealthCertificateToolkit
import class CertLogic.ValidationResult

final class ValidationResultCellModel {

	// MARK: - Init

	init(
		validationResult: ValidationResult,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.validationResult = validationResult
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		updateKeyValuePairs()

		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							Log.error("Signature verification error.", log: .vaccination, error: error)
						}
						Log.error("Could not fetch Vaccination value sets protobuf.", log: .vaccination, error: error)
					}
				}, receiveValue: { [weak self] valueSets in
					self?.valueSets = valueSets
					self?.updateKeyValuePairs()
				}
			)
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	var iconImage: UIImage? {
		switch validationResult.result {
		case .fail:
			return UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")
		case .open:
			return UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Open")
		case .passed:
			return nil
		}
	}

	var ruleDescription: String? {
		let localizedDescription = validationResult.rule?.description.first(where: { $0.lang.lowercased() == Locale.current.languageCode?.lowercased() })?.desc
		let englishDescription = validationResult.rule?.description.first(where: { $0.lang.lowercased() == "en" })?.desc
		let firstDescription = validationResult.rule?.description.first?.desc

		return localizedDescription ?? englishDescription ?? firstDescription ?? ruleIdentifier
	}

	var ruleTypeDescription: String? {
		switch validationResult.rule?.ruleType {
		case .acceptence:
			let arrivalCountry = (validationResult.rule?.countryCode).flatMap { Country(withCountryCodeFallback: $0) }

			return String(
				format: AppStrings.HealthCertificate.Validation.Result.acceptanceRule,
				arrivalCountry?.localizedName ?? ""
			)
		case .invalidation:
			return AppStrings.HealthCertificate.Validation.Result.invalidationRule
		case .none:
			return nil
		}
	}

	var keyValueAttributedString: NSAttributedString {
		keyValuePairs.map { (key: String, value: String?) -> NSAttributedString in
			NSAttributedString(attributedString: [keyFormatterAttributedString(key: key), valueFormatterAttributedString(value: value)].joined(with: "\n"))
		}.joined(with: "\n")
	}

	@DidSetPublished var keyValuePairs = [(key: String, value: String?)]()

	// MARK: - Private

	private let validationResult: ValidationResult
	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding

	private let vaccinationEntryKeyPaths: [String: PartialKeyPath<VaccinationEntry>] = [
		"v.0.tg": \VaccinationEntry.diseaseOrAgentTargeted,
		"v.0.vp": \VaccinationEntry.vaccineOrProphylaxis,
		"v.0.mp": \VaccinationEntry.vaccineMedicinalProduct,
		"v.0.ma": \VaccinationEntry.marketingAuthorizationHolder,
		"v.0.dn": \VaccinationEntry.doseNumber,
		"v.0.sd": \VaccinationEntry.totalSeriesOfDoses,
		"v.0.dt": \VaccinationEntry.dateOfVaccination,
		"v.0.co": \VaccinationEntry.countryOfVaccination,
		"v.0.is": \VaccinationEntry.certificateIssuer,
		"v.0.ci": \VaccinationEntry.uniqueCertificateIdentifier
	]

	private let testEntryKeyPaths: [String: PartialKeyPath<TestEntry>] = [
		"t.0.tg": \TestEntry.diseaseOrAgentTargeted,
		"t.0.tt": \TestEntry.typeOfTest,
		"t.0.nm": \TestEntry.naaTestName,
		"t.0.ma": \TestEntry.ratTestName,
		"t.0.sc": \TestEntry.sampleCollectionDate,
		"t.0.tr": \TestEntry.testResult,
		"t.0.tc": \TestEntry.testCenter,
		"t.0.co": \TestEntry.countryOfTest,
		"t.0.is": \TestEntry.certificateIssuer,
		"t.0.ci": \TestEntry.uniqueCertificateIdentifier
	]

	private let recoveryEntryKeyPaths: [String: PartialKeyPath<RecoveryEntry>] = [
		"r.0.tg": \RecoveryEntry.diseaseOrAgentTargeted,
		"r.0.fr": \RecoveryEntry.dateOfFirstPositiveNAAResult,
		"r.0.co": \RecoveryEntry.countryOfTest,
		"r.0.is": \RecoveryEntry.certificateIssuer,
		"r.0.df": \RecoveryEntry.certificateValidFrom,
		"r.0.du": \RecoveryEntry.certificateValidUntil,
		"r.0.ci": \RecoveryEntry.uniqueCertificateIdentifier
	]

	private var valueSets: SAP_Internal_Dgc_ValueSets?
	private var subscriptions = Set<AnyCancellable>()

	private var ruleIdentifier: String? {
		validationResult.rule?.identifier
	}

	private var ruleIdentifierWithVersion: String? {
		guard let rule = validationResult.rule else {
			return nil
		}

		return "\(rule.identifier) (\(rule.version))"
	}

	private func updateKeyValuePairs() {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			updateKeyValuePairs(vaccinationEntry: vaccinationEntry)
		case .test(let testEntry):
			updateKeyValuePairs(testEntry: testEntry)
		case .recovery(let recoveryEntry):
			updateKeyValuePairs(recoveryEntry: recoveryEntry)
		}
	}

	private func keyFormatterAttributedString(key: String) -> NSAttributedString {
		let spaceParagraphStyle = NSMutableParagraphStyle()
		spaceParagraphStyle.paragraphSpacingBefore = 16.0
		spaceParagraphStyle.lineHeightMultiple = 0.8
		return NSAttributedString(
			string: key,
			attributes: [
				.font: UIFont.enaFont(for: .footnote) ,
				.foregroundColor: UIColor.enaColor(for: .textPrimary2),
				.paragraphStyle: spaceParagraphStyle
			]
		)
	}

	private func valueFormatterAttributedString(value: String?) -> NSAttributedString {
		return NSAttributedString(
			string: value ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .subheadline) ,
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)
	}

	private func updateKeyValuePairs(vaccinationEntry: VaccinationEntry) {
		var keyValuePairs = [(key: String, value: String?)]()

		validationResult.rule?.affectedString.forEach {
			if let keyPath = vaccinationEntryKeyPaths[$0],
			   let title = vaccinationEntry.title(for: keyPath) {
				let formattedValue = vaccinationEntry.formattedValue(for: keyPath, valueSets: valueSets) ?? ""
				keyValuePairs.append((key: title, value: formattedValue))
			}
		}

		keyValuePairs.append((key: "Regel-ID / Rule ID", value: ruleIdentifierWithVersion))

		self.keyValuePairs = keyValuePairs
	}

	private func updateKeyValuePairs(testEntry: TestEntry) {
		var keyValuePairs = [(key: String, value: String?)]()

		validationResult.rule?.affectedString.forEach {
			if let keyPath = testEntryKeyPaths[$0],
			   let title = testEntry.title(for: keyPath) {
				let formattedValue = testEntry.formattedValue(for: keyPath, valueSets: valueSets) ?? ""
				keyValuePairs.append((key: title, value: formattedValue))
			}
		}

		keyValuePairs.append((key: "Regel-ID / Rule ID", value: ruleIdentifierWithVersion))

		self.keyValuePairs = keyValuePairs
	}

	private func updateKeyValuePairs(recoveryEntry: RecoveryEntry) {
		var keyValuePairs = [(key: String, value: String?)]()

		validationResult.rule?.affectedString.forEach {
			if let keyPath = recoveryEntryKeyPaths[$0],
			   let title = recoveryEntry.title(for: keyPath) {
				let formattedValue = recoveryEntry.formattedValue(for: keyPath, valueSets: valueSets) ?? ""
				keyValuePairs.append((key: title, value: formattedValue))
			}
		}

		keyValuePairs.append((key: "Regel-ID / Rule ID", value: ruleIdentifierWithVersion))

		self.keyValuePairs = keyValuePairs
	}

}
