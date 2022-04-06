//
// 🦠 Corona-Warn-App
//

import Foundation

public enum CertificateEntry {
    case vaccination(VaccinationEntry)
    case test(TestEntry)
    case recovery(RecoveryEntry)
}

public extension DigitalCovidCertificate {
    
    var vaccinationEntry: VaccinationEntry? {
        vaccinationEntries?.first
    }

    var testEntry: TestEntry? {
        testEntries?.first
    }

    var recoveryEntry: RecoveryEntry? {
        recoveryEntries?.first
    }
    
    var entry: CertificateEntry {
        if let vaccinationEntry = vaccinationEntry {
            return .vaccination(vaccinationEntry)
        } else if let testEntry = testEntry {
            return .test(testEntry)
        } else if let recoveryEntry = recoveryEntry {
            return .recovery(recoveryEntry)
        }

        fatalError("Unsupported certificates are not added in the first place")
    }
    
    var uniqueCertificateIdentifier: String {
        switch entry {
        case .vaccination(let vaccinationEntry):
            return vaccinationEntry.uniqueCertificateIdentifier
        case .test(let testEntry):
            return testEntry.uniqueCertificateIdentifier
        case .recovery(let recoveryEntry):
            return recoveryEntry.uniqueCertificateIdentifier
        }
    }
}
