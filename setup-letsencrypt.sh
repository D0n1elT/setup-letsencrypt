#!/bin/bash

certconfigdir="/root/SSL-Certs"
setup_apache=true
letsencrypt_username="letsencrypt"
letsencrypt_user_home="/var/lib/$letsencrypt_username"

logfile="$(pwd)/letsencrypt-setup-log.txt"
touch $logfile
chmod 664 $logfile

debugmode=false

FQDN="$1"
FQDNunderscores="$(echo $FQDN | sed 's/\./_/g')"

echo "---$(date)---" >> $logfile

if [ -z "$FQDNunderscores" ]; then
	echo "You didn't provide a FQDN!"
	echo "Didn't provide FQDN" >> $logfile
	exit;
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root!"
  echo "Script was run without root permissions by '$(whoami)'" >> $logfile
  exit
fi

echo "Setting up automatic letsencrypt SSL-Certification"

echo "Provided FQDN: $FQDN"
echo "Provided FQDN: $FQDN" >> $logfile

echo "Setting up Apache2: $setup_apache"
echo "Apache2: $setup_apache" >> $logfile

echo "Certification-Config directory will be created in $certconfigdir"
echo "Cert-Configs Directory: $certconfigdir" >> $logfile

echo "Setting up with user '$letsencrypt_username' with home '$letsencrypt_user_home'"
echo "User: $letsencrypt_username with home $letsencrypt_user_home" >> $logfile

param=$2
if [ -n $param ]; then
	if [ "$param" = "true" ]; then
		debugmode=true
	fi
fi

if [ "$debugmode" = true ]; then
	echo "Running in debug mode!"
fi


####################
#####INSTALLING#####
####################


### Installing Base64 ###
echo "Installing Base64 via APT"
#apt install base64
#TODO: SEARCH BASE64 PACKET
echo "OK"


### Making directory $certconfigdir ###
echo "Creating cert. config directory"
#mkdir $certconfigdir
test -d "$certconfigdir" || mkdir -p "$certconfigdir"
echo "OK"


### Deploying web_certrequest.sh ###
echo "Deploying web_certrequest.sh"
if ! [ -s "$certconfigdir/web_certrequest.sh" ]; then
	echo "IyEvYmluL2Jhc2gKCkZRRE49IiQxIgpGUUROdW5kZXJzY29yZXM9IiQoZWNobyAkRlFETiB8IHNlZCAncy9cLi9fL2cnKSIKCmJhc2U9IiQocHdkKSIKCnRlc3QgLWQgIiRiYXNlL3ByaXZhdGUiIHx8IG1rZGlyIC1wICIkYmFzZS9wcml2YXRlIgoKaWYgWyAtZiAiJGJhc2UvcHJpdmF0ZS8ke0ZRRE51bmRlcnNjb3Jlc30ua2V5IiBdOyB0aGVuCiAgICAgICAgb3BlbnNzbCAgcmVxICAtY29uZmlnICIkYmFzZS9vcGVuc3NsOjoke0ZRRE51bmRlcnNjb3Jlc30uY25mIiBcCiAgICAgICAgICAgICAgICAgICAgICAtbm9kZXMgIC1uZXcgXAogICAgICAgICAgICAgICAgICAgICAgLWtleSAiJGJhc2UvcHJpdmF0ZS8ke0ZRRE51bmRlcnNjb3Jlc30ua2V5IiBcCiAgICAgICAgICAgICAgICAgIC1vdXQgIiRiYXNlLyR7RlFETnVuZGVyc2NvcmVzfS5jc3IiCmVsc2UKICAgIG9wZW5zc2wgIHJlcSAgLWNvbmZpZyAiJGJhc2Uvb3BlbnNzbDo6JHtGUUROdW5kZXJzY29yZXN9LmNuZiIgXAogICAgICAgICAgICAgICAgICAtbm9kZXMgIC1uZXcgXAogICAgICAgICAgICAgICAgICAta2V5b3V0ICIkYmFzZS9wcml2YXRlLyR7RlFETnVuZGVyc2NvcmVzfS5rZXkiIFwKICAgICAgICAgICAgICAgICAgLW91dCAiJGJhc2UvJHtGUUROdW5kZXJzY29yZXN9LmNzciIKZmkK" | base64 -d - > "$certconfigdir/web_certrequest.sh"
else
	echo "Web_certrequest.sh was already deployed."
fi
echo "OK"

echo "Set permission for web_certrequest.sh"
chmod 755 "$certconfigdir/web_certrequest.sh"
echo "OK"


