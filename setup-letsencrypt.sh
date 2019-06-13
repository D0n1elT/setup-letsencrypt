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
#echo "Installing Base64 via APT"
#apt install base64
#TODO: SEARCH BASE64 PACKET
#echo "OK"


### Making directory $certconfigdir ###
echo "Creating cert. config directory"
test -d "$certconfigdir" || mkdir -p "$certconfigdir"
echo "OK"


### Deploying web_certrequest.sh ###
echo "Deploying web_certrequest.sh"
if ! [ -s "$certconfigdir/web_certrequest.sh" ]; then
	echo "IyEvYmluL2Jhc2gKCkZRRE49IiQxIgpGUUROdW5kZXJzY29yZXM9IiQoZWNobyAkRlFETiB8IHNlZCAncy9cLi9fL2cnKSIKCmJhc2U9IiQocHdkKSIKCnRlc3QgLWQgIiRiYXNlL3ByaXZhdGUiIHx8IG1rZGlyIC1wICIkYmFzZS9wcml2YXRlIgoKaWYgWyAtZiAiJGJhc2UvcHJpdmF0ZS8ke0ZRRE51bmRlcnNjb3Jlc30ua2V5IiBdOyB0aGVuCiAgICAgICAgb3BlbnNzbCAgcmVxICAtY29uZmlnICIkYmFzZS9vcGVuc3NsOjoke0ZRRE51bmRlcnNjb3Jlc30uY25mIiBcCiAgICAgICAgICAgICAgICAgICAgICAtbm9kZXMgIC1uZXcgXAogICAgICAgICAgICAgICAgICAgICAgLWtleSAiJGJhc2UvcHJpdmF0ZS8ke0ZRRE51bmRlcnNjb3Jlc30ua2V5IiBcCiAgICAgICAgICAgICAgICAgIC1vdXQgIiRiYXNlLyR7RlFETnVuZGVyc2NvcmVzfS5jc3IiCmVsc2UKICAgIG9wZW5zc2wgIHJlcSAgLWNvbmZpZyAiJGJhc2Uvb3BlbnNzbDo6JHtGUUROdW5kZXJzY29yZXN9LmNuZiIgXAogICAgICAgICAgICAgICAgICAtbm9kZXMgIC1uZXcgXAogICAgICAgICAgICAgICAgICAta2V5b3V0ICIkYmFzZS9wcml2YXRlLyR7RlFETnVuZGVyc2NvcmVzfS5rZXkiIFwKICAgICAgICAgICAgICAgICAgLW91dCAiJGJhc2UvJHtGUUROdW5kZXJzY29yZXN9LmNzciIKZmkK" | base64 -d - > "$certconfigdir/web_certrequest.sh"
else
	echo "Web_certrequest.sh was already deployed."
fi

echo "Set permission for web_certrequest.sh"
chmod 755 "$certconfigdir/web_certrequest.sh"
echo "OK"


