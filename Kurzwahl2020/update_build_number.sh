#!/bin/sh

#  update_build_number.sh
#  Kurzwahl2020
#
#  Created by Andreas Vogel on 07.06.20.
#  Copyright © 2020 Vogel, Andreas. All rights reserved.
#  Source code copied from
#  https://medium.com/swiftcommmunity/automatic-build-incrementation-technique-for-ios-release-94eb0d08785b

branch=${1:-'master'}
buildNumber=$(expr $(git rev-list $branch --count) - $(git rev-list HEAD..$branch --count))
echo "Updating build number to $buildNumber using branch '$branch'."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
if [ -f "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
fi
