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

	func generatePDF() throws -> PDFDocument {
		guard let pdfDocument = PDFDocument(data: pdfTemplate) else {
			throw PDFGenerationError.pdfDocumentCreationFailed
		}

		guard let qrCodeImage = UIImage.qrCode(
			with: base45,
			encoding: .utf8,
			size: CGSize(width: 150, height: 150),
			qrCodeErrorCorrectionLevel: .medium
		) else {
			throw PDFGenerationError.qrCodeCreationFailed
		}

		try pdfDocument.embedImageAndText(
			image: qrCodeImage,
			at: CGPoint(x: 132, y: 436),
			texts: texts
		)

		return pdfDocument
	}

	private var pdfTemplate: Data {
//		let templateName: String
//		switch type {
//		case .vaccination:
//			templateName = "VaccinationCertificateTemplate_v4.1"
//		case .test:
//			templateName = "TestCertificateTemplate_v4.1"
//		case .recovery:
//			templateName = "RecoveryCertificateTemplate_v4.1"
//		}

		let templateName = "TestCertificateTemplate_v4.1"

		guard let tempalteURL = Bundle.main.url(forResource: templateName, withExtension: "pdf"),
			  let templateData = FileManager.default.contents(atPath: tempalteURL.path) else {
			fatalError("Could not load pdf template.")
		}
		return templateData
	}

	private var texts: [PDFText] {
		switch entry {
		case .vaccination(let entry):
			return vaccinationTexts(for: entry)
		case .test(let entry):
			return testTexts(for: entry)
		default:
			return []
		}
	}

	private func vaccinationTexts(for entry: VaccinationEntry) -> [PDFText] {
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
				text: entry.marketingAuthorizationHolder,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 158, y: 173, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.vaccineMedicinalProduct,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 158, y: 230, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.vaccineOrProphylaxis,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 19, y: 303, width: 126, height: 23),
				upsideDown: true
			),
			PDFText(
				text: entry.diseaseOrAgentTargeted,
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
				text: entry.uniqueCertificateIdentifier,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 28, y: 785, width: 266, height: 23),
				upsideDown: false
			)
		]
	}

	private func testTexts(for entry: TestEntry) -> [PDFText] {
		[
			PDFText(
				text: entry.certificateIssuer,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 25, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.countryOfTest,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 52, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.testCenter ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 79, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.testResult,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 108, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.dateTimeOfSampleCollection,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 146, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.ratTestName ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 171, y: 190, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.naaTestName ?? "",
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 171, y: 238, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.typeOfTest,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 305, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: entry.diseaseOrAgentTargeted,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 7, y: 333, width: 112, height: 21),
				upsideDown: true
			),
			PDFText(
				text: name.reversedFullNameWithoutFallback,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 693, width: 267, height: 23),
				upsideDown: false
			),
			PDFText(
				text: dateOfBirth,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 740, width: 267, height: 23),
				upsideDown: false
			),
			PDFText(
				text: entry.uniqueCertificateIdentifier,
				color: textColor,
				font: HealthCertificate.openSansFont,
				rect: CGRect(x: 29, y: 785, width: 267, height: 23),
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

	func createPdfView() throws -> PDFView {

		let pdfView = PDFView()
		let pdfDocument = try generatePDF()

		pdfView.document = pdfDocument
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.autoScales = true
		return pdfView
	}
}
