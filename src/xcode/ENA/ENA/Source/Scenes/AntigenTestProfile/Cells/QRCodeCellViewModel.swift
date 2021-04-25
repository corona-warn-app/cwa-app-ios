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

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let backgroundColor: UIColor
	let boarderColor: UIColor

	var qrCodeImage: UIImage {
		guard let vCardString = String(data: vCardData, encoding: .utf8),
			  let QRCodeImage = UIImage.qrCode(
				  with: vCardString,
				  size: CGSize(width: 280.0, height: 280.0),
				  qrCodeErrorCorrectionLevel: .medium
			  )
			  else {
			Log.error("Failed to create QRCode image for vCard data")
			return UIImage()
		}
		return QRCodeImage
	}

	// MARK: - Private

	private let antigenTestProfile: AntigenTestProfile

	private var vCardData: Data {
		let contact = CNMutableContact()
		contact.contactType = .person
		contact.givenName = antigenTestProfile.firstName ?? ""
		contact.familyName = antigenTestProfile.lastName ?? ""

		if let dateOfBirth = antigenTestProfile.dateOfBirth {
			contact.birthday = Calendar.current.dateComponents([.day, .month, .year], from: dateOfBirth)
		}


		do {
			let vCardData = try CNContactVCardSerialization.data(with: [contact])
			return vCardData
		} catch {
			Log.error("Failed to create vCard data with antigenTestProfile input")
			return Data()
		}
	}


}
