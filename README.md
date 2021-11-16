# Setup-Letsencrypt script

This script can be used to deploy automatic Letsencrypt certificates on a webserver faster.
The script sets up a crown job for you __(Feature is planned and not implemented yet
<a href="https://github.com/DanielsLPecke/setup-letsencrypt/issues/3">#3</a>)__.
The automatic refreshing of the certificates will be set up using this way: https://sunweavers.net/blog/node/71

# Build process
In order to make the workflow as efficient as possible (simply copying a single script back and forth),
we decided that the script would first be built from several files with the help of `make`.
The `make` call  replaces all strings of the format `@B64:path/to/file.txt@` in file `setup-letsencrypt.sh.in`
by the base64 encoded representation of that script. This greatly simplifies development as all files are
now available in the code tree in plain text (not base64-encoded embedded in a shell script).

 - Simply execute `make` or `make build` in the base folder of this code project.
 - You now have a portable `setup-letsencrypt.sh` script ready to be deployed.

# Usage

./setup-letsencrypt.sh <server_hostname>

* <server_hostname>:
  * The hostname or domain of the webserver which requests the letsencrypt certificate.
  * For example server.example.org
