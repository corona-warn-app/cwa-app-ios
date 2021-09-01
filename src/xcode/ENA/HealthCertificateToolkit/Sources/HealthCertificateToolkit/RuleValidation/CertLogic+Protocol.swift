//
// 🦠 Corona-Warn-App
//

import CertLogic

public protocol CertLogicEnginable {

    init(schema: String, rules: [Rule])
    func validate(filter: FilterParameter, external: ExternalParameter, payload: String) -> [ValidationResult]
}

extension CertLogicEngine: CertLogicEnginable { }
