//
// 🦠 Corona-Warn-App
//

import Foundation

public struct ProofCertificateRepresentations: Codable {

    let base45: String
    let cbor: Data
    let header: HealthCertificateHeader
}

public struct HealthCertificateRepresentations: Codable {

    let base45: String
    let cbor: Data
    let header: HealthCertificateHeader
    let certificate: HealthCertificate
}

public struct HealthCertificateHeader: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case issuedAt = "iat"
        case expirationTime = "exp"
    }

    // MARK: - Internal

    let issuer: String
    let issuedAt: UInt64?
    let expirationTime: UInt64
}

public struct HealthCertificate: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case version = "ver"
        case name = "nam"
        case dateOfBirth = "dob"
        case vaccinationCertificates = "v"
    }

    // MARK: - Internal

    let version: String
    let name: HealthCertificateName
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

public struct HealthCertificateName: Codable, Equatable {

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
