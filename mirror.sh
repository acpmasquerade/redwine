#!/bin/bash
list_file='urls.txt'
user_agent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.74 Safari/537.36'
source_url='https://mirror.example.com/en/'
sitemap_path='sitemap.xml'
output_directory='mirror'
sitemap_local_cache='sitemap.mirror.xml'
site_url='http://www.example.com/' # deploy site url

current_dir=$(pwd)

function mkdir_safe {
	if [ -f "${1}" ]; then
		echo "Error: File exists with name ${1}"
		exit
	elif [ ! -d "${1}" ] ; then
		mkdir "${1}"
	fi
}

mkdir_safe "${output_directory}"
output_directory_raw="${output_directory}_raw"
mkdir_safe "${output_directory_raw}"

cd "${output_directory_raw}"

# Step 1 : 
# Read the sitemap, and prepare the links
# Python Implementation
	# python mirror.py "${source_url}${sitemap_path}" > "${list_file}"
# Simple SED
echo "* Downloading the sitemap ${source_url}${sitemap_path}"
wget -c --quiet "${source_url}${sitemap_path}" -O "${sitemap_local_cache}"

# Extract links from sitemap
sed -e 's#\(</\?loc>\)#\n\1\n#g' "${sitemap_local_cache}" | grep "^${source_url}"  > "${list_file}"

# KN ( Keep original links )
# p1 (Download html files only)
# -%F (Footer option - <!-- mirroed from ... >)

#if [ -d "hts-cache" ]; then
#	echo "* Previous static mirror detected. Doing updates only"
#	httrack --update
#else
#	echo "* Beginning for fresh mirror "
#	httrack --list "${list_file}" -F "${user_agent}" -p1 --quiet -%F " "
#fi

for some_link in $(cat ${list_file})
do
	echo "Fetching ... ${some_link}"
	wget --quiet -x -c "${some_link}"
done

cd "${current_dir}"
echo "* Copying raw downloads to ${output_directory} for fixing links"
cp -r "./${output_directory_raw}" "./${output_directory}"

#relative_root=$(echo "${source_url}" | sed "s#^http(s)?://[^/]+##g")
relative_root=$(echo "${source_url}" | sed 's/http\(s\)\?:\/\/[^\/]\+//g')

echo "* Relative root will be replaced as ${relative_root} -> ${site_url}"
echo "* Absolute root will be replaced as ${source_url} -> ${site_url}"

cd "${output_directory}"

file_prefix_for_subroot=$(echo ${source_url} | sed "s#http\(s\)://#./#g")

for mirror_file in $(find -type f -name "*.html" )
do
	echo "Fixing for file ${mirror_file}"
	# Replace Absolute URLS first
	sed -i "s#\(src\|href\|value\)=\(\"\|'\)\(${source_url}\|${relative_root}\)#\1=\2${site_url}#g" "${mirror_file}"
	current_root=$(echo ${mirror_file} | sed "s#^${file_prefix_for_subroot}\(.*\)/index.html#\1/#g")
	# Replace Relative urls
	# sed -i "s#\(src\|href\|value\)=\(\"\|'\)${relative_root}#\1=\2${site_url}#g" "${mirror_file}"
	sed -i "s#\(src\|href\|value\)=\(\"\|'\)\(\?!\(http\(s\)\?://\|${relative_root}\)\)#\1=\2${site_url}${current_root}#g" "${mirror_file}"
done

cd "${current_directory}"

echo ""
echo "* Done"
echo ""
exit

