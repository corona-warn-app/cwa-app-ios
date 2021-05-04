//
// 🦠 Corona-Warn-App
//


import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

final class HealthCertificateToolkitTests: XCTestCase {

    func test_When_decodeSucceeds_Then_CorrectDataIsReturned() throws {
        let healthCertificateToolkit = HealthCertificateToolkit()

        for testData in testDatas {
            let result = healthCertificateToolkit.decodeHealthCertificate(base45: testData.input)

            guard case let .success(certificateRepresentations) = result else {
                XCTFail("Success expected.")
                return
            }

            let jsonDecoder = JSONDecoder()

            let decodedCertificate = try jsonDecoder.decode(TestHealthCertificate.self, from: certificateRepresentations.json)

            guard let testData = testData.output.data(using: .utf8) else {
                XCTFail("Failed to encode test data.")
                return
            }
            let testCertificate = try jsonDecoder.decode(TestHealthCertificate.self, from: testData)

            XCTAssertEqual(decodedCertificate, testCertificate)
        }
    }

    func test_When_CertificateHasUmlaut_Then_EncodeDecodeWorksCorrectly() throws {
        let testCertificate = TestHealthCertificate(birthDate: nil, id: nil, issuer: nil, name: "Mäx Müstermänn", sex: nil, vaccination: nil, version: nil)

        let encoder = CodableCBOREncoder()
        let cborData = try encoder.encode(testCertificate)

        let decoder = CBORDecoder(input: [UInt8](cborData))

        guard let cbor = try? decoder.decodeItem() else {
            XCTFail("Could not decode cbor data.")
            return
        }

        let healthCertificateToolkit = HealthCertificateToolkit()
        let jsonData = try healthCertificateToolkit.extractJSON(cbor)
        let jsonDecoder = JSONDecoder()
        let jsonCertificate = try jsonDecoder.decode(TestHealthCertificate.self, from: jsonData)

        XCTAssertEqual(testCertificate, jsonCertificate)
    }