### Deploying openssl config ###
echo "Deploying openssl config"
if ! [ -s "$certconfigdir/openssl::$FQDNunderscores.cnf" ]; then
	echo "WyByZXFfZGlzdGluZ3Vpc2hlZF9uYW1lIF0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEQVBUIEhFUkUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lX2RlZmF1bHQgICAgICA9IE15IENvbXBhbnkgICAgICAgICAgICAgICMgYWRhcHQgYXMgbmVlZGVkCmxvY2FsaXR5TmFtZV9kZWZhdWx0ICAgICAgICAgICAgPSBNeSBDaXR5ICAgICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZApzdGF0ZU9yUHJvdmluY2VOYW1lX2RlZmF1bHQgICAgID0gTXkgQ291bnR5L1N0YXRlICAgICAgICAgIyBhZGFwdCBhcyBuZWVkZWQKY291bnRyeU5hbWVfZGVmYXVsdCAgICAgICAgICAgICA9IERFICAgICAgICAgICAgICAgICAgICAgICMgY291bnRyeSBjb2RlOiBlLmcuIERFIGZvciBHZXJtYW55CmNvbW1vbk5hbWVfZGVmYXVsdCAgICAgICAgICAgICAgPSBob3N0LmV4YW1wbGUuY29tICAgICAgICAjIGhvc3RuYW1lIG9mIHRoZSB3ZWJzZXJ2ZXIKZW1haWxBZGRyZXNzX2RlZmF1bHQgICAgICAgICAgICA9IGhvc3RtYXN0ZXJzQGV4YW1wbGUuY29tICMgYWRhcHQgYXMgbmVlZGVkCm9yZ2FuaXphdGlvbmFsVW5pdE5hbWVfZGVmYXVsdCAgPSBXZWJtYXN0ZXJ5ICAgICAgICAgICAgICAjIGFkYXB0IGFzIG5lZWRlZAojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KMC5vcmdhbml6YXRpb25OYW1lICAgICAgPSBPcmdhbml6YXRpb24gTmFtZSAoY29tcGFueSkKb3JnYW5pemF0aW9uYWxVbml0TmFtZSAgPSBPcmdhbml6YXRpb25hbCBVbml0IE5hbWUgKGRlcGFydG1lbnQsIGRpdmlzaW9uKQplbWFpbEFkZHJlc3MgICAgICAgICAgICA9IEVtYWlsIEFkZHJlc3MKZW1haWxBZGRyZXNzX21heCAgICAgICAgPSA0MApsb2NhbGl0eU5hbWUgICAgICAgICAgICA9IExvY2FsaXR5IE5hbWUgKGNpdHksIGRpc3RyaWN0KQpzdGF0ZU9yUHJvdmluY2VOYW1lICAgICA9IFN0YXRlIG9yIFByb3ZpbmNlIE5hbWUgKGZ1bGwgbmFtZSkKY291bnRyeU5hbWUgICAgICAgICAgICAgPSBDb3VudHJ5IE5hbWUgKDIgbGV0dGVyIGNvZGUpCmNvdW50cnlOYW1lX21pbiAgICAgICAgID0gMgpjb3VudHJ5TmFtZV9tYXggICAgICAgICA9IDIKY29tbW9uTmFtZSAgICAgICAgICAgICAgPSBDb21tb24gTmFtZSAoaG9zdG5hbWUsIElQLCBvciB5b3VyIG5hbWUpCmNvbW1vbk5hbWVfbWF4ICAgICAgICAgID0gNjQKClsgdjNfcmVxIF0KYmFzaWNDb25zdHJhaW50cyA9IENBOkZBTFNFCmtleVVzYWdlID0gbm9uUmVwdWRpYXRpb24sIGRpZ2l0YWxTaWduYXR1cmUsIGtleUVuY2lwaGVybWVudCwga2V5RW5jaXBoZXJtZW50LCBkYXRhRW5jaXBoZXJtZW50LCBrZXlBZ3JlZW1lbnQKc3ViamVjdEFsdE5hbWUgICAgICAgICAgPSBAYWx0X25hbWVzCgpbIHJlcSBdCmRlZmF1bHRfYml0cyAgICAgICAgICAgID0gNDA5NiAgICAgICAgICAgICAgICAgICMgU2l6ZSBvZiBrZXlzCmRpc3Rpbmd1aXNoZWRfbmFtZSAgICAgID0gcmVxX2Rpc3Rpbmd1aXNoZWRfbmFtZQpyZXFfZXh0ZW5zaW9ucyAgICAgICAgICA9IHYzX3JlcQp4NTA5X2V4dGVuc2lvbnMgICAgICAgICA9IHYzX3JlcQoKIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLUFEQVBUIEhFUkUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KW2FsdF9uYW1lc10KIyBFbnRlciB5b3VyIGFsdGVybmF0aXZlIEROUyBuYW1lcyAocGxlYXNlIG5vdGUgdGhlIGluY3JlbWVudGFsIG51bWJlcikK" | base64 -d - > "$certconfigdir/openssl::$FQDNunderscores.cnf"
	is_opensslconfig_new=true
else
	echo "OpenSSL config was already deployed."
	is_opensslconfig_new=false
fi

echo "Set permission for openssl config"
chmod 644 "$certconfigdir/openssl::$FQDNunderscores.cnf"
echo "OK"


### User is supposed to enter alternative DNS names ###
###  and cert. info (like orgaName or countryName)  ###
echo "Please configure this file properly"
if [ "$is_opensslconfig_new" = true ]; then
	echo "DNS.1 = $FQDN" >> "$certconfigdir/openssl::$FQDNunderscores.cnf"
fi
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

	echo "Set permission for private key in /etc/ssl/private"
	chmod 0600 "/etc/ssl/private/$FQDNunderscores.key"

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


echo "Set permission for directories in user home"
chmod 700 "$letsencrypt_user_home/bin"
chmod 710 "$letsencrypt_user_home/challenges"
chmod 700 "$letsencrypt_user_home/.letsencrypt"
chmod 710 "$letsencrypt_user_home"

