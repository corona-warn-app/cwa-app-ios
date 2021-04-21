#!/usr/bin/env zsh
set -euo pipefail

script_dir=${0:a:h}
cd $script_dir/../src/xcode/ENA/ENA/Resources/ServerEnvironment

serverEnvironments="{
	\"ServerEnvironments\":[
		{
			\"name\": \"Default\",
			\"distributionURL\": \"${SECRET_DIST_URL}\",
			\"submissionURL\": \"${SECRET_SUBM_URL}\",
			\"verificationURL\": \"${SECRET_VERIF_URL}\",
			\"dataDonationURL\": \"${SECRET_DATAD_URL}\"
		}
	]
}
"

echo $serverEnvironments > ServerEnvironments.json

cd -
