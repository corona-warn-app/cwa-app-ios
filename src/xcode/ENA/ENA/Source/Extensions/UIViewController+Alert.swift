//
//  UIViewController+Alert.swift
//  ENA
//
//  Created by Hu, Hao on 02.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    
    func alertError(message:String?, title: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