echo "Set ownership for directories in user home"
chown $letsencrypt_username:nogroup  "$letsencrypt_user_home/bin"
chown $letsencrypt_username:www-data "$letsencrypt_user_home/challenges"
chown $letsencrypt_username:nogroup  "$letsencrypt_user_home/.letsencrypt"
chown $letsencrypt_username:www-data "$letsencrypt_user_home"
echo "OK"


### Deploying letsencrypt-renew-certs ###
echo "Deploying letsencrypt-renew-certs"
if ! [ -s "$letsencrypt_user_home/bin/letsencrypt-renew-certs" ]; then
	echo "IyEvYmluL2Jhc2gKCnNldCAtZQoKZGVjbGFyZSBGUUROPSIkKGNhdCAke0hPTUV9L2Jpbi9GUUROLmNuZiB8IHRyIC1kICdccicpIgpkZWNsYXJlIEZRRE51bmRlcnNjb3Jlcz0iJChlY2hvICRGUUROIHwgc2VkICdzL1wuL18vZycpIgoKZGVjbGFyZSBrZXlzX2Jhc2VfcGF0aD0iJHtIT01FfS8ubGV0c2VuY3J5cHQiCmRlY2xhcmUgaW50ZXJtZWRpYXRlPSdsZXRzLWVuY3J5cHQteDMtY3Jvc3Mtc2lnbmVkLnBlbScKZGVjbGFyZSBhY2NvdW50X2tleV9wYXRoPSIke2tleXNfYmFzZV9wYXRofS9hY2NvdW50LSR7RlFETnVuZGVyc2NvcmVzfS5rZXkiCmRlY2xhcmUgY2VydF9iYXNlX3BhdGg9IiR7a2V5c19iYXNlX3BhdGh9LyR7RlFETnVuZGVyc2NvcmVzfSIKZGVjbGFyZSBpbnRlcm1lZGlhdGVfcGF0aD0iJHtrZXlzX2Jhc2VfcGF0aH0vJHtpbnRlcm1lZGlhdGV9IgpkZWNsYXJlIGNoYWxsZW5nZXNfcGF0aD0iJHtIT01FfS9jaGFsbGVuZ2VzIgpkZWNsYXJlIGNoZWNrZWRfcGF0aD0iJHtIT01FfS9jaGVja2VkIgoKZGVjbGFyZSAtaSBpPScwJwoKIyBJZiB0aGUgY2hlY2tlZCBmaWxlIGV4aXN0cywgd2UgaGF2ZSBhbHJlYWR5IHJlbmV3ZWQgdGhlIGNlcnRpZmljYXRlIGluIHRoZQojIHBhc3QuCmlmIFtbIC1lICIke2NoZWNrZWRfcGF0aH0iIF1dOyB0aGVuCiAgIyBIb3dldmVyLCBsaWZlIGdldHMgYSBiaXQgY29tcGxpY2F0ZWQuIFRoaXMgc2NyaXB0IGlzIHN1cHBvc2VkIHRvIHJ1biBldmVyeQogICMgNyBkYXlzIGF0IHRoZSBsYXRlc3QsIHN0YXJ0aW5nIHdpdGggdGhlIGZpcnN0IGRheSBvZiBldmVyeSBtb250aCwgYW5kIHdlCiAgIyBvbmx5IHdhbnQgdG8gcmVuZXcgdGhlIGNlcnRpZmljYXRlIG9uY2UgYSBtb250aC4KICAjIFdlIHdpbGwgY3JlYXRlIHRoZSBjaGVja2VkIGZpbGUgYXQgdGhlIHZlcnkgZW5kLCB3aGljaCBhbHNvIG1lYW5zIHRoYXQgaXQKICAjIHdpbGwgb25seSBiZSBjcmVhdGVkIG9uY2UgdGhlIGNlcnRpZmljYXRlIGhhcyBiZWVuIHN1Y2Nlc3NmdWxseSByZW5ld2VkLgogICMgRm9yIG5vdywgbGV0J3MgY2hlY2sgaWYgd2UgaGF2ZSB0byByZW1vdmUgaXQsIHdoaWNoIHdpbGwgYWx3YXlzIGJlIHRoZSBjYXNlCiAgIyBvbiB0aGUgZmlyc3QgZGF5IG9mIG1vbnRoLgogIGlmIFtbICIxIiA9ICIkKGRhdGUgIislLWQiKSIgXV07IHRoZW4KICAgICMgUmVtb3ZlIHRoZSBmaWxlLCBzdGFydGluZyB0aGUgcmVuZXdhbCBwcm9jZXNzLgogICAgcm0gLWYgIiR7Y2hlY2tlZF9wYXRofSIKICBlbHNlCiAgICAjIE90aGVyd2lzZSwgd2UgZG9uJ3QgYWN0dWFsbHkgbmVlZCBhIHJlbmV3YWwsIHNvIGp1c3Qgc3RvcC4KICAgIGV4aXQgMAogIGZpCmZpCgojIFNlZWQgJHtSQU5ET019IHVzaW5nIHRoZSBjdXJyZW50IHRpbWUuClJBTkRPTT0iJChkYXRlICcrJXMnKSIKCiMgTGVhdmUgb3JpZ2luYWwsIHNpZ25lZCBjZXJ0aWZpY2F0ZSB1bmhhcm1lZCBkdXJpbmcgcmVuZXdhbCBydW5zLgojIFRoaXMgaXMgdmVyeSBpbXBvcnRhbnQgc2luY2Ugb3RoZXJ3aXNlIGZhaWx1cmVzIHRvIHJlbmV3IHRoZSBjZXJ0aWZpY2F0ZQojIHdvdWxkIGxlYWQgdG8gYSBicm9rZW4vbWlzc2luZyBjZXJ0aWZpY2F0ZSwgd2hpY2ggbGVhZHMgdG8gY29tbW9uIEhUVFAKIyBzZXJ2ZXJzIGZhaWxpbmcgdG8gc3RhcnQgdXAgYW5kIGhlbmNlIG1ha2Ugc3Vic2VxdWVudCByZW5ld2FsIHJlcXVlc3RzCiMgaW1wb3NzaWJsZSAoYW5kLCB3b3JzZSwgYSBzZWxmLWluZmxpY3RlZCBkZW5pYWwtb2Ytc2VydmljZSBzaXR1YXRpb24pLgojIEhlbmNlLCB1c2UgYSB0ZW1wb3JhcnkgZmlsZSBmb3IgZmV0Y2hpbmcgdGhlIG5ld2VkIGNlcnRpZmljYXRlIGFuZCBvbmx5CiMgY29weSB0aGF0IGludG8gdGhlIGFjdHVhbCBjZXJ0aWZpY2F0ZSBmaWxlIHdoZW4gZXZlcnl0aGluZyB3b3JrZWQgb3V0IGZpbmUuCjo+ICIke2NlcnRfYmFzZV9wYXRofS5jcnQudG1wIgp3aGlsZSA6OyBkbwogICMgSWdub3JpbmcgZXJyb3JzIGhlcmUgLSBlcnJvcnMgd2lsbCBiZSBpbXBsaWNpdGx5IGhhbmRsZWQgYnkgdGhlIHRlbXBvcmFyeQogICMgcmVuZXdlZCBjZXJ0aWZpY2F0ZSBmaWxlIGJlaW5nIGVtcHR5LgogIGFjbWUtdGlueSAtLWFjY291bnQta2V5ICIke2FjY291bnRfa2V5X3BhdGh9IiBcCgkgICAgLS1jc3IgIiR7Y2VydF9iYXNlX3BhdGh9LmNzciIgXAoJICAgIC0tYWNtZS1kaXIgIiR7Y2hhbGxlbmdlc19wYXRofSIgXAoJICAgID4gIiR7Y2VydF9iYXNlX3BhdGh9LmNydC50bXAiIHx8IDoKCiAgaWYgdGVzdCBcISAtcyAiJHtjZXJ0X2Jhc2VfcGF0aH0uY3J0LnRtcCI7IHRoZW4KICAgICMgUmV0cnkgYXQgbW9zdCA2IHRpbWVzLgogICAgaWYgW1sgIiQoKCsraSkpIiAtZ3QgJzUnIF1dOyB0aGVuCiAgICAgIGVjaG8gJ0ZhaWxlZCB0byByZW5ldyBjZXJ0aWZpY2F0ZSB0b28gb2Z0ZW4sIGFib3J0aW5nLi4uJyA+JjIKICAgICAgZXhpdCAnMScKICAgIGVsc2UKICAgICAgIyBTbGVlcCBmb3IgYXQgbGVhc3QgMzAgbWludXRlcywgdXAgdG8gNjAuCiAgICAgICMgVGhlIHJhdGUgbGltaXRpbmcgcG9saWN5IHdvdWxkIGdpdmUgdXMgNSB0cmllcyBwZXIgYWNjb3VudC9ob3N0bmFtZS9ob3VyLAogICAgICAjIGJ1dCB0aGVyZSdzIHByb2JhYmx5IG5vIGhhcm0gaW4ga2VlcGluZyBhIChsYXJnZSkgc2FmZXR5IG1hcmdpbi4KICAgICAgZGVjbGFyZSAtaSBzbGVlcF90aW1lPSIkKCgzMCAqIDYwKSkiCgogICAgICAjIENhbGN1bGF0ZSBtYXhpbXVtIHJhbmRvbSB2YWx1ZSBmb3IgdW5pZm9ybSBtb2R1bG8gY2xhbXBpbmcuCiAgICAgICMgTW9kdWxvIGNsYW1waW5nIGlzIG9ubHkgdW5iaWFzZWQgaWYgdGhlIHJhbmRvbSBudW1iZXIgcmFuZ2UgZGl2aWRlZCBieQogICAgICAjIHRoZSBkaXZpc29yIGhhcyBubyByZW1haW5kZXIgKGkuZS4sIFJBTkRfTUFYICUgbiA9PSAwKS4KICAgICAgIyBIZW5jZSwgY2xhbXAgdGhlIHJhbmRvbSB2YWx1ZSByYW5nZSBhIGJpdCBmaXJzdC4KICAgICAgIyBUbyBub3QgZGlzY2FyZCB2YWx1ZXMgdW5uZWNlc3NhcmluZ2x5LCB1c2UgYSBkaWZmZXJlbnQgYWxnb3JpdGhtIHRoYXQKICAgICAgIyBoYW5kbGVzIGhpZ2ggZGl2aXNvciB2YWx1ZXMgZWZmaWNpZW50bHkgLSBldmVuIGlmIHdlIGRvbid0IG5lZWQgaXQgaW4KICAgICAgIyB0aGlzIGNhc2UgYW5kIGl0J3MgYWN0dWFsbHkgY291bnRlci1wcm9kdWN0aXZlIGhlcmUuCiAgICAgIGRlY2xhcmUgLWkgcmFuZG9tX2xpbWl0PSIkKCgzMjc2NyAtICgoKDMyNzY3ICUgMzApICsgMSkgJSAzMCkpKSIKCiAgICAgICMgSW5pdGlhbGl6ZS4KICAgICAgZGVjbGFyZSAtaSByYW5kb21fbWludXRlcz0iJHtSQU5ET019IgoKICAgICAgIyBGZXRjaCBuZXcgcmFuZG9tIG51bWJlciBpZiBvdmVyIHRoZSBsaW1pdC4KICAgICAgd2hpbGUgKCgke3JhbmRvbV9taW51dGVzfSA+ICR7cmFuZG9tX2xpbWl0fSkpOyBkbwoJcmFuZG9tX21pbnV0ZXM9IiR7UkFORE9NfSIKICAgICAgZG9uZQoKICAgICAgIyBDbGFtcCBpbnRvIHJhbmdlLCB3aGljaCB3aWxsIGJlIHVuaWZvcm1seSBhdCB0aGlzIHBvaW50LgogICAgICByYW5kb21fbWludXRlcz0iJCgoJHtyYW5kb21fbWludXRlc30gJSAzMCkpIgoKICAgICAgc2xlZXBfdGltZT0iJCgoJHtzbGVlcF90aW1lfSArICgke3JhbmRvbV9taW51dGVzfSAqIDYwKSkpIgoKICAgICAgIyBBbmQgYWN0dWFsbHkgc2xlZXAuCiAgICAgIHNsZWVwICIke3NsZWVwX3RpbWV9cyIKICAgIGZpCiAgZWxzZQogICAgIyBSZW5ld2FsIHN1Y2Nlc3NmdWwuCiAgICBicmVhawogIGZpCmRvbmUKCiMgQ29weWluZyB0aGUgY29udGVudCB2aWEgY2F0IHdpbGwgcHJlc2VydmUgb3JpZ2luYWwgZmlsZSBwZXJtaXNzaW9ucywgYW5kLAojIHByb2JhYmx5IGV2ZW4gbW9yZSBpbXBvcnRhbnRseSwgdGhlIGZpbGUncyBpbm9kZS4KY2F0ICIke2NlcnRfYmFzZV9wYXRofS5jcnQudG1wIiBcCiAgICA+ICIke2NlcnRfYmFzZV9wYXRofS5jcnQiCgpjYXQgIiR7Y2VydF9iYXNlX3BhdGh9LmNydCIgXAogICAgIiR7aW50ZXJtZWRpYXRlX3BhdGh9IiBcCiAgICA+ICIke2NlcnRfYmFzZV9wYXRofS5mdWxsY2hhaW4uY3J0IgoKIyBDcmVhdGUgY2hlY2tlZCBmaWxlLCBkZW5vdGluZyB0aGF0IHRoZSBzdWNjZXNzZnVsbHkgcmVuZXdlZCB0aGUgY2VydGlmaWNhdGUuCnRvdWNoICIke2NoZWNrZWRfcGF0aH0iCg==" | base64 -d - > "$letsencrypt_user_home/bin/letsencrypt-renew-certs"
