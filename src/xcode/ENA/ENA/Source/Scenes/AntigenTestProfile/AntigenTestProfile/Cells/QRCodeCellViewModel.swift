////
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts

struct QRCodeCellViewModel {

	// MARK: - Init

	init(
		antigenTestProfile: AntigenTestProfile,
		backgroundColor: UIColor,
		borderColor: UIColor
	) {
		self.antigenTestProfile = antigenTestProfile
		self.backgroundColor = backgroundColor
		self.borderColor = borderColor
	}

	// MARK: - Internal

	let backgroundColor: UIColor
	let borderColor: UIColor

	// QRCode image with vCard data inside - will create an empty image if data is broken
	func qrCodeImage(revDate: Date = Date()) -> UIImage {
		guard let QRCodeImage = UIImage.qrCode(
			with: vCardV4(revDate: revDate),
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .medium
		)
		else {
			Log.error("Failed to create QRCode image for vCard data")
			return UIImage()
		}
		return QRCodeImage
	}

	func vCardV4(revDate: Date = Date()) -> String {
		let placeholder = """
			BEGIN:VCARD
			VERSION:4.0
			N:%@;%@;;;
			FN:%@
			BDAY:%@
			EMAIL;TYPE=home:%@
			TEL;TYPE="cell,home":%@
			ADR;type=home:;;%@;%@;;%@;
			REV:%@
			END:VCARD
			"""

		var dataOfBirth = ""
		if let date = antigenTestProfile.dateOfBirth {
			dataOfBirth = DateFormatter.VCard.justUTCDateFormatter.string(from: date)
		}

		return String(
			format: placeholder,
			convertStringForVCard(antigenTestProfile.lastName),
			convertStringForVCard(antigenTestProfile.firstName),
			convertStringForVCard(friendlyName),
			dataOfBirth,
			convertStringForVCard(antigenTestProfile.email),
			convertStringForVCard(antigenTestProfile.phoneNumber),
			convertStringForVCard(antigenTestProfile.addressLine),
			convertStringForVCard(antigenTestProfile.city),
			convertStringForVCard(antigenTestProfile.zipCode),
			DateFormatter.VCard.revDate.string(from: revDate)
		)
	}

	private func convertStringForVCard(_ input: String?) -> String {
		guard let input = input else {
			return ""
		}
		// removed line breaks
		var output = input.filter { !"\n\r".contains($0) }
		output = output.replacingOccurrences(of: ";", with: "\\;")
		output = output.replacingOccurrences(of: ",", with: "\\,")
		return output
	}

	// MARK: - Private

	private let antigenTestProfile: AntigenTestProfile

	private var friendlyName: String {
		var components = PersonNameComponents()
		components.givenName = antigenTestProfile.firstName
		components.familyName = antigenTestProfile.lastName

		let formatter = PersonNameComponentsFormatter()
		formatter.style = .medium
		return formatter.string(from: components).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}


}
