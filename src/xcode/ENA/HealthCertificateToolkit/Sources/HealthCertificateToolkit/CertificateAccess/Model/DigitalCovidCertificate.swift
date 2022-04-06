//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

public struct DigitalCovidCertificate: Codable, Equatable {

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case version = "ver"
        case name = "nam"
        case dateOfBirth = "dob"
        case vaccinationEntries = "v"
        case testEntries = "t"
        case recoveryEntries = "r"
    }

    // MARK: - Internal

    public let version: String
    public let name: Name
    public let dateOfBirth: String
    public let vaccinationEntries: [VaccinationEntry]?
    public let testEntries: [TestEntry]?
    public let recoveryEntries: [RecoveryEntry]?

    public static func fake(
        version: String = "1.3.0",
        name: Name = .fake(),
        dateOfBirth: String = "1989-12-12",
        vaccinationEntries: [VaccinationEntry]? = nil,
        testEntries: [TestEntry]? = nil,
        recoveryEntries: [RecoveryEntry]? = nil
    ) -> DigitalCovidCertificate {
        
        // To ensure, that the decoding does not fail, at least one of the entries has to be set.
        var _vaccinationEntries = vaccinationEntries
        if vaccinationEntries == nil &&
            testEntries == nil &&
            recoveryEntries == nil {
            _vaccinationEntries = [
                VaccinationEntry.fake()
            ]
        }
        return DigitalCovidCertificate(
            version: version,
            name: name,
            dateOfBirth: dateOfBirth,
            vaccinationEntries: _vaccinationEntries,
            testEntries: testEntries,
            recoveryEntries: recoveryEntries
        )
    }
}

public struct VaccinationEntry: Codable, Equatable {

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

    // MARK: - Public

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

    public static func fake(
        diseaseOrAgentTargeted: String = "840539006",
        vaccineOrProphylaxis: String = "1119349007",
        vaccineMedicinalProduct: String = "EU/1/20/1528",
        marketingAuthorizationHolder: String = "ORG-100030215",
        doseNumber: Int = 1,
        totalSeriesOfDoses: Int = 2,
        dateOfVaccination: String = "2021-06-01",
        countryOfVaccination: String = "DE",
        certificateIssuer: String = "Bundesministerium für Gesundheit",
        uniqueCertificateIdentifier: String = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
    ) -> VaccinationEntry {
        VaccinationEntry(
            diseaseOrAgentTargeted: diseaseOrAgentTargeted,
            vaccineOrProphylaxis: vaccineOrProphylaxis,
            vaccineMedicinalProduct: vaccineMedicinalProduct,
            marketingAuthorizationHolder: marketingAuthorizationHolder,
            doseNumber: doseNumber,
            totalSeriesOfDoses: totalSeriesOfDoses,
            dateOfVaccination: dateOfVaccination,
            countryOfVaccination: countryOfVaccination,
            certificateIssuer: certificateIssuer,
            uniqueCertificateIdentifier: uniqueCertificateIdentifier
        )
    }
}

public struct TestEntry: Codable, Equatable {

    // MARK: - Init

    public init(
        diseaseOrAgentTargeted: String,
        typeOfTest: String,
        testResult: String,
        naaTestName: String?,
        ratTestName: String?,
        dateTimeOfSampleCollection: String,
        testCenter: String?,
        countryOfTest: String,
        certificateIssuer: String,
        uniqueCertificateIdentifier: String
    ) {
        self.diseaseOrAgentTargeted = diseaseOrAgentTargeted
        self.typeOfTest = typeOfTest
        self.testResult = testResult
        self.naaTestName = naaTestName
        self.ratTestName = ratTestName
        self.dateTimeOfSampleCollection = dateTimeOfSampleCollection
        self.testCenter = testCenter
        self.countryOfTest = countryOfTest
        self.certificateIssuer = certificateIssuer
        self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
    }


    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case diseaseOrAgentTargeted = "tg"
        case typeOfTest = "tt"
        case testResult = "tr"
        case naaTestName = "nm"
        case ratTestName = "ma"
        case dateTimeOfSampleCollection = "sc"
        case testCenter = "tc"
        case countryOfTest = "co"
        case certificateIssuer = "is"
        case uniqueCertificateIdentifier = "ci"
    }

    // MARK: - Internal

    public let diseaseOrAgentTargeted: String
    public let typeOfTest: String
    public let testResult: String
    public let naaTestName: String?
    public let ratTestName: String?
    public let dateTimeOfSampleCollection: String
    public let testCenter: String?
    public let countryOfTest: String
    public let certificateIssuer: String
    public let uniqueCertificateIdentifier: String

    public static func fake(
        diseaseOrAgentTargeted: String = "840539006",
        typeOfTest: String = "LP6464-4",
        testResult: String = "260415000",
        naaTestName: String? = nil,
        ratTestName: String? = nil,
        dateTimeOfSampleCollection: String = "2021-05-29T22:34:17.595Z",
        testCenter: String? = nil,
        countryOfTest: String = "DE",
        certificateIssuer: String = "Bundesministerium für Gesundheit",
        uniqueCertificateIdentifier: String = "01DE/00000/1119349007/9QK4WRVMUOUIP7PYVNSFBK9GF"
    ) -> TestEntry {
        TestEntry(
            diseaseOrAgentTargeted: diseaseOrAgentTargeted,
            typeOfTest: typeOfTest,
            testResult: testResult,
            naaTestName: naaTestName,
            ratTestName: ratTestName,
            dateTimeOfSampleCollection: dateTimeOfSampleCollection,
            testCenter: testCenter,
            countryOfTest: countryOfTest,
            certificateIssuer: certificateIssuer,
            uniqueCertificateIdentifier: uniqueCertificateIdentifier
        )
    }
}

