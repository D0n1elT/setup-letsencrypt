# Setup-Letsencrypt script

This script can be used to deploy automatic Letsencrypt certificates on a webserver faster.
The script sets up a crown job for you __(Feature is planned and not implemented yet
<a href="https://github.com/DanielsLPecke/setup-letsencrypt/issues/3">#3</a>)__.
The automatic refreshing of the certificates will be set up using this way: https://sunweavers.net/blog/node/71

# Usage

./setup-letsencrypt.sh <server_hostname>

* <server_hostname>:
  * The hostname or domain of the webserver which requests the letsencrypt certificate.
  * For example server.example.org


  
