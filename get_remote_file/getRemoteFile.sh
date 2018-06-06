#!/bin/sh
#
# Copyright (c) 2018, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Corporate Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# Usage:  getRemoteFile.sh  [--email|-e]
#
# Get remote file as follows:
# - Download the remote file from URL_TARGET to FPATH_TARGET.
# - Abort if minimum file size (MIN_FILE_BYTES) is not met.
# - Only continue if the file is different from the one previously downloaded
#   (and kept) by this program.
# - Keep the specified number of backups.
# - Send a brief report to either STDOUT or to the specified email list.
#
##############################################################################
PATH=/bin:/usr/bin:/usr/local/bin; export PATH

APP=`basename $0`
TRUE="1"
FALSE=""

URL_TARGET="https://example.com/path/remotefile.txt"		# CUSTOMISE

DIR_TARGET=$HOME/cache						# CUSTOMISE
FPATH_TARGET=$DIR_TARGET/localfile.txt				# CUSTOMISE

MIN_FILE_BYTES=50000						# CUSTOMISE
NUM_BACKUPS=5							# CUSTOMISE

# Files used are:
# - $FPATH_TARGET:		Symlink to $FPATH_TARGET.0 (below)
# - $FPATH_TARGET.download:	Temporary downloaded file
# - $FPATH_TARGET.0:		The latest downloaded file
# - $FPATH_TARGET.1:		The 2nd latest downloaded file (1st backup)
# - $FPATH_TARGET.2:		The 3rd latest downloaded file (2nd backup)
# - ...
# - $FPATH_TARGET.$NUM_BACKUPS:	The oldest downloaded file (oldest backup)

EMAIL_LIST="me@example.com you@example.com"			# CUSTOMISE
EMAIL_SUBJECT_OK="Download remote file ($APP)"			# CUSTOMISE
EMAIL_SUBJECT_ERROR="ERROR: Download remote file ($APP)"	# CUSTOMISE

##############################################################################
# Optionally override any of the above variables.
ENV_FPATH="`echo \"$0\" |sed 's/\.sh$/_env.sh/'`"      # Path to THIS_env.sh
[ -f $ENV_FPATH ] && . $ENV_FPATH

##############################################################################
initialise() {
  [ ! -d $DIR_TARGET ] && {
    mkdir $DIR_TARGET
    [ $? != 0 ] && {
      msg="ERROR: Could not create the target directory."
      is_ok=$FALSE
    }
  }
}

##############################################################################
verify_file_size() {
  size_msg=`wc -c $FPATH_TARGET.download |
    head -1 |
    awk -v min_file_bytes=$MIN_FILE_BYTES '{
      if($1 >= min_file_bytes) {
        print "ok"
      } else {
        printf("File size (%d bytes) is too small (minimum is %d)\n", $1, min_file_bytes)
      }
    }'`

  [ "$size_msg" != ok ] && {
    rm -f $FPATH_TARGET.download
    msg="Download ERROR: $size_msg"
    is_ok=$FALSE
  }
}

##############################################################################
process_files() {
  # Take backups
  for i_next in `seq $NUM_BACKUPS -1 1`; do	# i_next = NUM_BACKUPS ... 3 2 1
    i=`expr $i_next - 1`			# i =  (NUM_BACKUPS-1) ... 2 1 0
    [ -f $FPATH_TARGET.$i ] && cp -fp $FPATH_TARGET.$i $FPATH_TARGET.$i_next
  done

  # Use the downloaded file & symlink to it
  mv -f $FPATH_TARGET.download $FPATH_TARGET.0
  ln -fs $FPATH_TARGET.0  $FPATH_TARGET
}

##############################################################################
download_remote_file() {
  msg=""
  is_ok=$TRUE
  initialise

  [ "$is_ok" ] && {
    curl --silent -o $FPATH_TARGET.download "$URL_TARGET"

    [ ! -f $FPATH_TARGET.download ] && {
      msg="ERROR: Unable to download the remote file from $URL_TARGET"
      is_ok=$FALSE

    } || {
      verify_file_size
    }
  }

  [ "$is_ok" ] && {
    # $is_ok remains true for both conditions below
    [ -f $FPATH_TARGET.0 ] && [ "`sum $FPATH_TARGET.0`" = "`sum $FPATH_TARGET.download`" ] && {
      msg="Downloaded file is identical to current file; discarding the downloaded file."
      rm -f $FPATH_TARGET.download

    } || {
      msg="Downloaded file is different from current file; we will use the downloaded file."
      process_files
    }
  }
}

##############################################################################
# Main
##############################################################################
download_remote_file

[ "$1" = --email -o "$1" = -e ] && {
  [ "$is_ok" ] && subject="$EMAIL_SUBJECT_OK" || subject="$EMAIL_SUBJECT_ERROR"
  echo "$msg" |mailx -s "$subject" $EMAIL_LIST

} || {
  echo "$msg"
}

