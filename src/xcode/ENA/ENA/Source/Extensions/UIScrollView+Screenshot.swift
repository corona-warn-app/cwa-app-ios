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

import UIKit

extension UIScrollView {
	func screenshot() -> UIImage? {
		UIGraphicsBeginImageContext(contentSize)
		
		let savedContentOffset = contentOffset
		let savedFrame = frame
		
		contentOffset = CGPoint.zero
		frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
		
		layer.render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		
		contentOffset = savedContentOffset
		frame = savedFrame
		
		UIGraphicsEndImageContext()
		
		return image
	}
}
