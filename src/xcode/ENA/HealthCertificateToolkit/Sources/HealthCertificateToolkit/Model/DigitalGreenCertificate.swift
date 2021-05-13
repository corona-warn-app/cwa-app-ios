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

    public let version: String
    public let name: Name
    public let dateOfBirth: String
    public let vaccinationCertificates: [VaccinationCertificate]

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

    public let diseaseOrAgentTargeted: String
    public let vaccineOrProphylaxis: String
    public let vaccineMedicinalProduct: String
    public let marketingAuthorizationHolder: String

    public let doseNumber: Int
    public let totalSeriesOfDoses: Int

    public let dateOfVaccination: String
    public let countryOfVaccination: String
    public let certificateIssuer: String
    public let uniqueCertificateIdentifier: String

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

    public let familyName: String?
    public let givenName: String?
    public let standardizedFamilyName: String
    public let standardizedGivenName: String?

}
