from xmlutils.xml2json import xml2json

import sys
import json
import urllib3
import os

import re

def download(url):
    http = urllib3.PoolManager(
        cert_reqs='CERT_REQUIRED', # Force certificate check.
        ca_certs=certifi.where(),  # Path to the Certifi bundle.
    )

    resp = http.request('GET', url)

    # we didn't get a valid response, bail
    if 200 != resp.status:
        return False

    sitemap_filename = "sitemap.mirror.xml"

    file = open(sitemap_filename, "w")
    file.write(resp.data)
    file.close()

    return sitemap_filename

try:
    sitemap_filename = sys.argv[1]
    if sitemap_filename.startswith("http://") or sitemap_filename.startswith("https://"):
        sitemap_filename = download(sitemap_filename)
        if sitemap_filename is False:
            print "Unable to download content"
            sys.exit(-1)

except: 
    print "Please provide a sitemap file or url"
    sys.exit(-1)

if not os.path.isfile(sitemap_filename):
    print "File not found"
    sys.exit(-1)

converter = xml2json(sitemap_filename)

sitemap = converter.get_json()

regex = re.compile(r'{http:\/\/www.sitemaps.org\/.*}')
clean_json = regex.subn("", sitemap)

sitemap_dict = json.loads(clean_json[0])
urls = sitemap_dict['urlset']['url']

urls_file = open("urls.txt", "w")
for some_url in urls:
	loc = some_url.get('loc', None)
	urls_file.write(loc+"\n")	

urls_file.close()

print "URLs written to urls.txt"
		
