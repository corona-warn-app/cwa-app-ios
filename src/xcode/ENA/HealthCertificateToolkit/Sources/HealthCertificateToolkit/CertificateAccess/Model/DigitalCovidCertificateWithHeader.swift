//
// 🦠 Corona-Warn-App
//

import Foundation

public struct DigitalCovidCertificateWithHeader: Codable, Equatable {
    public init(header: CBORWebTokenHeader, certificate: DigitalCovidCertificate) {
        self.header = header
        self.certificate = certificate
    }
    
    let header: CBORWebTokenHeader
    let certificate: DigitalCovidCertificate

    #if DEBUG
    
    public static func fake(
        header: CBORWebTokenHeader = .fake(),
        certificate: DigitalCovidCertificate = .fake()
    ) -> DigitalCovidCertificateWithHeader {
        return DigitalCovidCertificateWithHeader(
            header: header,
            certificate: certificate
        )
    }

    #endif
}

extension Array where Element == DigitalCovidCertificateWithHeader {

    // Find most recent vaccination certificate: the set of DGCs shall be filtered for vaccination certificates and the most recent one based on v[0].dt shall be identified.
    var recentVaccinationCertificate: DigitalCovidCertificateWithHeader? {
        filter {
            $0.certificate.isVaccinationCertificate
        }
        .max {
            guard let lhs = $0.certificate.vaccinationEntries?[0],
                  let rhs = $1.certificate.vaccinationEntries?[0] else {
                fatalError("Entries has to be of type 'vaccination' after previous filtering.")
            }
            guard let lhsDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: lhs.dateOfVaccination),
                  let rhsDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: rhs.dateOfVaccination) else {
                return false
            }

            // If there are multiple vaccination certificates with the same v[0].dt (dateOfVaccination), the vaccination certificate with the maximum iat claim of the CWT of the certificate shall have priority (i.e. most recently issued).
            if lhsDate == rhsDate {
                return $0.header.issuedAt < $1.header.issuedAt
            } else {
                return lhsDate < rhsDate
            }
        }
    }

    // Find most recent recovery certificate: the set of DGCs shall be filtered for recovery certificates and the most recent one based on r[0].fr shall be identified.
    var recentRecoveryCertificate: DigitalCovidCertificateWithHeader? {
        filter {
            $0.certificate.isRecoveryCertificate
        }
        .max {
            guard let lhs = $0.certificate.recoveryEntries?[0],
                  let rhs = $1.certificate.recoveryEntries?[0] else {
                fatalError("Entries has to be of type 'recovery' after previous filtering.")
            }
            guard let lhsDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: lhs.dateOfFirstPositiveNAAResult),
                  let rhsDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: rhs.dateOfFirstPositiveNAAResult) else {
                return false
            }

            // If there are multiple recovery certificates with the same r[0].fr (dateOfFirstPositiveNAAResult), the vaccination certificate with the maximum iat claim of the CWT of the certificate shall have priority (i.e. most recently issued).
            if lhsDate == rhsDate {
                return $0.header.issuedAt < $1.header.issuedAt
            } else {
                return lhsDate < rhsDate
            }
        }
    }
}

fileprivate extension ISO8601DateFormatter {

    static var justLocalDateFormatter: ISO8601DateFormatter {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        return dateFormatter
    }
}
