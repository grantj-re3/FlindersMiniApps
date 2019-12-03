# FlindersMiniApps: wget2path

## Description

The wget2path.sh script does the following.

- Downloads a web resource from specified URL
  (eg. https://example.com/REL_PATH)
- Writes the resulting file to REL_PATH in the current directory


## Example

If URL_LIST is a file containing one URL per line, such as:

```
http://example.com/one/a.png
http://example.com/one/two/b.css
http://example.com/three/c.js
```

and you run the following from the (Linux) bash command line:

```
$ cat URL_LIST |while read url; do ./wget2path.sh "$url"; done
```

then the resulting file structure in the current directory will be:

```
one/a.png
one/two/b.css
three/c.js
```