else
	echo "Letsencrypt-renew-certs script was already deployed."
fi

echo "Set permission for letsencrypt-renews-certs script"
chmod 755 "$letsencrypt_user_home/bin/letsencrypt-renew-certs"

echo "Set ownership for letsencrypt-renews-certs script"
chown root:root  "$letsencrypt_user_home/bin/letsencrypt-renew-certs"
echo "OK"


### Creating FQDN.cnf file ###
echo "Creating the FQDN.cnf file..."
if ! [ -s "$letsencrypt_user_home/bin/FQDN.cnf" ]; then
	printf "$FQDNunderscores" | tr -d '\r' > "$letsencrypt_user_home/bin/FQDN.cnf"
else
	echo "FQDN.cnf was already created."
fi

echo "Set permission for FQDN.cnf"
chmod 644 "$letsencrypt_user_home/bin/FQDN.cnf"
echo "OK"


### Copying $FQDNunderscores.csr from $certconfigdir into $letsencrypt_user_home/.letsencrypt ###
echo "Copying $FQDNunderscores.csr from $certconfigdir into $letsencrypt_user_home/.letsencrypt"
cp "$certconfigdir/$FQDNunderscores.csr" "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.csr"

echo "Set permission for $FQDNunderscores.csr"
chmod 644 "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.csr"
echo "OK"


