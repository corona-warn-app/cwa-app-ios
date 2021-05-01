////
//// 🦠 Corona-Warn-App
////
//
//
//import XCTest
//@testable import HealthCertificateToolkit
//
//final class HealthCertificateToolkitTests: XCTestCase {
//
//    struct TestData {
//        let input: String
//        let output: String
//    }
//
//    func test_When_decodeSucceeds_Then_CorrectDataIsReturned() throws {
//
//        let healthCertificateToolkit = HealthCertificateToolkit()
//
//        let result = healthCertificateToolkit.decode(base45: testData1.input)
//
//        guard case let .success(certificateRepresentations) = result else {
//            XCTFail("Success expected.")
//            return
//        }
//
//        let encoder = JSONEncoder()
//        let encodedData = try encoder.encode(certificateRepresentations)
//        let encodedString = String(data: encodedData, encoding: .utf8)
//        let testData = testData1.output.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//        XCTAssertEqual(encodedString, testData)
//    }
//
//    lazy var testData1: TestData = {
//        TestData (
//            input: "6BFB 9B8OYK3DR3D92BSQAQAHSOMEQ3%1GEVQT4H4O8G3.13G$H6+DH.157SWEV21SD7F2OPY1O-9LRFG0NGCUEPS5LLKJ:1CEJTLA2SADI887A/P3UHL20FTA9ZTRPSVUXO19LEZBQF3VJE$77D5FFC91ZFKCPP%90VS09P2QDQBCMY7-AE0/RW1R:ICP76XRS5UGC82WDNRJ9R7SX331MI9C7WNE5ZL1795NTA/P-35.N65O65ZQ8SU2:KY:C9K9PKD6+K%DI$YQ-9A:CKZ+5HPQNIF7N3K UEU6GEKHCO03MC%QN+LN+C5TTB1B94EC$38QC5O5DP262N:X7JYR/XH/A8%-1KZFTODRY3I 859G-IS9TMY4JM21TAV$N2NK3%BW8K7GI6%O8DUKUT036EF$8:32RBK*0IHJISK5SLTT21KYE7 U/316$I08A/XBU4IZYAGD3UVOJQI2YH3JMXHS1IPE%FOJN$HOV%B3FWCDCP65/%RKP2W2M4A9X7GETNASOXZ0Q/Q5LUNMJ QH+-2:4FW$33+4 +AY7GV-15/717GXY4H4O.:RM/USWV70PV8NGL5XP15NQ3K217GC:1WQEJNBK1RU6J.4K9/J%VQOHA+EW I0YMQ 0",
//            output: """
//                {
//                  "birthDate": "19910415",
//                  "id": "01DE/00000/1119305005/4299MYTM6WE72JLNK6ZWIIUF6#S",
//                  "issuer": "Bundesministerium für Gesundheit (BMG)",
//                  "name": "Müller Lisa",
//                  "sex": "male",
//                  "vaccination": [
//                    {
//                      "targetDisease": "840539006",
//                      "vaccineCode": "1119305005",
//                      "product": "ChAdOx1 nCoV-19 (AstraZeneca)",
//                      "manufacturer": "AstraZeneca",
//                      "series": "1/2",
//                      "occurence": "20210416",
//                      "location": "00000",
//                      "country": "DE",
//                      "nextDate": "20210601"
//                    }
//                  ],
//                  "version": "1.0.0"
//                }
//            """)
//    }()
//}
