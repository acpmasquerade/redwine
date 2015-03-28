#!/bin/bash
list_file='urls.txt'
user_agent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.74 Safari/537.36'
root_url='https://some-domain.example.com/'
sitemap_path='en/sitemap.xml'
output_directory='mirror'
sitemap_local_cache='sitemap.mirror.xml'

current_dir=$(pwd)

if [ -f "${output_directory}" ]; then
	echo "Error: File exists with name ${output_directory}"
	exit
elif [ ! -d "${output_directory}" ] ; then
	mkdir "${output_directory}"
fi

echo "* HTTRACK will generate the static mirror inside directory - [${output_directory}]"
cd "${output_directory}"

# Step 1 : 
# Read the sitemap, and prepare the links
# Python Implementation
	# python mirror.py "${root_url}${sitemap_path}" > "${list_file}"
# Simple SED
echo "* Downloading the sitemap "
wget --quiet "${root_url}${sitemap_path}" -O "${sitemap_local_cache}"

sed -e 's#\(</\?loc>\)#\n\1\n#g' "${sitemap_local_cache}" | grep "^${root_url}" > "${list_file}"

# KN ( Keep original links )
# p1 (Download html files only)
# -%F (Footer option - <!-- mirroed from ... >)

if [ -d "hts-cache" ]; then
	echo "* Previous static mirror detected. Doing updates only"
	httrack --update
else
	echo "* Beginning for fresh mirror "
	httrack --list "${list_file}" -F "${user_agent}" -p1 --quiet -%F " "
fi

cd "${current_dir}"

echo ""
echo "* Done"
echo ""
exit
