#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

echo -e "- Script directory: $BASEDIR --> Let's move to this directory"

cd $BASEDIR
cwd=$(pwd)

echo -e ""
echo -e "- Current workning directory: $cwd"

echo -e "- To avoid any git conflict we do a force pull first\n"
git fetch --all
git reset --hard origin/master



# Arg: string that contains the addon.xml content
# Return: version of the addon
function extract_addon_version() {
    local addon_xml_content="$1"
    local re="<addon([^>]+)>"
	if [[ $addon_xml_content =~ $re ]]; then
	    local addon_line=${BASH_REMATCH[0]}
	    local re='version="([^"]+)"'
	    if [[ $addon_line =~ $re ]]; then
	    	local version=${BASH_REMATCH[1]}
	    	echo $version
	   	fi
	fi
}



commit_msg="Auto update repo(s): "
need_to_commit_push="false"


# Krypton release repo
echo -e "\n# Check if we need to update the Krypton release official repository"

need_to_update_repo="no"

## plugin.video.catchuptvandmore
krypton_release_cutv_current_version="$(extract_addon_version "$(cat ./zips/krypton_release/plugin.video.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of plugin.video.catchuptvandmore on the repository is: $krypton_release_cutv_current_version"

krypton_release_cutv_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/master/plugin.video.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of plugin.video.catchuptvandmore on master branch available is: $krypton_release_cutv_last_version"

if [ "$krypton_release_cutv_current_version" != "$krypton_release_cutv_last_version" ]; then
	need_to_update_repo="yes"
fi


if [ "${need_to_update_repo}" == "yes" ]; then
	echo -e "\n\t--> Need to update this repository"
	
	commit_msg="$commit_msg Krypton release,"
	need_to_commit_push="true"

	echo -e "\t\t- Start create_repository.py on Krypton release repository"
	python ./create_repository.py \
		--datadir ./zips/krypton_release \
		--info ./addons_xmls/krypton_release/addons.xml \
		--checksum ./addons_xmls/krypton_release/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.release/ \
		https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore\#master:plugin.video.catchuptvandmore
else
	echo -e "\n\t--> No need to update this repository"
fi



# Krypton beta repo
echo -e "\n# Check if we need to update the Krypton beta official repository"

need_to_update_repo="no"

## plugin.video.catchuptvandmore
krypton_beta_cutv_current_version="$(extract_addon_version "$(cat ./zips/krypton_beta/plugin.video.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of plugin.video.catchuptvandmore is: $krypton_beta_cutv_current_version"

krypton_beta_cutv_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/dev/plugin.video.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of plugin.video.catchuptvandmore on dev branch available is: $krypton_beta_cutv_last_version"

if [ "$krypton_beta_cutv_current_version" != "$krypton_beta_cutv_last_version" ]; then
	need_to_update_repo="yes"
fi


if [ "${need_to_update_repo}" == "yes" ]; then
	echo -e "\n\t--> Need to update this repository"
	
	commit_msg="$commit_msg Krypton beta,"
	need_to_commit_push="true"

	echo -e "\t\t- Start create_repository.py on Krypton beta repository"
	python ./create_repository.py \
		--datadir ./zips/krypton_beta \
		--info ./addons_xmls/krypton_beta/addons.xml \
		--checksum ./addons_xmls/krypton_beta/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.beta/ \
		https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore\#dev:plugin.video.catchuptvandmore
else
	echo -e "\n\t--> No need to update this repository"
fi


# Commit and push if needed
if [ "$need_to_commit_push" == "true" ]; then
    echo -e "\n# Need to update one or more repos, need to commit/push on the GitHub repo\n"
    echo -e "\t* Commit message: $commit_msg"
    git add --all
    git commit -m "$commit_msg"
    git push
    echo -e "\t* Changes have been pushed"
else
	echo -e "\n# No change detected on any repos, no need to commit/push on the GitHub repo\n"
fi


