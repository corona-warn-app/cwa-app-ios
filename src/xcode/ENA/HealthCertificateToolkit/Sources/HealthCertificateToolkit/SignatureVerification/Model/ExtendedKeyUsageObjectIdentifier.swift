//
// 🦠 Corona-Warn-App
//

enum ExtendedKeyUsageObjectIdentifier {

    static let testIssuer = [
        "1.3.6.1.4.1.1847.2021.1.1",
        "1.3.6.1.4.1.0.1847.2021.1.1"
    ]
    static let vaccinationIssuer = [
        "1.3.6.1.4.1.1847.2021.1.2",
        "1.3.6.1.4.1.0.1847.2021.1.2"
    ]
    static let recoveryIssuer = [
        "1.3.6.1.4.1.1847.2021.1.3",
        "1.3.6.1.4.1.0.1847.2021.1.3"
    ]

    static var all: [String] {
        testIssuer + vaccinationIssuer + recoveryIssuer
    }
}
