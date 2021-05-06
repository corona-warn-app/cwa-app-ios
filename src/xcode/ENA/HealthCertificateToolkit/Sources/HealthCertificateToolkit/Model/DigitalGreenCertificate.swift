//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

public struct DigitalGreenCertificate: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case version = "ver"
        case name = "nam"
        case dateOfBirth = "dob"
        case vaccinationCertificates = "v"
    }

    // MARK: - Internal

    let version: String
    let name: Name
    let dateOfBirth: String
    let vaccinationCertificates: [VaccinationCertificate]
}

public struct VaccinationCertificate: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case diseaseOrAgentTargeted = "tg"
        case vaccineOrProphylaxis = "vp"
        case vaccineMedicinalProduct = "mp"
        case marketingAuthorizationHolder = "ma"
        case doseNumber = "dn"
        case totalSeriesOfDoses = "sd"
        case dateOfVaccination = "dt"
        case countryOfVaccination = "co"
        case certificateIssuer = "is"
        case uniqueCertificateIdentifier = "ci"
    }

    // MARK: - Internal

    let diseaseOrAgentTargeted: String
    let vaccineOrProphylaxis: String
    let vaccineMedicinalProduct: String
    let marketingAuthorizationHolder: String

    let doseNumber: Int
    let totalSeriesOfDoses: Int

    let dateOfVaccination: String
    let countryOfVaccination: String
    let certificateIssuer: String
    let uniqueCertificateIdentifier: String
}

public extension VaccinationCertificate {

    var isEligibleForProofCertificate: Bool {
        doseNumber == totalSeriesOfDoses
    }
}

public struct Name: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case familyName = "fn"
        case givenName = "gn"
        case standardizedFamilyName = "fnt"
        case standardizedGivenName = "gnt"
    }

    // MARK: - Internal

    let familyName: String
    let givenName: String
    let standardizedFamilyName: String
    let standardizedGivenName: String
}
