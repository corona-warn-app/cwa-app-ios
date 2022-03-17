//
// 🦠 Corona-Warn-App
//

import PDFKit
import HealthCertificateToolkit

extension HealthCertificate {

	enum PDFGenerationError: Error {
		case qrCodeCreationFailed
		case pdfDocumentCreationFailed
	}

	// MARK: - Internal

	func pdfDocument(with valueSets: SAP_Internal_Dgc_ValueSets, from bundle: Bundle = Bundle.main) throws -> PDFDocument {

		guard let dataProvider = CGDataProvider(data: pdfTemplate(from: bundle) as CFData), let originalDocument = CGPDFDocument(dataProvider) else {
			throw PDFGenerationError.pdfDocumentCreationFailed
		}

		guard let image = CIImage.qrCode(
			with: base45,
			encoding: .utf8,
			size: CGSize(width: 1000, height: 1000),
			scale: 1,
			qrCodeErrorCorrectionLevel: .medium
		) else {
			throw PDFGenerationError.qrCodeCreationFailed
		}

		do {
			let pdfDocument = try originalDocument.pdfDocumentEmbeddingImageAndText(
				image: image,
				at: CGRect(x: 132, y: 436, width: 150, height: 150),
				texts: texts(with: valueSets)
			)

			return pdfDocument
		} catch {
			throw PDFGenerationError.pdfDocumentCreationFailed
		}
	}
	
	// MARK: - Private

	private func pdfTemplate(from bundle: Bundle) -> Data {
		let templateName: String
		switch type {
		case .vaccination:
			templateName = "VaccinationCertificateTemplate_v4.1"
		case .test:
			templateName = "TestCertificateTemplate_v4.1"
		case .recovery:
			templateName = "RecoveryCertificateTemplate_v4.1"
		}

		guard let templateURL = bundle.url(forResource: templateName, withExtension: "pdf"),
			  let templateData = FileManager.default.contents(atPath: templateURL.path) else {
			fatalError("Could not load pdf template.")
		}

		return templateData
	}

	private func texts(with valueSets: SAP_Internal_Dgc_ValueSets) -> [PDFText] {
		switch entry {
		case .vaccination(let entry):
			return vaccinationTexts(for: entry, with: valueSets)
		case .test(let entry):
			return testTexts(for: entry, with: valueSets)
		case .recovery(let entry):
			return recoveryTexts(for: entry, with: valueSets)
		}
	}

	private func vaccinationTexts(for entry: VaccinationEntry, with valueSets: SAP_Internal_Dgc_ValueSets) -> [PDFText] {
		[
			PDFText(
				text: entry.certificateIssuer,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 30, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.countryOfVaccination,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 61, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.dateOfVaccination,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 93, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \VaccinationEntry.marketingAuthorizationHolder, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 173, width: 265, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \VaccinationEntry.vaccineMedicinalProduct, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 230, width: 265, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \VaccinationEntry.vaccineOrProphylaxis, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 303, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \VaccinationEntry.diseaseOrAgentTargeted, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 331, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: "\(entry.doseNumber)  \(entry.totalSeriesOfDoses)",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 141, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: name.reversedFullNameWithoutFallback,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 694, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: dateOfBirth,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 740, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: entry.uniqueCertificateIdentifier.removingURNPrefix(),
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 785, width: 266, height: 23),
				upsideDown: false
			)
		]
	}

	private func testTexts(for entry: TestEntry, with valueSets: SAP_Internal_Dgc_ValueSets) -> [PDFText] {
		[
			PDFText(
				text: entry.certificateIssuer,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 25, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.countryOfTest,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 52, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.testCenter ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 79, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \TestEntry.testResult, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 108, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.dateTimeOfSampleCollection,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 146, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \TestEntry.ratTestName, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 190, width: 276, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.naaTestName ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 238, width: 276, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \TestEntry.typeOfTest, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 305, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \TestEntry.diseaseOrAgentTargeted, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 333, width: 112, height: 23),
				upsideDown: true
			),
			PDFText(
				text: name.reversedFullNameWithoutFallback,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 694, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: dateOfBirth,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 740, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: entry.uniqueCertificateIdentifier.removingURNPrefix(),
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 785, width: 266, height: 23),
				upsideDown: false
			)
			
		]
	}

	private func recoveryTexts(for entry: RecoveryEntry, with valueSets: SAP_Internal_Dgc_ValueSets) -> [PDFText] {
		[
			PDFText(
				text: entry.certificateValidUntil,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 56, width: 125, height: 47),
				upsideDown: true
			),
			PDFText(
				text: entry.certificateValidFrom,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 118, width: 125, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.certificateIssuer,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 163, width: 125, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.countryOfTest,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 209, width: 125, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.dateOfFirstPositiveNAAResult,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 263, width: 125, height: 19),
				upsideDown: true
			),
			PDFText(
				text: entry.formattedValue(for: \RecoveryEntry.diseaseOrAgentTargeted, valueSets: valueSets) ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 14, y: 326, width: 125, height: 28),
				upsideDown: true
			),
			PDFText(
				text: name.reversedFullNameWithoutFallback,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 694, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: dateOfBirth,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 740, width: 266, height: 23),
				upsideDown: false
			),
			PDFText(
				text: entry.uniqueCertificateIdentifier.removingURNPrefix(),
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 785, width: 266, height: 23),
				upsideDown: false
			)
		]
	}

	private static var openSansFont: UIFont = {
		guard let font = UIFont(name: "OpenSans-Regular", size: 8) else {
			fatalError("Could not find OpenSans-Font.")
		}
		return font
	}()

	private var textColor: UIColor {
		.enaColor(for: .certificatePDFBlue)
	}
}

private extension String {

	func removingURNPrefix() -> String {
		return replacingOccurrences(of: "URN:UVCI:", with: "")
	}
}
