#!zsh
set -euo pipefail

script_dir=${0:a:h}
cd $script_dir/../src/xcode/ENA/ENA/Resources/ServerEnvironment

serverEnvironments="{
	\"ServerEnvironments\":[
		{
			\"name\": \"Production\",
			\"distributionURL\": \"${SECRET_DIST_URL}\",
			\"submissionURL\": \"${SECRET_SUBM_URL}\",
			\"verificationURL\": \"${SECRET_VERIF_URL}\"
		},
		{
			\"name\": \"ECME\",
			\"distributionURL\": \"${ACME_SECRET_DIST_URL}\",
			\"submissionURL\": \"${ACME_SECRET_SUBM_URL}\",
			\"verificationURL\": \"${ACME_SECRET_VERIF_URL}\"
		}
	]
}
"

echo $serverEnvironments > ServerEnvironments.json

cd -