public struct RecoveryEntry: Codable, Equatable {

    // MARK: - Init

    public init(
        diseaseOrAgentTargeted: String,
        dateOfFirstPositiveNAAResult: String,
        countryOfTest: String,
        certificateIssuer: String,
        certificateValidFrom: String,
        certificateValidUntil: String,
        uniqueCertificateIdentifier: String
    ) {
        self.diseaseOrAgentTargeted = diseaseOrAgentTargeted
        self.dateOfFirstPositiveNAAResult = dateOfFirstPositiveNAAResult
        self.countryOfTest = countryOfTest
        self.certificateIssuer = certificateIssuer
        self.certificateValidFrom = certificateValidFrom
        self.certificateValidUntil = certificateValidUntil
        self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
    }

    // MARK: - Protocol Codable

    enum CodingKeys: String, CodingKey {
        case diseaseOrAgentTargeted = "tg"
        case dateOfFirstPositiveNAAResult = "fr"
        case countryOfTest = "co"
        case certificateIssuer = "is"
        case certificateValidFrom = "df"
        case certificateValidUntil = "du"
        case uniqueCertificateIdentifier = "ci"
    }

    // MARK: - Internal

    public let diseaseOrAgentTargeted: String
    public let dateOfFirstPositiveNAAResult: String
    public let countryOfTest: String
    public let certificateIssuer: String
    public let certificateValidFrom: String
    public let certificateValidUntil: String
    public let uniqueCertificateIdentifier: String

    public static func fake(
        diseaseOrAgentTargeted: String = "840539006",
        dateOfFirstPositiveNAAResult: String = "2021-04-21",
        countryOfTest: String = "NL",
        certificateIssuer: String = "Ministry of Public Health, Welfare and Sport",
        certificateValidFrom: String = "2021-05-01",
        certificateValidUntil: String = "2021-10-21",
        uniqueCertificateIdentifier: String = "urn:uvci:01:NL:LSP/REC/1289821"
    ) -> RecoveryEntry {

        RecoveryEntry(
            diseaseOrAgentTargeted: diseaseOrAgentTargeted,
            dateOfFirstPositiveNAAResult: dateOfFirstPositiveNAAResult,
            countryOfTest: countryOfTest,
            certificateIssuer: certificateIssuer,
            certificateValidFrom: certificateValidFrom,
            certificateValidUntil: certificateValidUntil,
            uniqueCertificateIdentifier: uniqueCertificateIdentifier
        )
    }
}

public struct Name: Codable, Equatable {

    // MARK: - Init
    
    public init(
        familyName: String?,
        givenName: String?,
        standardizedFamilyName: String,
        standardizedGivenName: String?
    ) {
        self.familyName = familyName
        self.givenName = givenName
        self.standardizedFamilyName = standardizedFamilyName
        self.standardizedGivenName = standardizedGivenName
    }

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

    public static func fake(
        familyName: String? = nil,
        givenName: String? = nil,
        standardizedFamilyName: String = "ERIKA<DOERTE",
        standardizedGivenName: String? = nil
    ) -> Name {
        Name(
            familyName: familyName,
            givenName: givenName,
            standardizedFamilyName: standardizedFamilyName,
            standardizedGivenName: standardizedGivenName
        )
    }
}
