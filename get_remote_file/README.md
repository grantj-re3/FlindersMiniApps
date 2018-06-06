# FlindersMiniApps: get_remote_file

## Description

The getRemoteFile.sh script is a wrapper for the curl program.

It does the following.

- Downloads the remote file from URL_TARGET to FPATH_TARGET.
- Aborts if the minimum file size (MIN_FILE_BYTES) is not met.
- Only continues if the file is different from the one previously downloaded
  (and kept) by this program.
- Keeps the specified number of backups.
- Sends a brief report to either STDOUT or to the specified email list.

