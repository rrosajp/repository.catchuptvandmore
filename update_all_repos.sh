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




echo -e "\n# Get addons versions currently on the repo\n"

krypton_beta_addon_xml=`cat ./zips/krypton_beta/plugin.video.catchuptvandmore/addon.xml`
krypton_beta_current_version=`extract_addon_version "$krypton_beta_addon_xml"`
echo -e "\t* Krypton beta addon version on the repo: $krypton_beta_current_version"

krypton_release_addon_xml=`cat ./zips/krypton_release/plugin.video.catchuptvandmore/addon.xml`
krypton_release_current_version=`extract_addon_version "$krypton_release_addon_xml"`
echo -e "\t* Krypton release addon version on the repo: $krypton_release_current_version"





echo -e "\n# Get last addons versions avaible on GitHub repos that contains the plugin sources\n"

krypton_beta_addon_xml=`wget https://raw.github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/dev/plugin.video.catchuptvandmore/addon.xml -q -O -`
krypton_beta_last_version=`extract_addon_version "$krypton_beta_addon_xml"`
echo -e "\t* Krypton beta addon last version: $krypton_beta_last_version"

krypton_release_addon_xml=`wget https://raw.github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/master/plugin.video.catchuptvandmore/addon.xml -q -O -`
krypton_release_last_version=`extract_addon_version "$krypton_release_addon_xml"`
echo -e "\t* Krypton release addon last version: $krypton_release_last_version"




echo -e "\n# Compare current and new version of all repos in order to commit/push if necessary\n"
commit_msg="Auto update repo(s): "
need_to_commit_push=false


if [ "$krypton_beta_current_version" == "$krypton_beta_last_version" ]
then
	echo -e "\t* Last version of Krypton beta already on the repo"
else
	echo -e "\t* New version detected for Krypton beta"
	commit_msg="$commit_msg Krypton beta,"
	need_to_commit_push=true

	echo -e "\t\t- Start create_repository.py on Krypton beta repo"
	python ./create_repository.py \
		--datadir ./zips/krypton_beta \
		--info ./addons_xmls/krypton_beta/addons.xml \
		--checksum ./addons_xmls/krypton_beta/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.beta/ \
		https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore\#dev:plugin.video.catchuptvandmore
fi


if [ "$krypton_release_current_version" == "$krypton_release_last_version" ]
then
	echo -e "\t* Last version of Krypton release already on the repo"
else
	echo -e "\t* New version detected for Krypton release"
	commit_msg="$commit_msg Krypton release,"
	need_to_commit_push=true

	echo -e "\t\t- Start create_repository.py on Krypton release repo"
	python ./create_repository.py \
		--datadir ./zips/krypton_release \
		--info ./addons_xmls/krypton_release/addons.xml \
		--checksum ./addons_xmls/krypton_release/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.release/ \
		https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore\#master:plugin.video.catchuptvandmore
fi







if [ "$need_to_commit_push" = true ]
then
    echo -e "\n# Change detected on one or more repos, need to commit/push on the GitHub repo\n"
    echo -e "\t* Commit message: $commit_msg"
    git add --all
    git commit -m "$commit_msg"
    git push
    echo -e "\t* Changes have been pushed"
else
	echo -e "\n# No change detected on any repos, no need to commit/push on the GitHub repo\n"
fi


exit 0






