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

extension AppInformationHelpModel {
	// TODO: Evalute actual content and localize it
	static let questions = AppInformationHelpModel(
		questions: [
			(
				sectionTitle: "Tracing",
				questions: [
					(title: "Wie funktioniert Tracing?", details: .helpTracing),
					(title: "Wie kann ich das Tracing ausschalten?", details: .helpTracing),
					(title: "Woran erkenne ich, dass das Tracing aktiv ist?", details: .helpTracing),
				]
			),
			(
				sectionTitle: "Meine Daten",
				questions: [
					(title: "Wie lange werden meine Daten gespeichert?", details: .helpTracing),
					(title: "Wie funktioniert die Verschlüsselung meiner Daten?", details: .helpTracing),
				]
			),
		]
	)
}