### Deploying openssl config ###
echo "Deploying openssl config"
if ! [ -s "$certconfigdir/openssl::$FQDNunderscores.cnf" ]; then
	#echo "WyByZXEgXQpkZWZhdWx0X2JpdHMgICAgICAgICAgICA9IDQwOTYgICAgICAgICAgICAgICAgICAjIFNpemUgb2Yga2V5cwpkaXN0aW5ndWlzaGVkX25hbWUgICAgICA9IHJlcV9kaXN0aW5ndWlzaGVkX25hbWUKcmVxX2V4dGVuc2lvbnMgICAgICAgICAgPSB2M19yZXEKeDUwOV9leHRlbnNpb25zICAgICAgICAgPSB2M19yZXEKClsgcmVxX2Rpc3Rpbmd1aXNoZWRfbmFtZSBdCiMgVmFyaWFibGUgbmFtZSAgICAgICAgICAgUHJvbXB0IHN0cmluZwojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSAgIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lICAgICAgPSBPcmdhbml6YXRpb24gTmFtZSAoY29tcGFueSkKb3JnYW5pemF0aW9uYWxVbml0TmFtZSAgPSBPcmdhbml6YXRpb25hbCBVbml0IE5hbWUgKGRlcGFydG1lbnQsIGRpdmlzaW9uKQplbWFpbEFkZHJlc3MgICAgICAgICAgICA9IEVtYWlsIEFkZHJlc3MKZW1haWxBZGRyZXNzX21heCAgICAgICAgPSA0MApsb2NhbGl0eU5hbWUgICAgICAgICAgICA9IExvY2FsaXR5IE5hbWUgKGNpdHksIGRpc3RyaWN0KQpzdGF0ZU9yUHJvdmluY2VOYW1lICAgICA9IFN0YXRlIG9yIFByb3ZpbmNlIE5hbWUgKGZ1bGwgbmFtZSkKY291bnRyeU5hbWUgICAgICAgICAgICAgPSBDb3VudHJ5IE5hbWUgKDIgbGV0dGVyIGNvZGUpCmNvdW50cnlOYW1lX21pbiAgICAgICAgID0gMgpjb3VudHJ5TmFtZV9tYXggICAgICAgICA9IDIKY29tbW9uTmFtZSAgICAgICAgICAgICAgPSBDb21tb24gTmFtZSAoaG9zdG5hbWUsIElQLCBvciB5b3VyIG5hbWUpCmNvbW1vbk5hbWVfbWF4ICAgICAgICAgID0gNjQKCiMgRGVmYXVsdCB2YWx1ZXMgZm9yIHRoZSBhYm92ZSwgZm9yIGNvbnNpc3RlbmN5IGFuZCBsZXNzIHR5cGluZy4KIyBWYXJpYWJsZSBuYW1lICAgICAgICAgICAgICAgICAgIFZhbHVlCiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lX2RlZmF1bHQgICAgICA9IE15IENvbXBhbnkgICAgICAgICAgICAgICMgYWRhcHQgYXMgbmVlZGVkCmxvY2FsaXR5TmFtZV9kZWZhdWx0ICAgICAgICAgICAgPSBNeSBDaXR5ICAgICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZApzdGF0ZU9yUHJvdmluY2VOYW1lX2RlZmF1bHQgICAgID0gTXkgQ291bnR5L1N0YXRlICAgICAgICAgIyBhZGFwdCBhcyBuZWVkZWQKY291bnRyeU5hbWVfZGVmYXVsdCAgICAgICAgICAgICA9IEMgICAgICAgICAgICAgICAgICAgICAgICMgY291bnRyeSBjb2RlOiBlLmcuIERFIGZvciBHZXJtYW55CmNvbW1vbk5hbWVfZGVmYXVsdCAgICAgICAgICAgICAgPSBob3N0LmV4YW1wbGUuY29tICAgICAgICAjIGhvc3RuYW1lIG9mIHRoZSB3ZWJzZXJ2ZXIKZW1haWxBZGRyZXNzX2RlZmF1bHQgICAgICAgICAgICA9IGhvc3RtYXN0ZXJzQGV4YW1wbGUuY29tICMgYWRhcHQgYXMgbmVlZGVkCm9yZ2FuaXphdGlvbmFsVW5pdE5hbWVfZGVmYXVsdCAgPSBXZWJtYXN0ZXJ5ICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZAoKWyB2M19yZXEgXQojIEV4dGVuc2lvbnMgdG8gYWRkIHRvIGEgY2VydGlmaWNhdGUgcmVxdWVzdApiYXNpY0NvbnN0cmFpbnRzID0gQ0E6RkFMU0UKa2V5VXNhZ2UgPSBub25SZXB1ZGlhdGlvbiwgZGlnaXRhbFNpZ25hdHVyZSwga2V5RW5jaXBoZXJtZW50LCBrZXlFbmNpcGhlcm1lbnQsIGRhdGFFbmNpcGhlcm1lbnQsIGtleUFncmVlbWVudAoKIyBTb21lIENBcyBkbyBub3QgeWV0IHN1cHBvcnQgc3ViamVjdEFsdE5hbWUgaW4gQ1NScy4KIyBJbnN0ZWFkIHRoZSBhZGRpdGlvbmFsIG5hbWVzIGFyZSBmb3JtIGVudHJpZXMgb24gd2ViCiMgcGFnZXMgd2hlcmUgb25lIHJlcXVlc3RzIHRoZSBjZXJ0aWZpY2F0ZS4uLgpzdWJqZWN0QWx0TmFtZSAgICAgICAgICA9IEBhbHRfbmFtZXMKClthbHRfbmFtZXNdCiMjIyBob3N0LmV4YW1wbGUuY29tIGlzIHRoZSBGUUROCkROUy4xID0gaG9zdC5leGFtcGxlLmNvbQpETlMuMiA9IHd3dy5leGFtcGxlLmNvbQpETlMuMyA9IGV4YW1wbGUuY29tCkROUy40ID0gd2lraS5leGFtcGxlLmNvbQpETlMuNSA9IHd3dy5vbGQtY29tcGFueS1uYW1lLmJpeg==" | base64 -d - > "$certconfigdir/openssl::$FQDNunderscores.cnf"
	#echo "WyByZXFfZGlzdGluZ3Vpc2hlZF9uYW1lIF0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEQVBUIEhFUkUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lX2RlZmF1bHQgICAgICA9IE15IENvbXBhbnkgICAgICAgICAgICAgICMgYWRhcHQgYXMgbmVlZGVkCmxvY2FsaXR5TmFtZV9kZWZhdWx0ICAgICAgICAgICAgPSBNeSBDaXR5ICAgICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZApzdGF0ZU9yUHJvdmluY2VOYW1lX2RlZmF1bHQgICAgID0gTXkgQ291bnR5L1N0YXRlICAgICAgICAgIyBhZGFwdCBhcyBuZWVkZWQKY291bnRyeU5hbWVfZGVmYXVsdCAgICAgICAgICAgICA9IERFICAgICAgICAgICAgICAgICAgICAgICMgY291bnRyeSBjb2RlOiBlLmcuIERFIGZvciBHZXJtYW55CmNvbW1vbk5hbWVfZGVmYXVsdCAgICAgICAgICAgICAgPSBob3N0LmV4YW1wbGUuY29tICAgICAgICAjIGhvc3RuYW1lIG9mIHRoZSB3ZWJzZXJ2ZXIKZW1haWxBZGRyZXNzX2RlZmF1bHQgICAgICAgICAgICA9IGhvc3RtYXN0ZXJzQGV4YW1wbGUuY29tICMgYWRhcHQgYXMgbmVlZGVkCm9yZ2FuaXphdGlvbmFsVW5pdE5hbWVfZGVmYXVsdCAgPSBXZWJtYXN0ZXJ5ICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZAoKMC5vcmdhbml6YXRpb25OYW1lICAgICAgPSBPcmdhbml6YXRpb24gTmFtZSAoY29tcGFueSkKb3JnYW5pemF0aW9uYWxVbml0TmFtZSAgPSBPcmdhbml6YXRpb25hbCBVbml0IE5hbWUgKGRlcGFydG1lbnQsIGRpdmlzaW9uKQplbWFpbEFkZHJlc3MgICAgICAgICAgICA9IEVtYWlsIEFkZHJlc3MKZW1haWxBZGRyZXNzX21heCAgICAgICAgPSA0MApsb2NhbGl0eU5hbWUgICAgICAgICAgICA9IExvY2FsaXR5IE5hbWUgKGNpdHksIGRpc3RyaWN0KQpzdGF0ZU9yUHJvdmluY2VOYW1lICAgICA9IFN0YXRlIG9yIFByb3ZpbmNlIE5hbWUgKGZ1bGwgbmFtZSkKY291bnRyeU5hbWUgICAgICAgICAgICAgPSBDb3VudHJ5IE5hbWUgKDIgbGV0dGVyIGNvZGUpCmNvdW50cnlOYW1lX21pbiAgICAgICAgID0gMgpjb3VudHJ5TmFtZV9tYXggICAgICAgICA9IDIKY29tbW9uTmFtZSAgICAgICAgICAgICAgPSBDb21tb24gTmFtZSAoaG9zdG5hbWUsIElQLCBvciB5b3VyIG5hbWUpCmNvbW1vbk5hbWVfbWF4ICAgICAgICAgID0gNjQKClsgdjNfcmVxIF0KYmFzaWNDb25zdHJhaW50cyA9IENBOkZBTFNFCmtleVVzYWdlID0gbm9uUmVwdWRpYXRpb24sIGRpZ2l0YWxTaWduYXR1cmUsIGtleUVuY2lwaGVybWVudCwga2V5RW5jaXBoZXJtZW50LCBkYXRhRW5jaXBoZXJtZW50LCBrZXlBZ3JlZW1lbnQKc3ViamVjdEFsdE5hbWUgICAgICAgICAgPSBAYWx0X25hbWVzCgpbIHJlcSBdCmRlZmF1bHRfYml0cyAgICAgICAgICAgID0gNDA5NiAgICAgICAgICAgICAgICAgICMgU2l6ZSBvZiBrZXlzCmRpc3Rpbmd1aXNoZWRfbmFtZSAgICAgID0gcmVxX2Rpc3Rpbmd1aXNoZWRfbmFtZQpyZXFfZXh0ZW5zaW9ucyAgICAgICAgICA9IHYzX3JlcQp4NTA5X2V4dGVuc2lvbnMgICAgICAgICA9IHYzX3JlcQoKW2FsdF9uYW1lc10KIyBFbnRlciB5b3VyIGFsdGVybmF0aXZlIEROUyBuYW1lcyAocGxlYXNlIG5vdGUgdGhlIGluY3JlbWVudGFsIG51bWJlcik=" | base64 -d - > "$certconfigdir/openssl::$FQDNunderscores.cnf"
	echo "WyByZXFfZGlzdGluZ3Vpc2hlZF9uYW1lIF0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEQVBUIEhFUkUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lX2RlZmF1bHQgICAgICA9IE15IENvbXBhbnkgICAgICAgICAgICAgICMgYWRhcHQgYXMgbmVlZGVkCmxvY2FsaXR5TmFtZV9kZWZhdWx0ICAgICAgICAgICAgPSBNeSBDaXR5ICAgICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZApzdGF0ZU9yUHJvdmluY2VOYW1lX2RlZmF1bHQgICAgID0gTXkgQ291bnR5L1N0YXRlICAgICAgICAgIyBhZGFwdCBhcyBuZWVkZWQKY291bnRyeU5hbWVfZGVmYXVsdCAgICAgICAgICAgICA9IERFICAgICAgICAgICAgICAgICAgICAgICMgY291bnRyeSBjb2RlOiBlLmcuIERFIGZvciBHZXJtYW55CmNvbW1vbk5hbWVfZGVmYXVsdCAgICAgICAgICAgICAgPSBob3N0LmV4YW1wbGUuY29tICAgICAgICAjIGhvc3RuYW1lIG9mIHRoZSB3ZWJzZXJ2ZXIKZW1haWxBZGRyZXNzX2RlZmF1bHQgICAgICAgICAgICA9IGhvc3RtYXN0ZXJzQGV4YW1wbGUuY29tICMgYWRhcHQgYXMgbmVlZGVkCm9yZ2FuaXphdGlvbmFsVW5pdE5hbWVfZGVmYXVsdCAgPSBXZWJtYXN0ZXJ5ICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZAojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lICAgICAgPSBPcmdhbml6YXRpb24gTmFtZSAoY29tcGFueSkKb3JnYW5pemF0aW9uYWxVbml0TmFtZSAgPSBPcmdhbml6YXRpb25hbCBVbml0IE5hbWUgKGRlcGFydG1lbnQsIGRpdmlzaW9uKQplbWFpbEFkZHJlc3MgICAgICAgICAgICA9IEVtYWlsIEFkZHJlc3MKZW1haWxBZGRyZXNzX21heCAgICAgICAgPSA0MApsb2NhbGl0eU5hbWUgICAgICAgICAgICA9IExvY2FsaXR5IE5hbWUgKGNpdHksIGRpc3RyaWN0KQpzdGF0ZU9yUHJvdmluY2VOYW1lICAgICA9IFN0YXRlIG9yIFByb3ZpbmNlIE5hbWUgKGZ1bGwgbmFtZSkKY291bnRyeU5hbWUgICAgICAgICAgICAgPSBDb3VudHJ5IE5hbWUgKDIgbGV0dGVyIGNvZGUpCmNvdW50cnlOYW1lX21pbiAgICAgICAgID0gMgpjb3VudHJ5TmFtZV9tYXggICAgICAgICA9IDIKY29tbW9uTmFtZSAgICAgICAgICAgICAgPSBDb21tb24gTmFtZSAoaG9zdG5hbWUsIElQLCBvciB5b3VyIG5hbWUpCmNvbW1vbk5hbWVfbWF4ICAgICAgICAgID0gNjQKClsgdjNfcmVxIF0KYmFzaWNDb25zdHJhaW50cyA9IENBOkZBTFNFCmtleVVzYWdlID0gbm9uUmVwdWRpYXRpb24sIGRpZ2l0YWxTaWduYXR1cmUsIGtleUVuY2lwaGVybWVudCwga2V5RW5jaXBoZXJtZW50LCBkYXRhRW5jaXBoZXJtZW50LCBrZXlBZ3JlZW1lbnQKc3ViamVjdEFsdE5hbWUgICAgICAgICAgPSBAYWx0X25hbWVzCgpbIHJlcSBdCmRlZmF1bHRfYml0cyAgICAgICAgICAgID0gNDA5NiAgICAgICAgICAgICAgICAgICMgU2l6ZSBvZiBrZXlzCmRpc3Rpbmd1aXNoZWRfbmFtZSAgICAgID0gcmVxX2Rpc3Rpbmd1aXNoZWRfbmFtZQpyZXFfZXh0ZW5zaW9ucyAgICAgICAgICA9IHYzX3JlcQp4NTA5X2V4dGVuc2lvbnMgICAgICAgICA9IHYzX3JlcQoKIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEQVBUIEhFUkUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KW2FsdF9uYW1lc10KIyBFbnRlciB5b3VyIGFsdGVybmF0aXZlIEROUyBuYW1lcyAocGxlYXNlIG5vdGUgdGhlIGluY3JlbWVudGFsIG51bWJlcikK" | base64 -d - > "$certconfigdir/openssl::$FQDNunderscores.cnf"
