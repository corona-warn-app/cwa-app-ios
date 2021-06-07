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
        case vaccinationEntries = "v"
        case testEntries = "t"
    }

    // MARK: - Internal

    public let version: String
    public let name: Name
    public let dateOfBirth: String
    public let vaccinationEntries: [VaccinationEntry]?
    public let testEntries: [TestEntry]?

    static func fake(
        version: String = "0.0.0",
        name: Name = .fake(),
        dateOfBirth: String = "01.01.1942",
        vaccinationEntries: [VaccinationEntry]? = nil,
        testEntries: [TestEntry]? = nil
    ) -> DigitalGreenCertificate {
        DigitalGreenCertificate(
            version: version,
            name: name,
            dateOfBirth: dateOfBirth,
            vaccinationEntries: vaccinationEntries,
            testEntries: testEntries
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

    static func fake(
        diseaseOrAgentTargeted: String = "diseaseOrAgentTargeted",
        vaccineOrProphylaxis: String = "vaccineOrProphylaxis",
        vaccineMedicinalProduct: String = "vaccineMedicinalProduct",
        marketingAuthorizationHolder: String = "marketingAuthorizationHolder",
        doseNumber: Int = 0,
        totalSeriesOfDoses: Int = 0,
        dateOfVaccination: String = "dateOfVaccination",
        countryOfVaccination: String = "countryOfVaccination",
        certificateIssuer: String = "certificateIssuer",
        uniqueCertificateIdentifier: String = "uniqueCertificateIdentifier"
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
        dateTimeOfTestResult: String,
        testCenter: String,
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
        self.dateTimeOfTestResult = dateTimeOfTestResult
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
        case dateTimeOfTestResult = "dr"
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
    public let dateTimeOfTestResult: String
    public let testCenter: String
    public let countryOfTest: String
    public let certificateIssuer: String
    public let uniqueCertificateIdentifier: String

    static func fake(
        diseaseOrAgentTargeted: String = "diseaseOrAgentTargeted",
        typeOfTest: String = "typeOfTest",
        testResult: String = "testResult",
        naaTestName: String? = nil,
        ratTestName: String? = nil,
        dateTimeOfSampleCollection: String = "dateTimeOfSampleCollection",
        dateTimeOfTestResult: String = "dateTimeOfTestResult",
        testCenter: String = "testCenter",
        countryOfTest: String = "countryOfTest",
        certificateIssuer: String = "certificateIssuer",
        uniqueCertificateIdentifier: String = "uniqueCertificateIdentifier"
    ) -> TestEntry {
        TestEntry(
            diseaseOrAgentTargeted: diseaseOrAgentTargeted,
            typeOfTest: typeOfTest,
            testResult: testResult,
            naaTestName: naaTestName,
            ratTestName: ratTestName,
            dateTimeOfSampleCollection: dateTimeOfSampleCollection,
            dateTimeOfTestResult: dateTimeOfTestResult,
            testCenter: testCenter,
            countryOfTest: countryOfTest,
            certificateIssuer: certificateIssuer,
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
