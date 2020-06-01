echo "###########################"
echo "  1. Running SwiftFormat ..."
echo "###########################"
if which swiftformat >/dev/null; then
  swiftformat .
else
  echo "warning: SwiftFormat is not available."
  echo "Use 'brew install swiftformat' to install SwiftFormat or download it manually from https://github.com/nicklockwood/SwiftFormat."
fi

echo "###########################"
echo "  2. Running SwiftLint ..."
echo "###########################"
if which swiftlint >/dev/null; then
  swiftlint -q
else
  echo "warning: SwiftLint is not available."
  echo "Use 'brew install swiftlint' to install SwiftLint or download it manually from https://github.com/realm/SwiftLint."
fi

echo "###########################"
echo "  3. Running AnyLint ..."
echo "###########################"
if which anylint >/dev/null; then
  anylint
else
  echo "warning: AnyLint is not available."
  echo "Use 'brew tap Flinesoft/AnyLint https://github.com/Flinesoft/AnyLint.git && brew install swiftlint' to install AnyLint or download it manually from https://github.com/Flinesoft/AnyLint."
fi