else
	echo "OpenSSL config was already deployed."
fi
echo "OK"

echo "Set permission for openssl config"
chmod 644 "$certconfigdir/openssl::$FQDNunderscores.cnf"
echo "OK"


### User is supposed to enter alternative DNS names ###
###  and cert. info (like orgaName or countryName)  ###
echo "Please configure this file properly"
echo "DNS.1 = $FQDN" >> "$certconfigdir/openssl::$FQDNunderscores.cnf"
editor "$certconfigdir/openssl::$FQDNunderscores.cnf"
echo "OK"


### EXECUTING web_certrequest.sh ###
echo "Executing web_certrequest.sh script..."
cdstack="$(pwd)"
cd "$certconfigdir/"
bash "$certconfigdir/web_certrequest.sh" "$FQDN"
cd "$cdstack"
echo "OK"

if [ "$debugmode" = false ]; then
	### Copy private key to /etc/ssl/private ###
	echo "Copying the private key '$certconfigdir/private/$FQDNunderscores.key' to /etc/ssl/private"
	cp "$certconfigdir/private/$FQDNunderscores.key" "/etc/ssl/private/$FQDNunderscores.key"
	echo "OK"

	echo "Set permission for private key in /etc/ssl/private"
	chmod 0600 "/etc/ssl/private/$FQDNunderscores.key"
	echo "OK"
	echo "Set ownership for private key in /etc/ssl/private"
	chown root:root "/etc/ssl/private/$FQDNunderscores.key"
	echo "OK"