### Testing for internet connection ###
echo "Testing for internet connection..."
# We would get the same with
# 'wget -q --spider http://letsencrypt.org'
# but then we would require wget
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

	echo "Set permission for letsencrypt certs"
	chmod 644 "$file1"
	chmod 644 "$file2"

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
	echo "Creating account-key '$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key'" >> $logfile
	sudo su letsencrypt -c "openssl genrsa 4096 > $letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"

	echo "Set permission for account key"
	chmod 644 "$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"

	echo "Set ownership for account key"
	chown root:root "$letsencrypt_user_home/.letsencrypt/account-$FQDNunderscores.key"
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
if ! [ -s "$apache_acme_conf" ]; then
	echo "QWxpYXMgLy53ZWxsLWtub3duL2FjbWUtY2hhbGxlbmdlLyAvdmFyL2xpYi9sZXRzZW5jcnlwdC9jaGFsbGVuZ2VzLwoKPERpcmVjdG9yeSAvdmFyL2xpYi9sZXRzZW5jcnlwdC9jaGFsbGVuZ2VzPgogICAgUmVxdWlyZSBhbGwgZ3JhbnRlZAogICAgT3B0aW9ucyAtSW5kZXhlcwo8L0RpcmVjdG9yeT4=" | base64 -d - > $apache_acme_conf
	echo "OK"
else
	echo "Apache2 config was already deployed..."
fi

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
	echo "Restarting apache2 failed" >> $logfile
fi

### EXECUTING letsencrypt-renew-script ###
echo "Executing letsencrypt-renew-certs script!"
echo "Executing letsencrypt-renew-certs script" >> $logfile
sudo letsencrypt-renew-certs
echo "OK"


### Symlink cert ###
sudo ln -s "$letsencrypt_user_home/.letsencrypt/$FQDNunderscores.fullchain.crt" "/etc/ssl/certs/$FQDNunderscores.fullchain.crt" > /dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Symlinked .crt to '/etc/ssl/certs/$FQDNunderscores.fullchain.crt'"
else
        echo "NOT OK! But Symlink was problably just already there..."
fi


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
