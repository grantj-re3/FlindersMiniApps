
# How to install an SSL Certificate in CPanel 11

## Assumptions

- **IMPORTANT security consideration:** Assumes your CPanel traffic
  already uses HTTPS (perhaps via a self-signed SSL cert.) so that
  your private key is uploaded via an encrypted channel.
- Assumes SNI (Server Name Indication) support which allows you (or your
  CPanel hosting provider) to host multiple SSL certificates for different
  domains on the same IP address.
- Assumes your ICT department have created a GeoTrust certificate and have
  not used CPanel to generate a Certificate Signing Request (CSR).
- Assumes your ICT department have supplied you with the following:
  * GeoTrust URL to "DOWNLOAD AND INSTALL YOUR CERTIFICATE"
  * private key file (.key) and corresponding passphrase

Although I used GeoTrust for this example, the principle should be
similar for other certificate authorities/providers.


## Instructions

### Download the certificates from GeoTrust.

- Navigate to the Geotrust URL "DOWNLOAD AND INSTALL YOUR CERTIFICATE"
- Get Started > Apache > HTTP Server > Download. (If the "Get Started"
  button takes you to a generic page, try using a different web browser,
  eg. Internet Explorer)
- Unzip to obtain ssl_certificate.crt and IntermediateCA.crt

### Upload the certificate to your hosting provider

- CPanel > Home > SSL/TLS > Certificates (CRT)
- Browse: ssl_certificate.crt
- Description: Eg. Uploaded YYYY-MM-DD by XXXX
- Upload Certificate

### "Upload" the private key

Convert to PEM format using passphrase. For **security reasons**
the output of the command below should either not be stored or
should stored in a secure password-protected and/or encrypted
file.

```
# Run this command under Linux, Unix or similar environment.
# Enter passphrase when prompted.
# Output will go to stdout.

$ openssl rsa -in mydomain.key -outform PEM
```

Upload the converted PEM format private key. For **security reasons**
this key should be uploaded via an encrypted channel (ie. CPanel
running via HTTPS).

- CPanel > Home > SSL/TLS > Private Keys (KEY)
- Paste private key from output of above command (including BEGIN and END lines)
- Description: Eg. Uploaded YYYY-MM-DD by XXXX
- Upload Certificate


### Install the certificate

- CPanel > Home > SSL/TLS > Install and Manage SSL for your site (HTTPS)
- Browse Certificates > Select the above cert. > Use Certificate.
  The cert and private key will auto-populate.
- Paste the IntermediateCA.crt into CABUNDLE (if it doesn't auto-populate)
- Install certificate

### Test

- Verify using https://www.geocerts.com/ssl_checker

- Verify at the actual site:
  *  Navigate to the HTTPS web page using Firefox (eg. 41.0.2) web browser.
  *  Click padlock (left of URL bar) > More information > View Certificate


## References

Main references:

- https://www.geocerts.com/install/cpanel_11
- https://documentation.cpanel.net/display/ALD/SSL+TLS+-+WHM
- https://documentation.cpanel.net/display/ALD/SSL+FAQ+and+Troubleshooting
- http://stackoverflow.com/questions/6753619/public-key-certificate-and-private-key-doesnt-match-when-using-godaddy-issued/14403235#14403235
- https://www.digicert.com/ssl-support/pem-ssl-creation.htm
- https://www.geocerts.com/ssl_checker

Other interesting references:

- https://forums.cpanel.net/threads/ssl-trouble-installing-intermediate-certificate.413721/
- https://www.liquidweb.com/kb/install-a-ssl-certificate-on-a-domain-using-cpanel/
- https://www.digicert.com/ssl-certificate-installation-apache-cpanel.htm

