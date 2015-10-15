#!/bin/sh
#
# Copyright (c) 2015, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Information Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# This script does the following:
# - Get/download web pages from web site [Option: -g]
# - Process the pages downloaded from the web site [Option: -p]
#
# Notes:
# - See usage_exit() for usage information.
# - This script will require heavy customisation for a different
#   application/site.
# - The purpose of the processing (in this case) is to:
#   * convert full html pages into partial html-body sections representing
#     search results
#   * dynamically insert those sections into a STEN html-template in order
#     to build a complete web page (see
#     https://github.com/grantj-re3/SimpleTemplateENgine-Sten)
# - This script does not create any STEN templates, php files which
#   manipulate STEN tokens, etc.
#
##############################################################################
url_main="http://example.com/myscript?x=xx&y=yy&z=zz"
url_az_part="http://example.com/myscript?x=x1&y=y1&z=z1"
url_jr_part="http://example.com/myscript?x=x2&y=y2&z=z2"

dir_az1="cws_az_get"
dir_az2="cws_az_proc"

dir_jr1="cws_jur_temp"
dir_jr2="cws_jur_get"
dir_jr3="cws_jur_proc"

fname_main="main.html"
fname_jr="jurisdictions.txt"

cmd_wget="wget --no-verbose"

##############################################################################
get_pages_az() {
  echo "Getting pages: A-Z"
  mkdir $dir_az1 $dir_az2  2>/dev/null

  for letter in {a..z}; do
    echo
    echo "Letter: '$letter'"
    fname="$letter.html"
    url_az="${url_az_part}&az=$letter"
    $cmd_wget -O $dir_az1/$fname "$url_az"
  done
}

##############################################################################
process_pages_az() {
  echo "Processing pages: A-Z"
  mkdir $dir_az1 $dir_az2  2>/dev/null

  for letter in {a..z}; do
    echo
    echo "Letter: '$letter'"
    fname="$letter.html"
    fname_out="$letter.inc.html"

    echo "Extracting search results to $dir_az2/$fname_out"

    exit_if_bad_file $dir_az1/$fname
    if egrep -q "FMP-IWPErr.js" $dir_az1/$fname; then
      # No results for this letter
      cat <<-EOMSG_EMPTY > $dir_az2/$fname_out
		<!-- Results --><div>
		  <p><strong>Search Results</strong><br />
		  <font face="arial, helvetica, sans-serif" size=1 color="4A293A"> (No records found) </font>
		</div>
	EOMSG_EMPTY

    else
      extract_search_results $dir_az1/$fname > $dir_az2/$fname_out
    fi
  done
}

##############################################################################
get_pages_jurisdiction() {
  echo "Getting pages: Jurisdiction"
  mkdir $dir_jr1 $dir_jr2 $dir_jr3 2>/dev/null

  # Get main web page
  $cmd_wget -O $dir_jr1/$fname_main "$url_main"

  # Extract jurisdictions into a file
  cat $dir_jr1/$fname_main |
    tr -d '\r' |
    awk '
      # Extract jurisdictions from the select-element
      BEGIN {enable=0}
      /<select *name="Jurisdiction"/ {enable=1}

      enable==1 && /<option> /{
        m1 = gensub("^.*<option> ", "", "")
        m2 = gensub("</option>.*$", "", "", m1)
        print m2
      }

      /<\/select>/ {enable=0}
    ' > $dir_jr1/$fname_jr

  # Get web page for each jurisdiction
  cat $dir_jr1/$fname_jr |
    while read j; do
      echo
      echo "Jurisdiction: '$j'"
      fname="$j.html"		# This filename will typically contain spaces
      url_jr="${url_jr_part}&Jurisdiction=$j"

      cmd="$cmd_wget -O \"$dir_jr2/$fname\" \"$url_jr\""
      echo "$cmd"
      eval $cmd
    done
}

##############################################################################
process_pages_jurisdiction() {
  echo "Processing pages: Jurisdiction"
  mkdir $dir_jr1 $dir_jr2 $dir_jr3 2>/dev/null

  exit_if_bad_file $dir_jr1/$fname_jr
  while read j; do
    echo
    echo "Jurisdiction: '$j'"
    fname="$j.html"		# This filename will typically contain spaces
    fname_out="$j.inc.html"	# This filename will typically contain spaces

    echo "Extracting search results to $dir_jr3/$fname_out"

    # Loop must not be subshell for this exit_if_bad_file() to exit script
    exit_if_bad_file "$dir_jr2/$fname"
    extract_search_results "$dir_jr2/$fname" > "$dir_jr3/$fname_out"
  done < $dir_jr1/$fname_jr	# Loop without creating a subshell
}

##############################################################################
extract_search_results() {
  cat "$1" |
    tr -d '\r' |
    awk '
      BEGIN {enable=0}

      # Start output with this line
      /<\!-- Results --><div>/ {enable=1}

      # Stop output BEFORE this line
      /<script type="text\/javascript">/ {enable=0}

      enable==1 {print}
    '
}

##############################################################################
process_main_page() {
  # Replace A-Z links (a-tags) with links to static pages.
  #
  # This will allow our a-tags to do POST rather than GET.
  # That is:  href="FMPro?...&az=z&..."
  # becomes:  onclick="post('abbr.php', {t: 'az', q: 'z'})" href="javascript:void(0)"
  echo
  echo "Processing main page"

  exit_if_bad_file $dir_jr1/$fname_main
  cat $dir_jr1/$fname_main |
    tr -d '\r' |
    awk '
      {print $0}

      # Point to JavaScript which implements post() method
      /jquery.collapse.js/ {
        print "  <script type=\"text/javascript\" src=\"common/helper.js\"></script>"
      }
    ' |
    sed '
      s~href="FMPro?[^"]*az=\(.\)[^"]*"~onclick="post('\''abbr.php'\'', {t: '\''az'\'', q: '\''\1'\''})" href="javascript:void(0)"~g
    ' > $dir_jr1/${fname_main}.az_post
}

##############################################################################
exit_if_bad_file() {
  fpath="$1"
  [ ! -f "$fpath" ] && usage_exit "File not found: '$fpath'" 1
}

##############################################################################
usage_exit() {
  msg="$1"
  exit_code="${2:-0}"

  if [ "$msg" != "" ]; then
    echo "$msg" >&2
    echo >&2
  fi

  echo "Usage:  `basename $0`  --get|-g  |  --process|-p" >&2
  echo "First get/download the web pages, then process the downloaded pages" >&2
  exit "$exit_code"
}

##############################################################################
get_command_line_opts() {
  if [ "$1" = --get -o "$1" = -g ]; then
    opt1="get"		# Get web pages

  elif [ "$1" = --process -o "$1" = -p ]; then
    opt1="process"	# Process web pages (assumes we've done a get first)

  elif [ "$1" = --help -o "$1" = -h ]; then
    usage_exit "" 0

  else
    usage_exit "" 2
  fi
}

##############################################################################
# Main()
##############################################################################
get_command_line_opts $@

eval "${opt1}_pages_az"
eval "${opt1}_pages_jurisdiction"
[ $opt1 = process ] && process_main_page

