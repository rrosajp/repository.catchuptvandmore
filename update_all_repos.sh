#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

echo -e "- Script directory: $BASEDIR --> Let's move to this directory"

cd $BASEDIR
cwd=$(pwd)

echo -e ""
echo -e "- Current workning directory: $cwd"


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

## resource.images.catchuptvandmore
krypton_release_images_current_version="$(extract_addon_version "$(cat ./zips/krypton_release/resource.images.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of resource.images.catchuptvandmore on the repository is: $krypton_release_images_current_version"

krypton_release_images_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore/master/resource.images.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of resource.images.catchuptvandmore on master branch available is: $krypton_release_images_last_version"

if [ "$krypton_release_images_current_version" != "$krypton_release_images_last_version" ]; then
	need_to_update_repo="yes"
fi


if [ "${need_to_update_repo}" == "yes" ]; then
	echo -e "\n\t--> Need to update this repository"
	
	# Download cutv&m zip file from GitHub repo
	mkdir temp
	wget https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/archive/master.zip -q -P ./temp

	# Unzip cutv&m zip file
	unzip -q ./temp/master.zip -d ./temp

	# Set reuselanguageinvoker to true
	sed -i 's#<reuselanguageinvoker>false</reuselanguageinvoker>#<reuselanguageinvoker>true</reuselanguageinvoker>#g' ./temp/plugin.video.catchuptvandmore-master/plugin.video.catchuptvandmore/addon.xml

	# Update commit message
	commit_msg="$commit_msg Krypton release,"

	# Set need_to_commit_push to true in order to trigger a commit and push at the end of the script
	need_to_commit_push="true"

	# Update our Kodi repo with create_repository.py
	echo -e "\t\t- Start create_repository.py on Krypton release repository"
	python3 ./create_repository.py \
		--datadir ./zips/krypton_release \
		--info ./addons_xmls/krypton_release/addons.xml \
		--checksum ./addons_xmls/krypton_release/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.release/ \
		./temp/plugin.video.catchuptvandmore-master/plugin.video.catchuptvandmore/ \
		https://github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore\#master:resource.images.catchuptvandmore
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

## resource.images.catchuptvandmore
krypton_beta_images_current_version="$(extract_addon_version "$(cat ./zips/krypton_beta/resource.images.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of resource.images.catchuptvandmore on the repository is: $krypton_beta_images_current_version"

krypton_beta_images_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore/master/resource.images.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of resource.images.catchuptvandmore on master branch available is: $krypton_beta_images_last_version"

if [ "$krypton_beta_images_current_version" != "$krypton_beta_images_last_version" ]; then
	need_to_update_repo="yes"
fi


if [ "${need_to_update_repo}" == "yes" ]; then
	echo -e "\n\t--> Need to update this repository"

	# Download cutv&m zip file from GitHub repo
	mkdir temp
	wget https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/archive/dev.zip -q -P ./temp

	# Unzip cutv&m zip file
	unzip -q ./temp/dev.zip -d ./temp

	# Set reuselanguageinvoker to true
	sed -i 's#<reuselanguageinvoker>false</reuselanguageinvoker>#<reuselanguageinvoker>true</reuselanguageinvoker>#g' ./temp/plugin.video.catchuptvandmore-dev/plugin.video.catchuptvandmore/addon.xml
	
	# Update commit message
	commit_msg="$commit_msg Krypton beta,"
	
	# Set need_to_commit_push to true in order to trigger a commit and push at the end of the script
	need_to_commit_push="true"

	# Update our Kodi repo with create_repository.py
	echo -e "\t\t- Start create_repository.py on Krypton beta repository"
	python3 ./create_repository.py \
		--datadir ./zips/krypton_beta \
		--info ./addons_xmls/krypton_beta/addons.xml \
		--checksum ./addons_xmls/krypton_beta/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.krypton.beta/ \
		./temp/plugin.video.catchuptvandmore-dev/plugin.video.catchuptvandmore/ \
		https://github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore\#master:resource.images.catchuptvandmore
else
	echo -e "\n\t--> No need to update this repository"
fi


# Matrix beta repo
echo -e "\n# Check if we need to update the Matrix beta official repository"

need_to_update_repo="no"

## plugin.video.catchuptvandmore
matrix_beta_cutv_current_version="$(extract_addon_version "$(cat ./zips/matrix_beta/plugin.video.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of plugin.video.catchuptvandmore is: $matrix_beta_cutv_current_version"

matrix_beta_cutv_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/kodi19/plugin.video.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of plugin.video.catchuptvandmore on kodi19 branch available is: $matrix_beta_cutv_last_version"

if [ "$matrix_beta_cutv_current_version" != "$matrix_beta_cutv_last_version" ]; then
	need_to_update_repo="yes"
fi

## resource.images.catchuptvandmore
matrix_beta_images_current_version="$(extract_addon_version "$(cat ./zips/matrix_beta/resource.images.catchuptvandmore/addon.xml)")"
echo -e "\t* Version of resource.images.catchuptvandmore on the repository is: $matrix_beta_images_current_version"

matrix_beta_images_last_version="$(extract_addon_version "$(wget https://raw.github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore/master/resource.images.catchuptvandmore/addon.xml -q -O -)")"
echo -e "\t* Version of resource.images.catchuptvandmore on master branch available is: $matrix_beta_images_last_version"

if [ "$matrix_beta_images_current_version" != "$matrix_beta_images_last_version" ]; then
	need_to_update_repo="yes"
fi


if [ "${need_to_update_repo}" == "yes" ]; then
	echo -e "\n\t--> Need to update this repository"

	# Download cutv&m zip file from GitHub repo
	mkdir temp
	wget https://github.com/Catch-up-TV-and-More/plugin.video.catchuptvandmore/archive/kodi19.zip -q -P ./temp

	# Unzip cutv&m zip file
	unzip -q ./temp/kodi19.zip -d ./temp

	# Set reuselanguageinvoker to true
	sed -i 's#<reuselanguageinvoker>false</reuselanguageinvoker>#<reuselanguageinvoker>true</reuselanguageinvoker>#g' ./temp/plugin.video.catchuptvandmore-kodi19/plugin.video.catchuptvandmore/addon.xml
	
	# Update commit message
	commit_msg="$commit_msg Matrix beta,"
	
	# Set need_to_commit_push to true in order to trigger a commit and push at the end of the script
	need_to_commit_push="true"

	# Update our Kodi repo with create_repository.py
	echo -e "\t\t- Start create_repository.py on Matrix beta repository"
	python3 ./create_repository.py \
		--datadir ./zips/matrix_beta \
		--info ./addons_xmls/matrix_beta/addons.xml \
		--checksum ./addons_xmls/matrix_beta/addons.xml.md5 \
		./repo_addons_src/catchuptvandmore.kodi.matrix.beta/ \
		./temp/plugin.video.catchuptvandmore-kodi19/plugin.video.catchuptvandmore/ \
		https://github.com/Catch-up-TV-and-More/resource.images.catchuptvandmore\#master:resource.images.catchuptvandmore \
		https://github.com/Catch-up-TV-and-More/script.module.youtube.dl\#kodi19 \
		https://github.com/Catch-up-TV-and-More/script.module.codequick\#kodi19:script.module.codequick
else
	echo -e "\n\t--> No need to update this repository"
fi


# Commit and push if needed
if [ "$need_to_commit_push" == "true" ]; then

	# Remove temp folder
	rm -rf ./temp

	# Add all, commit and push
    echo -e "\n# Need to update one or more repos, need to commit/push on the GitHub repo\n"
    echo -e "\t* Commit message: $commit_msg"
    git add --all
    git commit -m "$commit_msg"
    git push
    echo -e "\t* Changes have been pushed"
else
	echo -e "\n# No change detected on any repos, no need to commit/push on the GitHub repo\n"
fi


