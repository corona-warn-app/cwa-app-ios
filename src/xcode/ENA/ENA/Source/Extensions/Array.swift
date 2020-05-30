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

extension Array {
	public func count(where test: (Element) -> Bool) -> Int {
		filter(test).count
	}
	
	public func first<T>(ofType _: T.Type) -> T? {
		first(where: { $0 is T }) as? T
	}
	
	public func firstIndex<T>(ofType _: T.Type) -> Int? {
		firstIndex(where: { $0 is T })
	}
	
	public func last<T>(ofType _: T.Type) -> T? {
		last(where: { $0 is T }) as? T
	}
	
	public func lastIndex<T>(ofType _: T.Type) -> Int? {
		lastIndex(where: { $0 is T })
	}
	
	public func filter<T>(ofType _: T.Type) -> [T] {
		filter { $0 is T } as? [T] ?? []
	}
	
	public func contains<T>(type _: T.Type) -> Bool {
		contains(where: { $0 is T })
	}
}
