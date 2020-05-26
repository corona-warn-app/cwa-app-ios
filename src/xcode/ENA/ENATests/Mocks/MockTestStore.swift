//
//  MockTestStorage.swift
//  ENATests
//
//  Created by Rohwer, Johannes on 26.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
@testable import ENA

class MockTestStore: Store {
    
    var isOnboarded: Bool = false
       
    var dateLastExposureDetection: Date?
    
    var dateOfAcceptedPrivacyNotice: Date?
    
    var allowsCellularUse: Bool = false
    
    var developerSubmissionBaseURLOverride: String?
    
    var developerDistributionBaseURLOverride: String?
    
    var developerVerificationBaseURLOverride: String?
    
    var teleTan: String?
    
    var tan: String?
    
    var testGUID: String?
    
    var devicePairingConsentAccept: Bool = false
    
    var devicePairingConsentAcceptTimestamp: Int64?
    
    var devicePairingSuccessfulTimestamp: Int64?
    
    var isAllowedToSubmitDiagnosisKeys: Bool = false
    
    var registrationToken: String?
    
    
}