else
	echo "Skipped copying private key"
fi

### Installing acme-tiny ###
echo "Installing acme-tiny via APT"
apt install acme-tiny
echo "OK"


### Creating letsencrypt_user ###
echo "Creating user: '$letsencrypt_username'"
sudo adduser --system --home "$letsencrypt_user_home" --shell /bin/bash "$letsencrypt_username"
echo "OK"


### Creating directories in user home ###
echo "Creating new directories in user home"
test -d "$letsencrypt_user_home/bin"          || mkdir -p "$letsencrypt_user_home/bin"
test -d "$letsencrypt_user_home/challenges"   || mkdir -p "$letsencrypt_user_home/challenges"
test -d "$letsencrypt_user_home/.letsencrypt" || mkdir -p "$letsencrypt_user_home/.letsencrypt"
echo "OK"


echo "Set permission for directories in user home"
chmod 700 "$letsencrypt_user_home/bin"
chmod 710 "$letsencrypt_user_home/challenges"
chmod 700 "$letsencrypt_user_home/.letsencrypt"
chmod 710 "$letsencrypt_user_home"
echo "OK"

echo "Set ownership for directories in user home"
chown $letsencrypt_username:nogroup  "$letsencrypt_user_home/bin"
chown $letsencrypt_username:www-data "$letsencrypt_user_home/challenges"
chown $letsencrypt_username:nogroup  "$letsencrypt_user_home/.letsencrypt"
chown $letsencrypt_username:www-data "$letsencrypt_user_home"
echo "OK"


