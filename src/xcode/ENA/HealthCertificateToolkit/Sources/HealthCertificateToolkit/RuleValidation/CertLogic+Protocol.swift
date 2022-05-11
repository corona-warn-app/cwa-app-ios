//
// 🦠 Corona-Warn-App
//

import CertLogic

public protocol CertLogicEnginable {

    init(schema: String, rules: [Rule])
    func validate(filter: FilterParameter, external: ExternalParameter, payload: String) -> [ValidationResult]
}

extension CertLogicEngine: CertLogicEnginable {
    public func validate(filter: FilterParameter, external: ExternalParameter, payload: String) -> [ValidationResult] {
        return validate(filter: filter, external: external, payload: payload, validationType: .all)
    }
}
