#!/bin/sh
#
# Copyright (c) 2019, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Corporate Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# Usage:  wget2path.sh  URL
#
##############################################################################
app=`basename $0`

if [ "$1" = "" ]; then
  cat <<-END_OF_MSG
	Usage:  $app  URL

	Download a web resource from URL (eg. https://example.com/REL_PATH)
	and write the resulting file to REL_PATH in the current directory.
	END_OF_MSG
  exit 1
fi

if ! echo "$1" |egrep -q "https?://"; then
  echo "URL must start with either http:// or https://" >&2
  exit 1
fi

##############################################################################
# FIXME: Add sanity checks
url="$1"
fpath=`echo "$url" |sed 's:^https\{0,1\}\://::; s:^[^/]*/*::'`

# FIXME: Remove this parent directory from the destination path
#fpath=`echo "$fpath" |sed 's:^flinders/::'`

dirpath=`dirname "$fpath"`
fbase=`basename "$fpath"`

echo "INFO|$fbase|$url|$fpath|$dirpath|"
wget -nv -O "$fbase"  "$url"
res=$?

if [ $res = 0 ]; then
  echo "RESULT|PASS|$fbase|$res|"
  mkdir -p "$dirpath"
  mv -f "$fbase" "$fpath"
  echo "SUM|$fbase|`sum \"$fpath\"`|"

else
  echo "RESULT|FAIL|$fbase|$res|"
  rm -f "$fbase"
fi

echo

