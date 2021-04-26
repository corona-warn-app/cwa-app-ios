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
		boarderColor: UIColor
	) {
		self.antigenTestProfile = antigenTestProfile
		self.backgroundColor = backgroundColor
		self.boarderColor = boarderColor
	}

	// MARK: - Internal

	let backgroundColor: UIColor
	let boarderColor: UIColor

	// QRCode image with vCard data inside - will create an empty image if data is broken
	var qrCodeImage: UIImage {
		guard let vCardString = String(data: vCardData, encoding: .utf8),
			  let QRCodeImage = UIImage.qrCode(
				with: vCardString,
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

	// create vCard data, CNContactVCardSerialization creates a version 3.0 output
	var vCardData: Data {
		let contact = CNMutableContact()
		contact.contactType = .person
		contact.givenName = antigenTestProfile.firstName ?? ""
		contact.familyName = antigenTestProfile.lastName ?? ""

		if let dateOfBirth = antigenTestProfile.dateOfBirth {
			contact.birthday = Calendar.current.dateComponents([.day, .month, .year], from: dateOfBirth)
		}

		if let phoneNumber = antigenTestProfile.phoneNumber {
			contact.phoneNumbers = [CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phoneNumber))]
		}

		if !(antigenTestProfile.city?.isEmpty ?? true) ||
		   !(antigenTestProfile.addressLine?.isEmpty ?? true) ||
		   !(antigenTestProfile.zipCode?.isEmpty ?? true) {
			let postalAddress = CNMutablePostalAddress()
			postalAddress.city = antigenTestProfile.city ?? ""
			postalAddress.street = antigenTestProfile.addressLine ?? ""
			postalAddress.postalCode = antigenTestProfile.zipCode ?? ""
			contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: postalAddress)]
		}

		do {
			let vCardData = try CNContactVCardSerialization.data(with: [contact])
			return vCardData
		} catch {
			Log.error("Failed to create vCard data with antigenTestProfile input")
			return Data()
		}
	}

	// MARK: - Private

	private let antigenTestProfile: AntigenTestProfile

}
