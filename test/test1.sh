#!/bin/sh

set -eu

cd "$(dirname -- "$0")"

rm -Rf test-ca/

../create-root-ca -l -d test-ca <<EOF
test-ca
bogus.com
US
California
San Francisco
Bogus Inc.
Operations
Bogus Inc. Certificate Authority
rootCA_password
rootCA_password
EOF

cd test-ca/

./bin/create-server -s test-server.bogus.com -a www.test-server.bogus.com << EOF
rootCA_password
San Francisco
Jurisdiction of test-server.bogus.com
EOF

./bin/create-client -c test-client << EOF
rootCA_password
San Francisco
private
test-client@bogus.com
EOF

./bin/revoke-cert -c certs/server/test-server-bogus-com/test-server-bogus-com.crt << EOF
1
y
rootCA_password
EOF

./bin/create-signing-ca -d test-signing << EOF
rootCA_password
test-signing
bogus.com
US
California
San Francisco
Bogus Inc.
Operations
Bogus Inc. Certificate test-signing
signCA_password
signCA_password
EOF

./bin/show-status

./bin/gen-html

cd test-signing/

./bin/create-server -s test-server.bogus.com -a www.test-server.bogus.com << EOF
signCA_password
San Francisco
Jurisdiction of test-server.bogus.com
EOF

./bin/renew-cert -s test-server-bogus-com -t server << EOF
signCA_password
EOF

./bin/create-client -c test-client << EOF
signCA_password
San Francisco
private
test-client@bogus.com
EOF

./bin/renew-cert -s test-client -t client << EOF
signCA_password
EOF

./bin/revoke-cert -c certs/server/test-server-bogus-com/test-server-bogus-com.crt.old << EOF
1
y
signCA_password
EOF

./bin/revoke-cert -c certs/clients/test-client/test-client.crt.old << EOF
5
y
signCA_password
EOF

openssl req -nodes -new -newkey rsa:2048 -sha256 -out csr.pem << EOF
AU
Some-State
Locality
Organization Name
Organizational Unit Name
csr-test
test@bogus.com


EOF

./bin/sign-csr -c csr.pem << EOF
signCA_password
EOF

./bin/show-status

./bin/gen-html


echo
echo
echo "TEST SUCCESSFUL"
echo
echo