### Deploying letsencrypt-renew-certs ###
echo "Deploying letsencrypt-renew-certs"
if ! [ -s "$letsencrypt_user_home/bin/letsencrypt-renew-certs" ]; then
	echo "IyEvYmluL2Jhc2gKCnNldCAtZQoKZGVjbGFyZSBGUUROPSJ0ZXN0LmRhcy1uZXR6d2Vya3RlYW0uZGUiCmRlY2xhcmUgRlFETnVuZGVyc2NvcmVzPSJ0ZXN0X2Rhcy1uZXR6d2Vya3RlYW1fZGUiCgpkZWNsYXJlIGtleXNfYmFzZV9wYXRoPSIke0hPTUV9Ly5sZXRzZW5jcnlwdCIKZGVjbGFyZSBpbnRlcm1lZGlhdGU9J2xldHMtZW5jcnlwdC14My1jcm9zcy1zaWduZWQucGVtJwpkZWNsYXJlIGFjY291bnRfa2V5X3BhdGg9IiR7a2V5c19iYXNlX3BhdGh9L2FjY291bnQtJHtGUUROdW5kZXJzY29yZXN9LmtleSIKZGVjbGFyZSBjZXJ0X2Jhc2VfcGF0aD0iJHtrZXlzX2Jhc2VfcGF0aH0vJHtGUUROdW5kZXJzY29yZXN9IgpkZWNsYXJlIGludGVybWVkaWF0ZV9wYXRoPSIke2tleXNfYmFzZV9wYXRofS8ke2ludGVybWVkaWF0ZX0iCmRlY2xhcmUgY2hhbGxlbmdlc19wYXRoPSIke0hPTUV9L2NoYWxsZW5nZXMiCmRlY2xhcmUgY2hlY2tlZF9wYXRoPSIke0hPTUV9L2NoZWNrZWQiCgpkZWNsYXJlIC1pIGk9JzAnCgojIElmIHRoZSBjaGVja2VkIGZpbGUgZXhpc3RzLCB3ZSBoYXZlIGFscmVhZHkgcmVuZXdlZCB0aGUgY2VydGlmaWNhdGUgaW4gdGhlCiMgcGFzdC4KaWYgW1sgLWUgIiR7Y2hlY2tlZF9wYXRofSIgXV07IHRoZW4KICAjIEhvd2V2ZXIsIGxpZmUgZ2V0cyBhIGJpdCBjb21wbGljYXRlZC4gVGhpcyBzY3JpcHQgaXMgc3VwcG9zZWQgdG8gcnVuIGV2ZXJ5CiAgIyA3IGRheXMgYXQgdGhlIGxhdGVzdCwgc3RhcnRpbmcgd2l0aCB0aGUgZmlyc3QgZGF5IG9mIGV2ZXJ5IG1vbnRoLCBhbmQgd2UKICAjIG9ubHkgd2FudCB0byByZW5ldyB0aGUgY2VydGlmaWNhdGUgb25jZSBhIG1vbnRoLgogICMgV2Ugd2lsbCBjcmVhdGUgdGhlIGNoZWNrZWQgZmlsZSBhdCB0aGUgdmVyeSBlbmQsIHdoaWNoIGFsc28gbWVhbnMgdGhhdCBpdAogICMgd2lsbCBvbmx5IGJlIGNyZWF0ZWQgb25jZSB0aGUgY2VydGlmaWNhdGUgaGFzIGJlZW4gc3VjY2Vzc2Z1bGx5IHJlbmV3ZWQuCiAgIyBGb3Igbm93LCBsZXQncyBjaGVjayBpZiB3ZSBoYXZlIHRvIHJlbW92ZSBpdCwgd2hpY2ggd2lsbCBhbHdheXMgYmUgdGhlIGNhc2UKICAjIG9uIHRoZSBmaXJzdCBkYXkgb2YgbW9udGguCiAgaWYgW1sgIjEiID0gIiQoZGF0ZSAiKyUtZCIpIiBdXTsgdGhlbgogICAgIyBSZW1vdmUgdGhlIGZpbGUsIHN0YXJ0aW5nIHRoZSByZW5ld2FsIHByb2Nlc3MuCiAgICBybSAtZiAiJHtjaGVja2VkX3BhdGh9IgogIGVsc2UKICAgICMgT3RoZXJ3aXNlLCB3ZSBkb24ndCBhY3R1YWxseSBuZWVkIGEgcmVuZXdhbCwgc28ganVzdCBzdG9wLgogICAgZXhpdCAwCiAgZmkKZmkKCiMgU2VlZCAke1JBTkRPTX0gdXNpbmcgdGhlIGN1cnJlbnQgdGltZS4KUkFORE9NPSIkKGRhdGUgJyslcycpIgoKIyBMZWF2ZSBvcmlnaW5hbCwgc2lnbmVkIGNlcnRpZmljYXRlIHVuaGFybWVkIGR1cmluZyByZW5ld2FsIHJ1bnMuCiMgVGhpcyBpcyB2ZXJ5IGltcG9ydGFudCBzaW5jZSBvdGhlcndpc2UgZmFpbHVyZXMgdG8gcmVuZXcgdGhlIGNlcnRpZmljYXRlCiMgd291bGQgbGVhZCB0byBhIGJyb2tlbi9taXNzaW5nIGNlcnRpZmljYXRlLCB3aGljaCBsZWFkcyB0byBjb21tb24gSFRUUAojIHNlcnZlcnMgZmFpbGluZyB0byBzdGFydCB1cCBhbmQgaGVuY2UgbWFrZSBzdWJzZXF1ZW50IHJlbmV3YWwgcmVxdWVzdHMKIyBpbXBvc3NpYmxlIChhbmQsIHdvcnNlLCBhIHNlbGYtaW5mbGljdGVkIGRlbmlhbC1vZi1zZXJ2aWNlIHNpdHVhdGlvbikuCiMgSGVuY2UsIHVzZSBhIHRlbXBvcmFyeSBmaWxlIGZvciBmZXRjaGluZyB0aGUgbmV3ZWQgY2VydGlmaWNhdGUgYW5kIG9ubHkKIyBjb3B5IHRoYXQgaW50byB0aGUgYWN0dWFsIGNlcnRpZmljYXRlIGZpbGUgd2hlbiBldmVyeXRoaW5nIHdvcmtlZCBvdXQgZmluZS4KOj4gIiR7Y2VydF9iYXNlX3BhdGh9LmNydC50bXAiCndoaWxlIDo7IGRvCiAgIyBJZ25vcmluZyBlcnJvcnMgaGVyZSAtIGVycm9ycyB3aWxsIGJlIGltcGxpY2l0bHkgaGFuZGxlZCBieSB0aGUgdGVtcG9yYXJ5CiAgIyByZW5ld2VkIGNlcnRpZmljYXRlIGZpbGUgYmVpbmcgZW1wdHkuCiAgYWNtZS10aW55IC0tYWNjb3VudC1rZXkgIiR7YWNjb3VudF9rZXlfcGF0aH0iIFwKCSAgICAtLWNzciAiJHtjZXJ0X2Jhc2VfcGF0aH0uY3NyIiBcCgkgICAgLS1hY21lLWRpciAiJHtjaGFsbGVuZ2VzX3BhdGh9IiBcCgkgICAgPiAiJHtjZXJ0X2Jhc2VfcGF0aH0uY3J0LnRtcCIgfHwgOgoKICBpZiB0ZXN0IFwhIC1zICIke2NlcnRfYmFzZV9wYXRofS5jcnQudG1wIjsgdGhlbgogICAgIyBSZXRyeSBhdCBtb3N0IDYgdGltZXMuCiAgICBpZiBbWyAiJCgoKytpKSkiIC1ndCAnNScgXV07IHRoZW4KICAgICAgZWNobyAnRmFpbGVkIHRvIHJlbmV3IGNlcnRpZmljYXRlIHRvbyBvZnRlbiwgYWJvcnRpbmcuLi4nID4mMgogICAgICBleGl0ICcxJwogICAgZWxzZQogICAgICAjIFNsZWVwIGZvciBhdCBsZWFzdCAzMCBtaW51dGVzLCB1cCB0byA2MC4KICAgICAgIyBUaGUgcmF0ZSBsaW1pdGluZyBwb2xpY3kgd291bGQgZ2l2ZSB1cyA1IHRyaWVzIHBlciBhY2NvdW50L2hvc3RuYW1lL2hvdXIsCiAgICAgICMgYnV0IHRoZXJlJ3MgcHJvYmFibHkgbm8gaGFybSBpbiBrZWVwaW5nIGEgKGxhcmdlKSBzYWZldHkgbWFyZ2luLgogICAgICBkZWNsYXJlIC1pIHNsZWVwX3RpbWU9IiQoKDMwICogNjApKSIKCiAgICAgICMgQ2FsY3VsYXRlIG1heGltdW0gcmFuZG9tIHZhbHVlIGZvciB1bmlmb3JtIG1vZHVsbyBjbGFtcGluZy4KICAgICAgIyBNb2R1bG8gY2xhbXBpbmcgaXMgb25seSB1bmJpYXNlZCBpZiB0aGUgcmFuZG9tIG51bWJlciByYW5nZSBkaXZpZGVkIGJ5CiAgICAgICMgdGhlIGRpdmlzb3IgaGFzIG5vIHJlbWFpbmRlciAoaS5lLiwgUkFORF9NQVggJSBuID09IDApLgogICAgICAjIEhlbmNlLCBjbGFtcCB0aGUgcmFuZG9tIHZhbHVlIHJhbmdlIGEgYml0IGZpcnN0LgogICAgICAjIFRvIG5vdCBkaXNjYXJkIHZhbHVlcyB1bm5lY2Vzc2FyaW5nbHksIHVzZSBhIGRpZmZlcmVudCBhbGdvcml0aG0gdGhhdAogICAgICAjIGhhbmRsZXMgaGlnaCBkaXZpc29yIHZhbHVlcyBlZmZpY2llbnRseSAtIGV2ZW4gaWYgd2UgZG9uJ3QgbmVlZCBpdCBpbgogICAgICAjIHRoaXMgY2FzZSBhbmQgaXQncyBhY3R1YWxseSBjb3VudGVyLXByb2R1Y3RpdmUgaGVyZS4KICAgICAgZGVjbGFyZSAtaSByYW5kb21fbGltaXQ9IiQoKDMyNzY3IC0gKCgoMzI3NjcgJSAzMCkgKyAxKSAlIDMwKSkpIgoKICAgICAgIyBJbml0aWFsaXplLgogICAgICBkZWNsYXJlIC1pIHJhbmRvbV9taW51dGVzPSIke1JBTkRPTX0iCgogICAgICAjIEZldGNoIG5ldyByYW5kb20gbnVtYmVyIGlmIG92ZXIgdGhlIGxpbWl0LgogICAgICB3aGlsZSAoKCR7cmFuZG9tX21pbnV0ZXN9ID4gJHtyYW5kb21fbGltaXR9KSk7IGRvCglyYW5kb21fbWludXRlcz0iJHtSQU5ET019IgogICAgICBkb25lCgogICAgICAjIENsYW1wIGludG8gcmFuZ2UsIHdoaWNoIHdpbGwgYmUgdW5pZm9ybWx5IGF0IHRoaXMgcG9pbnQuCiAgICAgIHJhbmRvbV9taW51dGVzPSIkKCgke3JhbmRvbV9taW51dGVzfSAlIDMwKSkiCgogICAgICBzbGVlcF90aW1lPSIkKCgke3NsZWVwX3RpbWV9ICsgKCR7cmFuZG9tX21pbnV0ZXN9ICogNjApKSkiCgogICAgICAjIEFuZCBhY3R1YWxseSBzbGVlcC4KICAgICAgc2xlZXAgIiR7c2xlZXBfdGltZX1zIgogICAgZmkKICBlbHNlCiAgICAjIFJlbmV3YWwgc3VjY2Vzc2Z1bC4KICAgIGJyZWFrCiAgZmkKZG9uZQoKIyBDb3B5aW5nIHRoZSBjb250ZW50IHZpYSBjYXQgd2lsbCBwcmVzZXJ2ZSBvcmlnaW5hbCBmaWxlIHBlcm1pc3Npb25zLCBhbmQsCiMgcHJvYmFibHkgZXZlbiBtb3JlIGltcG9ydGFudGx5LCB0aGUgZmlsZSdzIGlub2RlLgpjYXQgIiR7Y2VydF9iYXNlX3BhdGh9LmNydC50bXAiIFwKICAgID4gIiR7Y2VydF9iYXNlX3BhdGh9LmNydCIKCmNhdCAiJHtjZXJ0X2Jhc2VfcGF0aH0uY3J0IiBcCiAgICAiJHtpbnRlcm1lZGlhdGVfcGF0aH0iIFwKICAgID4gIiR7Y2VydF9iYXNlX3BhdGh9LmZ1bGxjaGFpbi5jcnQiCgojIENyZWF0ZSBjaGVja2VkIGZpbGUsIGRlbm90aW5nIHRoYXQgdGhlIHN1Y2Nlc3NmdWxseSByZW5ld2VkIHRoZSBjZXJ0aWZpY2F0ZS4KdG91Y2ggIiR7Y2hlY2tlZF9wYXRofSIK" | base64 -d - > "$letsencrypt_user_home/bin/letsencrypt-renew-certs"