    lazy var testDatas: [TestData] = {[
        TestData (
            input: "6BFB 9B8OYK3DR3D92BSQAQAHSOMEQ3%1GEVQT4H4O8G3.13G$H6+DH.157SWEV21SD7F2OPY1O-9LRFG0NGCUEPS5LLKJ:1CEJTLA2SADI887A/P3UHL20FTA9ZTRPSVUXO19LEZBQF3VJE$77D5FFC91ZFKCPP%90VS09P2QDQBCMY7-AE0/RW1R:ICP76XRS5UGC82WDNRJ9R7SX331MI9C7WNE5ZL1795NTA/P-35.N65O65ZQ8SU2:KY:C9K9PKD6+K%DI$YQ-9A:CKZ+5HPQNIF7N3K UEU6GEKHCO03MC%QN+LN+C5TTB1B94EC$38QC5O5DP262N:X7JYR/XH/A8%-1KZFTODRY3I 859G-IS9TMY4JM21TAV$N2NK3%BW8K7GI6%O8DUKUT036EF$8:32RBK*0IHJISK5SLTT21KYE7 U/316$I08A/XBU4IZYAGD3UVOJQI2YH3JMXHS1IPE%FOJN$HOV%B3FWCDCP65/%RKP2W2M4A9X7GETNASOXZ0Q/Q5LUNMJ QH+-2:4FW$33+4 +AY7GV-15/717GXY4H4O.:RM/USWV70PV8NGL5XP15NQ3K217GC:1WQEJNBK1RU6J.4K9/J%VQOHA+EW I0YMQ 0",
            output: """
                {
                  "birthDate": "19910415",
                  "id": "01DE/00000/1119305005/4299MYTM6WE72JLNK6ZWIIUF6#S",
                  "issuer": "Bundesministerium für Gesundheit (BMG)",
                  "name": "Müller Lisa",
                  "sex": "male",
                  "vaccination": [
                    {
                      "targetDisease": "840539006",
                      "vaccineCode": "1119305005",
                      "product": "ChAdOx1 nCoV-19 (AstraZeneca)",
                      "manufacturer": "AstraZeneca",
                      "series": "1/2",
                      "occurence": "20210416",
                      "location": "00000",
                      "country": "DE",
                      "nextDate": "20210601"
                    }
                  ],
                  "version": "1.0.0"
                }
            """),
        TestData (
            input: "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDE9SCROHN$K%OKSQ1C%OE Q$M8XL9%H0VK0N$K8WIAL8UL8W2BJH0NEQ:Q67ZMA$6PRPFZTL43P$02%8ZMVD0H6974BFMI3VLVQIVFB3FGF4E593D03LY6TQWCC%CI$2EVV523UA3GHJE9B3ZC9:2%:KD$A/N757TLXKIBTV5TN%2L003$IQH5-Y3$PA$HSCHBI I7995R5ZFQETU 9R6KPB$PS1Q5V5XC5Q$9VVP2HU4ZLJ%5Z+L8KP7$PB.PGN9E/99$PZT56+PYPD-GIOMILZI1MBPMI+ZJ49BJNJ0ECM8C%P1%RKYTAUOLK/FNID$SOSKT3%8-B5DJP6Y2P7QI4OQC8P/H5FI.C3XFDE$A4%86.9FOVMB41JPGMJI58GQ9UF2EN9QRH6VHVB49ONMNR3LC8VO1THP.HB%HUZU6TIGL9JMI:M6BMSZ8D$JCP1J TI+P1BCB987.RQ3YU2YU0LHESI3XBUVP$SH8A810H% 0NY02+1-+A-DW09HNZVW UO1T/NT5%2EVLZCNETUFJ1RF9+ 30:I1HH0V3NSIWDNA4GOWB 7V1*FDJAD0W33IGXU5B7/9TV.4:VUX454ONYM02%8YWL",
            output: """
                {
                  "birthDate": "19900202",
                  "id": "01DE/00000/1119349007/40UQ6XNLAUTALI53NOPOJ2FIU#S",
                  "identifier": "LD1236489",
                  "issuer": "Bundesministerium für Gesundheit (BMG)",
                  "name": "Mustermann Max",
                  "sex": "male",
                  "vaccination": [
                    {
                      "targetDisease": "840539006",
                      "vaccineCode": "1119349007",
                      "product": "COMIRNATY (Pfizer/BioNTech)",
                      "manufacturer": "Pfizer-BioNTech",
                      "series": "2/2",
                      "occurence": "20210416",
                      "location": "00000",
                      "country": "DE"
                    }
                  ],
                  "version": "1.0.0"
                }
            """),
        TestData (
            input: "6BFB 93B6AP2YQ2%91Y0NIHA* 5OLJW5T%/E26J5P50.DP7PFXP--2.IP:HGLJJ4WN6-RJP3LUMDX8VWJNMGL*HTYLHO04C15.A/DK6A8WR5SS8WR5F*O %9VLGGJKS22F0C+4W4 FIZVC9LB+7RECZ MLEWRP65OUN/6N9WG.5+SF*KMU66X8NL4IZVIK OLOGGD1 YQ1NTO0JP G7DKN%11WG.-EJTAZCLBMLP/BD$F4113SELNT- 5Z.JFQDCONP1Q%/VVE2E24Y4I:CLG6GNNTUHRUVA60EC:M898A/2OHJ3CKZ+5Y+60BFTLBDRJNQP99G648N%RIZSFCM2IOKC9X465I25 8-NMVJAF-7KF3Q1JV%7-5M4K9154YM99%RYU1D96-6KS24CAF9F1MU3IKK1BAKTTSMOXJM5S7$MI5-Q86D IHCIB+1N7 BYVNK BB-RK-8* 5KCK6PKSF2LZ8ZMJMV2.-9559BTSMILXQM: K7FOTH8WJ49SK0UBLUVH%3/MO2XR3F5OGCD2VW048N55%UOFO27DF/P+IFWOFGFV US9ETF.JXLUQLD59L5%3D7NGQD4QDW8NV0DHNLC2VC/7QTF-+316S4BQKOR-WU148+QV.CFK R4/445G23KCNF%AV+UTCMM",
            output: """
                {
                  "birthDate": "19600703",
                  "id": "01DE/00000/1119305005/8EAOPQEEGWO7YZ0M3MAIRZFIM#S",
                  "identifier": "DWIDM126889",
                  "issuer": "Bundesministerium für Gesundheit (BMG)",
                  "name": "Schneider Ronald",
                  "sex": "male",
                  "vaccination": [
                    {
                      "targetDisease": "840539006",
                      "vaccineCode": "1119305005",
                      "product": "ChAdOx1 nCoV-19 (AstraZeneca)",
                      "manufacturer": "AstraZeneca",
                      "series": "2/2",
                      "occurence": "20210416",
                      "location": "00000",
                      "country": "DE"
                    }
                  ],
                  "version": "1.0.0"
                }
            """),
        TestData (
            input: "6BFXZ8Q.NAP2CR3091V62D60MV5LO0*F1WP69GE8J1TMEGW7SQ81$I-$17DG$.T44EEDTK%JZWU-0BF-SEF74WG5SRZAB5:7Z$2Y/0T4V+01TS4G*JC3LMHQ4O4-QBMBUNU7TUK2+H*JLF+0R14K:FA6MB9KX.0 6KEPS:NQ5PSX+QE3FNRS35L8MQ5TS-9T6144E4H-2PNS/FDBFE/XHU1Q9ID$%ACOF3.5BSG8SBOZN/%1Q0EV3M6*MODU9 ET273QFW$0EE7Z44C/JLNF+-L.5O0O6:VI9GB9IBPD47+ICLOR%0EZ9.LM9:45-M6*I.D1$NB0WP-OD/Z2NUGIGQQ84EIHFOJTNA-T2+WHZ/8PHUZ4HCOPEKQY/2PDVD$4F60C7E*Q81AKNEI.1J9+ILC1SDF*0OK9W-4NVOC8:MC7RT3VPHR+RNET9BF41EIG/F4XGDXGPK4E-4%W5S*KS554%DJCTR1JJDKIJ7IMOTWOO$MIXQ921L:H49DCYG9BQSDKZC17/UB QUWTW27K90D2PF0KOQEOPCT/UQMBN*MUOF:SQ:/SV7PK7F5/UJWSBIVYN5ZNM%:TJOS:0B12K93LK5Q%BQ71HIANAWK%3IN-2U0W92SY4D18UG.P*FDU%V$ZOS0M",
            output: """
                {
                  "birthDate": "19450519",
                  "id": "01DE/00000/1119349007/AGF05DWZI4U1DMUMN6JN8ORUC#S",
                  "identifier": "TEST374525",
                  "issuer": "Bundesministerium für Gesundheit (BMG)",
                  "name": "Musterfrau Erica",
                  "sex": "female",
                  "vaccination": [
                    {
                      "targetDisease": "840539006",
                      "vaccineCode": "1119349007",
                      "product": "mRNA-1273 (Moderna)",
                      "manufacturer": "Moderna",
                      "series": "1/2",
                      "occurence": "20210416",
                      "location": "00000",
                      "country": "DE",
                      "nextDate": "20210503"
                    }
                  ],
                  "version": "1.0.0"
                }
            """),
        TestData (
            input: "6BFFY8JZ9+J2KR21EK8USBRSMYG0GLASO*PFVQV*CNRFJGZD:E9BP4ZMBF.JWKNSINF$UCKU+RJ3.E:90A-HF6AZKHH*KUZ2I4ULZ4QQK6+B/VGV+RXD6V14RNCZY2SUS$:OX5H16Q$/3 O7CP6L:ED*M2+FM-9.F7F/1+BS0UHB8SV0UW*P/:FEZ7OH7EW7YB46 9.6AZTTG6KHK8PNLJ%4Y6A2 D+1ERHA9BDIGDKWP/8L0JNLKDKVK$-B56FU-I8OFTT9GK1+ES7H0UJHBTP%2QGZ6CXF G9X64WZUN G:AK +S/XEWAIJMN.6CXSEFBK6247+Q8NV+PC4NO%*B*LUR%8AHPWWSMDRD*OJNC+SQH8IN24G-R05VKQ8ZCD.ZF4I444K*RGUDA25LI9J5ZK2 CQSHFAN4821ZD3DR87IYFU24L%UITLD*4RM2JWM3KNVM9G854/E1Z+CW9BN76NZ1DIGUUE%C8P38K*G9AD+J6YAK9X6LO3./RCMK1EPUUM4UI HINALKWC57CYPCW$0:B9GL9OYMXY1%TJT:GCBLNPGLZGJYDNS4IJ8A MPDVV89P:I8RFQ 6IEIGMT/4L8LGTRVQAV1H7+R4P-SV+KYXSS2DQXMONCT7KD/9J0SNYQ.6MF.V/TRY7ICHFEI6O TN*TBAW:.UW5O1Y7WJT JNE08R7HE%7CFES7GP2TA2GU7UH%V*17:P9.4",
            output: """
                {
                  "birthDate": "19230107",
                  "id": "01DE/00000/1119349007/1ICRRAKC5ZQ0IDMTVEVCTBQKS#S",
                  "identifier": "DHJSO1234",
                  "issuer": "Bundesministerium für Gesundheit (BMG)",
                  "name": "Zimmermann Paola",
                  "sex": "diverse",
                  "vaccination": [
                    {
                      "targetDisease": "840539006",
                      "vaccineCode": "1119349007",
                      "product": "COMIRNATY (Pfizer/BioNTech)",
                      "manufacturer": "Pfizer-BioNTech",
                      "series": "1/2",
                      "lotNumber": "123901230ß91230",
                      "occurence": "20210416",
                      "location": "00000",
                      "performer": "123456789",
                      "country": "DE",
                      "nextDate": "20210520"
                    }
                  ],
                  "version": "1.0.0"
                }
            """)
    ]}()
}

// MARK: - TestData

struct TestData {
    let input: String
    let output: String
}

// MARK: - TestHealthCertificate

private struct TestHealthCertificate: Codable, Equatable {

    let birthDate, id, issuer, name: String?
    let sex: String?
    let vaccination: [Vaccination]?
    let version: String?
}

private struct Vaccination: Codable, Equatable {
    let targetDisease, vaccineCode, product, manufacturer: String?
    let series, occurence, location, country: String?
    let nextDate: String?
}
