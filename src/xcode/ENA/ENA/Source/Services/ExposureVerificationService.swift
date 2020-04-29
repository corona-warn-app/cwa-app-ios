//
//  ExposureVerificationService.swift
//  ENA
//
//  Created by Hu, Hao on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class ExposureVerificationService {
    
    weak var delegate: ExposureVerificationServiceDelegate?
    
    
    func startVerify() {
        //1. Check the timeframe/last succesfully download package.
        //2. Get the package download list.
        //3. Download the diff packages since last update.(consider: Transfer bakcground download, once the user kill the app or move it to background. Be careful, your app will get killled, need to update status.)
        //4. Create the ExposureDetectionSession from API, and call addDiagonisisKey to get the result.
        
        
    }
    
}


protocol ExposureVerificationServiceDelegate {
    //1. Error occurs.
    //2. Verification resolved/finished
}
