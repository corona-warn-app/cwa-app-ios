#!zsh

print_usage()
{
    echo "Usage: adjust_version.sh [[[-v version ] [-b build]] | [-h]]"
}

### Main part of the script ###

version=
build_number=
script_dir=${0:a:h}

while [ "$1" != "" ]; do
    case $1 in
        -v | --version )        shift
                                version=$1
                                ;;
        -b | --build )          shift
                                build_number=$1
                                ;;
        -h | --help )           print_usage
                                exit
                                ;;
        * )                     print_usage
                                exit 1
    esac
    shift
done

# Validate arguments
version_length=`echo -n $version | wc -m`
buildnumber_length=`echo -n $build_number | wc -m`
if [[ ($version_length -eq 0) || ($buildnumber_length -eq 0) ]]; then
    print_usage
    exit 1
fi

# Change to project root
cd $script_dir/..

# Replace version for xmake
echo "${version}.${build_number}" > cfg/VERSION

# Replace version in .pbxproj
# Replace version
MARKETING_VERSION="MARKETING_VERSION = $version;"
sed "s,MARKETING_VERSION.*,$MARKETING_VERSION,g" src/xcode/ENA/ENA.xcodeproj/project.pbxproj > tmp.pbxproj
mv tmp.pbxproj src/xcode/ENA/ENA.xcodeproj/project.pbxproj

# Replace build number
PROJECT_VERSION="CURRENT_PROJECT_VERSION = $build_number;"
sed "s,CURRENT_PROJECT_VERSION.*,$PROJECT_VERSION,g" src/xcode/ENA/ENA.xcodeproj/project.pbxproj > tmp.pbxproj
mv tmp.pbxproj src/xcode/ENA/ENA.xcodeproj/project.pbxproj