else
	echo "Letsencrypt-renew-certs script was already deployed."
fi
echo "OK"


echo "Set permission for letsencrypt-renews-certs script"
chmod 755 "$letsencrypt_user_home/bin/letsencrypt-renew-certs"
echo "OK"

echo "Set ownership for letsencrypt-renews-certs script"
chown root:root  "$letsencrypt_user_home/bin/letsencrypt-renew-certs"
echo "OK"


### Copying FQDN.csr from $certconfigdir into $letsencrypt_user_home/.letsencrypt ###
echo "Copying $FQDNunderscores.csr from $certconfigdir into $letsencrypt_user_home/.letsencrypt"
cp "$certconfigdir/$FQDNunderscores.csr" "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.csr"
echo "OK"

echo "Set permission for $FQDNunderscores.csr"
chmod 644 "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.csr"
echo "OK"


### Testing for internet connection ###
echo "Testing for internet connection..."
# We would get the same with 'wget -q --spider http://letsencrypt.org' but then we would require wget
echo -e "GET http://letsencrypt.org HTTP/1.0\n\n" | nc letsencrypt.org 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
	echo "Can connect to letsencrypt. Internet connection seems good."
	inetEnabled=true
else
	echo "Can't connect to letsencrypt."
	inetEnabled=false
fi


