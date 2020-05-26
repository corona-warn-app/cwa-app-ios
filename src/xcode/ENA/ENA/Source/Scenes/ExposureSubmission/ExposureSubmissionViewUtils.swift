//
//  ExposureSubmissionViewUtils.swift
//  ENA
//
//  Created by Rohwer, Johannes on 26.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

enum ExposureSubmissionViewUtils {

    static func setupConfirmationAlert(successAction: @escaping (() -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: AppStrings.Common.alertTitleKeySubmit,
                                      message: AppStrings.Common.alertDescriptionKeySubmit,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: AppStrings.Common.alertActionOk,
                               style: .default,
                               handler: { _ in
                                    successAction()
                                    alert.dismiss(animated: true, completion: nil)
                                })
        let cancel = UIAlertAction(title: AppStrings.Common.alertActionNo,
                                   style: .cancel,
                                   handler: { _ in
                                        alert.dismiss(animated: true, completion: nil)
                                    })
        alert.addAction(cancel)
        alert.addAction(ok)
        return alert
    }
    
    static func setupErrorAlert(_ error: ExposureSubmissionError) -> UIAlertController {
        return setupAlert(message: error.localizedDescription)
    }
    
    static func setupAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: AppStrings.ExposureSubmission.generalErrorTitle,
                                      message: message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: AppStrings.Common.alertActionOk,
                               style: .cancel,
                               handler: { _ in
                                    alert.dismiss(animated: true, completion: nil)
                               })
        alert.addAction(ok)
        return alert
    }
    
}
