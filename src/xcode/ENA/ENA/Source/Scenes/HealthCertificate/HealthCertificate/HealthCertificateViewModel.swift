////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		healthCertifiedPerson.$proofCertificate
			.sink { [weak self] proofCertificate in
				self?.gradientType = proofCertificate != nil ? .blueOnly : .solidGrey
			}
			.store(in: &subscriptions)

		// load certificate value sets
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
				}, receiveValue: { [weak self] valueSet in
//					self?.valueSet = valueSet
				}
			)
			.store(in: &subscriptions)

	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case headline
		case topCorner
		case details
		case bottomCorner

		static var numberOfSections: Int {
			allCases.count
		}

		static func map(_ section: Int) -> TableViewSection {
			guard let section = TableViewSection(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}

	let headlineCellViewModel: HealthCertificateSimpleTextCellViewModel = {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center

		let attributedName = NSAttributedString(
			string: "Impfung 1 von 2",
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		let attributedDetails = NSAttributedString(
			string: "Impfzertifikat",
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textAlignment: .center,
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText
		)
	}()

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .details:
			return values.count
		default:
			return 1
		}
	}

	func healthCertificateKeyValueCellViewModel(row: Int) -> HealthCertificateKeyValueCellViewModel {
		let model = values[row]
		return HealthCertificateKeyValueCellViewModel(model)
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider

	private(set) var valueSets: SAP_Internal_Dgc_ValueSets?

	private var subscriptions = Set<AnyCancellable>()

	// remove later if we have correct data
	struct DummyModel {
		let key: String
		let value: String
	}

	private let values = [
		DummyModel(key: "Andrea Schneider", value: "geboren 18.04.1943"),
		DummyModel(key: "Datum der Impfung", value: "12.04.2021"),
		DummyModel(key: "Impfstoff", value: "ID123")
	]

}