### Downloading Letsencrypt .pem 's ###
if [ "$inetEnabled" = true ]; then
	echo "Downloading certificates from letsencrypt"
	url1="https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt"
	file1="$letsencrypt_user_home/.letsencrypt/lets-encrypt-x3-cross-signed.pem"
	if [ -r "$file1" ]; then
		echo "Detected that '$file1' is already present. Using it..."
	else
		wget $url1 -O $file1.tmp -a $logfile
		if [ -s "$file1.tmp" ]; then
			echo "Successfully downloaded '$file1'!"
			echo "Downloaded '$file1'" >> $logfile
			mv $file1.tmp $file1
		else
			echo "Failed to download '$file1'!"
                	echo "Failed to download '$file1'!" >> $logfile
			rm $file1.tmp
			exit -1
		fi
	fi
	url2="https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt"
	file2="$letsencrypt_user_home/.letsencrypt/letsencryptauthorityx3.pem"
	if [ -r "$file2" ]; then
        	echo "Detected that '$file2' is already present. Using it..."
	else
        	wget $url2 -O $file2.tmp -a $logfile
        	if [ -s "$file2.tmp" ]; then
                	echo "Successfully downloaded '$file2'!"
                	echo "Downloaded '$file2'" >> $logfile
			mv $file2.tmp $file2
		else
			echo "Failed to download '$file2'!"
			echo "Failed to download '$file2'!" >> $logfile
			rm $file2.tmp
			exit -1
        	fi
	fi
	echo "OK"

	echo "Set permission for letsencrypt certs"
	chmod 644 "$file1"
	chmod 644 "$file2"
	echo "OK"

	echo "Set ownership for letsencrypt certs"
	chown root:root "$file1"
	chown root:root "$file2"
	echo "OK"
