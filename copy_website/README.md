# FlindersMiniApps: copy_website

## Description

The copy_website.sh script does the following:
- Gets/downloads web pages from a web site
- Processes the pages downloaded from the web site

## Notes
- This script will require heavy customisation for a different
  application or site.
- The purpose of the processing (in this case) is to:
  * convert full html pages into partial html-body sections representing
    search results (eg. search results for items starting with letters
    A to Z)
  * dynamically insert those sections into a STEN html-template in order
    to build a complete web page
- This script does not create any STEN templates, php files which
  manipulate STEN tokens, etc.
- The sten_sample folder shows a skeleton of how the STEN web
  server folder might look (eg. where the sten_sample/az folder might
  be populated with files created by copy_website.sh)

For more information regarding STEN, see
https://github.com/grantj-re3/SimpleTemplateENgine-Sten

