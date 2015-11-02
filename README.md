# redwine
Generate static HTML files from the sitemap of any dynamic website.

# Sample Use Case
* If you CMS sucks, use few rules of HTTRACK and generate static files to host with your CDN.

PS: Might not be useful for everyone, but I am using this deployment method, where the CMS uploads the static / media contents automatically to the CDN provider, and this script generates the HTML.

Let me know if it works for you as well. 

# Available configuration options (mirror.sh file)
````
  list_file='urls.txt'
  user_agent='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.74 Safari/537.36'
  root_url='https://some-domain.example.com/'
  sitemap_path='en/sitemap.xml'
  output_directory='mirror'
  sitemap_local_cache='sitemap.mirror.xml'
````