else
	echo "Didn't download certificates from letsencrypt"
fi


### Creating new account key ###
# Testing if there is already an account file
if [ -s "$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key" ]; then
	echo "Detected an account-key '$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key'!"
else
	echo "Didn't detect an account-key"
	echo "Creating a new account-key"
	echo "Creating account-key. '$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key'" >> $logfile
	sudo su letsencrypt -c "openssl genrsa 4096 > $letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"

	echo "Set permission for account key"
	chmod 644 "$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"
	echo "OK"

	echo "Set ownership for account key"
	chown root:root "$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"
	echo "OK"
fi
echo "OK"


### Installing letsencrypt-renew-certs command ###
echo "Installing 'letsencrypt-renew-certs' command"
commandfile="/usr/local/sbin/letsencrypt-renew-certs"
if ! [ -s "$commandfile" ]; then
	echo "IyEvYmluL2Jhc2gKCnN1IC0gbGV0c2VuY3J5cHQgLWMgfmxldHNlbmNyeXB0L2Jpbi9sZXRzZW5jcnlwdC1yZW5ldy1jZXJ0cwoKaW52b2tlLXJjLmQgYXBhY2hlMiByZXN0YXJ0" | base64 -d - > $commandfile
	echo "Installed 'letsencrypt-renew-certs' command" >> $logfile
else
	echo "Command was already installed."
fi
echo "OK"

echo "Making it executable"
chmod 0700 $commandfile
echo "OK"


#todo: cronjob


if [ "$setup_apache" = false ]; then
	echo "Didn't configure apache2."
	echo "Script has finished!"
	exit 0;
fi

################
###SETTING UP###
####APACHE 2####
################
apache_acme_conf="/etc/apache2/conf-available/acme-tiny.conf"


### Deploying $apache_acme_conf ###
echo "Deploying '$apache_acme_conf'"
touch $apache_acme_conf
echo "QWxpYXMgLy53ZWxsLWtub3duL2FjbWUtY2hhbGxlbmdlLyAvdmFyL2xpYi9sZXRzZW5jcnlwdC9jaGFsbGVuZ2VzLwoKPERpcmVjdG9yeSAvdmFyL2xpYi9sZXRzZW5jcnlwdC9jaGFsbGVuZ2VzPgogICAgUmVxdWlyZSBhbGwgZ3JhbnRlZAogICAgT3B0aW9ucyAtSW5kZXhlcwo8L0RpcmVjdG9yeT4=" | base64 -d - > $apache_acme_conf


### Enabling $apache_acme_conf ###
echo "Enabling '$apache_acme_conf'..."
sudo a2enconf acme-tiny
echo "OK"


### Restarting Apache2 ###
echo "Restarting Apache2..."
sudo invoke-rc.d apache2 restart
if [ $? -eq 0 ]; then
	echo "OK"
else
	echo "NOT OK! Restarting Apache2 failed..."
	echo "restarting apache2 failed" >> $logfile
fi

### EXECUTING letsencrypt-renew-script ###
echo "Executing letsencrypt-renew-certs script!"
echo "Executing letsencrypt-renew-certs script" >> $logfile
sudo letsencrypt-renew-certs
echo "OK"


### Symlink cert ###
sudo ln -s "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.fullchain.crt" "/etc/ssl/certs/$FQDNunderscores.fullchain.crt"
echo "Symlinked .crt to '/etc/ssl/certs/$FQDNunderscores.fullchain.crt'"


### Enabling the SSL module ###
echo "Enabling the SSL module..."
sudo a2enmod ssl
echo "OK"


### Restarting Apache2 ###
echo "Restarting Apache2..."
sudo invoke-rc.d apache2 restart
echo "OK"


echo "-------------------"
echo "Script Finished!"
echo "Please adjust your apache ssl site configuration to:"
echo "-------------------"
echo "SSLCertificateFile      /etc/ssl/certs/$FQDNunderscores.fullchain.crt"
echo "SSLCertificateKeyFile   /etc/ssl/private/$FQDNunderscores.key"
echo ""
echo "If you want your users to be always redirected to https then put the following into your *HTTP* site configuration:"
echo ""
echo "RewriteEngine on"
echo "RewriteCond %{REQUEST_URI} !/\.well-known/acme-challenge/.*"
echo "RewriteRule /(.*) https://$FQDN/\$1 [L,NC,NE]"
echo ""
echo "And don't forget to enable the rewrite module."
echo "a2enmod rewrite"
echo "-----THANK YOU-----"