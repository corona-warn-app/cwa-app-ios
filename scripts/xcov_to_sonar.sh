#!zsh
set -euo pipefail

function convert_file {
  local xccovarchive_file="$1"
  local file_name="$2"
  local xccov_options="$3"
  echo "  <file path=\"$file_name\">"
  xcrun xccov view $xccov_options --file "$file_name" "$xccovarchive_file" | \
    sed -n '
    s/^ *\([0-9][0-9]*\): 0.*$/    <lineToCover lineNumber="\1" covered="false"\/>/p;
    s/^ *\([0-9][0-9]*\): [1-9].*$/    <lineToCover lineNumber="\1" covered="true"\/>/p
    '
  echo '  </file>'
}

function xccov_to_generic {
  echo '<coverage version="1">'
  for xccovarchive_file in "$1"; do
    local xccov_options=""
    if [[ $xccovarchive_file == *".xcresult"* ]]; then
      xccov_options="--archive"
    fi
    xcrun xccov view $xccov_options --file-list "$xccovarchive_file" | while read -r file_name; do
      convert_file "$xccovarchive_file" "$file_name" "$xccov_options"
    done
  done
  echo '</coverage>'
}

if [[ -d "$1" ]]; then
  {
    xccov_to_generic "$1"  > coverage.xml
    echo "[SUCCESS] Created coverage file coverage.xml from $1"
  } || {
    echo "[FAILURE] Coverage file creation failed. Writing dummy file."
    '<coverage version="1"></coverage>' > coverage.xml
  }
  echo "Now cleaning with command: s|$2||. Writing to $3"
  sed "s|$2||" coverage.xml > $3
else
  echo "[FAILURE] Coverage archive not found in $1. Check if tests job ran and xcov paths are up-to-date."
fi
