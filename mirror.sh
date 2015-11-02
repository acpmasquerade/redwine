#!/bin/bash

#------------------Configuration------------------------------#
#------------------Configuration------------------------------#
#------------------Configuration------------------------------#

# 1. -------------------- Source --------------------------- #
source_url='https://mirror.some-site.com/en/' # Source ROOT.
site_url='http://www.some-site.com/' # deploy site url
sitemap_path='sitemap.xml' # Path for sitemap, relative to root

# 2. ----------- Temporary / output files, dirs -------------#
list_file='urls.txt' # Temporary file to save the links.
output_directory='mirror' # directory to output. <directory>_raw will also be created
sitemap_local_cache='sitemap.mirror.xml' # cache file to save the sitemap

# 3. ------------ Other Flags / Settings --------------------#
nodownload="0" # Don't download, simply run for existing files.
user_agent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.74 Safari/537.36'

#------------------- Configuration Ends ----------------------#


#----------------- Do not Change -----------------------------#
#----------------- Do not Change -----------------------------#
#----------------- Do not Change -----------------------------#

current_dir=$(pwd)

function mkdir_safe {
        if [ -f "${1}" ]; then
                echo "Error: File exists with name ${1}"
                exit
        elif [ ! -d "${1}" ] ; then
                mkdir "${1}"
        fi
}

# Create required directories
mkdir_safe "${output_directory}"
output_directory_raw="${output_directory}_raw"
mkdir_safe "${output_directory_raw}"

cd "${output_directory_raw}"

# Read the sitemap, and prepare the links
echo "* Downloading the sitemap ${source_url}${sitemap_path}"
if [ "${nodownload}" == "0" ]; then
        wget -c --quiet -U "${user_agent}" "${source_url}${sitemap_path}" -O "${sitemap_local_cache}"
fi

# Extract links from sitemap
sed -e 's#\(</\?loc>\)#\n\1\n#g' "${sitemap_local_cache}" | grep "^${source_url}"  > "${list_file}"

for some_link in $(cat ${list_file})
do
        echo "Fetching ... ${some_link}"
        if [ "${nodownload}" == "0" ]; then
                wget --quiet -x -c -U "${user_agent}" "${some_link}"
        fi
done

cd "${current_dir}"

echo ${output_directory}
echo ${output_directory_raw}
echo "* Copying raw downloads to ${output_directory} for fixing links"
rsync -r "${output_directory_raw}/" "${output_directory}"

relative_root=$(echo "${source_url}" | sed 's/http\(s\)\?:\/\/[^\/]\+//g')

echo "* Relative root will be replaced as ${relative_root} -> ${site_url}"
echo "* Absolute root will be replaced as ${source_url} -> ${site_url}"

cd "${output_directory}"

file_prefix_for_subroot=$(echo ${source_url} | sed "s#http\(s\)://#./#g")

# Replace links to fix for the new Mirror (Deploy) URL
for mirror_file in $(find -type f -name "*.html" )
do
        echo "Fixing for file ${mirror_file}"
        # Replace Absolute URLS first
        sed -i "s#\(src\|href\|value\)=\(\"\|'\)\(${source_url}\|${relative_root}\)#\1=\2${site_url}#g" "${mirror_file}"
        current_root=$(echo ${mirror_file} | sed "s#^${file_prefix_for_subroot}\(.*\)/index.html#\1/#g")
        # Replace Relative urls
        p_attrs="\(src\|href\|value\)"
        p_url="\(\"\|'\)\(\?!\(http\(s\)\?://\|${relative_root}\)\)"
        sed -i "s#${p_attrs}=${p_url}#\1=\2${site_url}${current_root}#g" "${mirror_file}"
done

cd "${current_directory}"

echo ""
echo "* Done"
echo ""
exit


