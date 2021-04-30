//
// 🦠 Corona-Warn-App
//

import Foundation

//{
//  "ver": "1.0.0",
//  "nam": {
//    "fn": "d'Arsøns - van Halen",
//    "gn": "François-Joan",
//    "fnt": "DARSONS<VAN<HALEN",
//    "gnt": "FRANCOIS<JOAN"
//  },
//  "dob": "2009-02-28",
//  "v": [
//    {
//      "tg": "840539006",
//      "vp": "1119349007",
//      "mp": "EU/1/20/1528",
//      "ma": "ORG-100030215",
//      "dn": 2,
//      "sd": 2,
//      "dt": "2021-04-21",
//      "co": "NL",
//      "is": "Ministry of Public Health, Welfare and Sport",
//      "ci": "urn:uvci:01:NL:PlA8UWS60Z4RZXVALl6GAZ"
//    }
//  ]
//}

// MARK: - HealthCertificate

struct HealthCertificate: Codable {

    struct Name: Codable {
        let fn, gn, fnt, gnt: String
    }

    struct VaccinationEntry: Codable {
        enum CodingKeys: String, CodingKey {
            case tg, vp, mp, ma, dn, sd, dt, co, ci
            case vIs = "is"
        }

        let tg, vp, mp, ma, dt, co, vIs, ci: String
        let dn, sd: Int
    }

    let ver: String
    let nam: Name
    let dob: String
    let v: [VaccinationEntry]
}

// MARK: - Fakes

extension CertificateRepresentations {
    static func fake(
        base45: String = "",
        cbor: Data = Data(),
        json: Data = Data()
    ) -> CertificateRepresentations {
        CertificateRepresentations(base45: base45, cbor: cbor, json: json)
    }
}

extension HealthCertificate {
    static func fake(
        ver: String = "",
        nam: Name = .fake(),
        dob: String = "",
        v: [VaccinationEntry] = [.fake()]
    ) -> HealthCertificate {
        HealthCertificate(ver: ver, nam: nam, dob: dob, v: v)
    }
}

extension HealthCertificate.Name {
    static func fake(
        fn: String = "",
        gn: String = "",
        fnt: String = "",
        gnt: String = ""
    ) -> HealthCertificate.Name {
        HealthCertificate.Name(fn: fn, gn: gn, fnt: fnt, gnt: gnt)
    }
}

extension HealthCertificate.VaccinationEntry {
    static func fake(
        tg: String = "",
        vp: String = "",
        mp: String = "",
        ma: String = "",
        dt: String = "",
        co: String = "",
        vIs: String = "",
        ci: String = "",
        dn: Int = 0,
        sd: Int = 0
    ) -> HealthCertificate.VaccinationEntry {
        HealthCertificate.VaccinationEntry(tg: tg, vp: vp, mp: mp, ma: ma, dt: dt, co: co, vIs: vIs, ci: ci, dn: dn, sd: sd)
    }
}

