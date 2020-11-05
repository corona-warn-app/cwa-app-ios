//
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
//

import Foundation

/// The WarnOthersNotificationStates represent the current situation of the warn others scheduled notification
/// The `expired` state defines, that both notifications have been fired and the schedule is over for the test result.
/// The `canceld`state defines, that the user has warned others and therefor the scheduled notifications have been canceled again.
enum WarnOthersNotificationState: Int {
	case unscheduled = 0, scheduled, expired, canceled
}
