// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

class RiskLegendFactory {
    struct RiskLegendEntry {
        var riskLevel: RiskLevel
        var backgroundColor: UIColor
        var imageName: String
        var title: String
        var description: String
    }

    private static var sharedRiskLegendFactory = RiskLegendFactory()

    class func getSharedRiskLegendFactory() -> RiskLegendFactory {
        sharedRiskLegendFactory
    }

    func getRiskLegend() -> [RiskLegendEntry] {
        [
            RiskLegendEntry(
                riskLevel: .unknown,
                backgroundColor: .preferredColor(for: .unknownRisk),
                imageName: "sun.min",
                title: AppStrings.RiskView.unknownRisk,
                description: AppStrings.RiskView.unknownRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .inactive,
                backgroundColor: .preferredColor(for: .inactive),
                imageName: "cloud.rain",
                title: AppStrings.RiskView.inactiveRisk,
                description: AppStrings.RiskView.inactiveRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .low,
                backgroundColor: .preferredColor(for: .positive),
                imageName: "sun.dust",
                title: AppStrings.RiskView.lowRisk,
                description: AppStrings.RiskView.lowRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .high,
                backgroundColor: .preferredColor(for: .negative),
                imageName: "cloud.bolt",
                title: AppStrings.RiskView.highRisk,
                description: AppStrings.RiskView.highRiskDetailHelp
            )
        ]
    }
}
