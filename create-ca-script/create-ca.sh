#!/bin/bash
set -e

BASE_DIR="./pki"
ROOT_DIR="$BASE_DIR/root"
INT_DIR="$BASE_DIR/intermediate"
WEB_DIR="$BASE_DIR/web"

# ============================================================
# Helper: Create directory structure
# ============================================================
init_ca_structure() {
    local DIR=$1
    mkdir -p $DIR/{certs,crl,newcerts,private,csr}
    chmod 700 $DIR/private
    touch $DIR/index.txt
    echo 1000 > $DIR/serial
}

# ============================================================
# Create OpenSSL config
# ============================================================
create_openssl_conf() {
    local DIR=$1
    local NAME=$2

    cat > "$DIR/openssl.cnf" <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = $DIR
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
private_key       = \$dir/private/${NAME}.key.pem
certificate       = \$dir/certs/${NAME}.cert.pem
default_md        = sha256
policy            = policy_loose
email_in_dn       = no
copy_extensions   = copy

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only

[ req_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = DE
stateOrProvinceName = State
localityName        = City
organizationName    = Organization
commonName          = Common Name

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_server ]
basicConstraints = CA:false
nsCertType = server
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
EOF
}

# ============================================================
# Create Root CA
# ============================================================
create_root_ca() {
    echo "=== Creating Root CA ==="
    init_ca_structure $ROOT_DIR
    create_openssl_conf $ROOT_DIR "root"

    openssl genrsa -out $ROOT_DIR/private/root.key.pem 4096
    chmod 400 $ROOT_DIR/private/root.key.pem

    openssl req -config $ROOT_DIR/openssl.cnf \
        -key $ROOT_DIR/private/root.key.pem \
        -new -x509 -days 3650 -sha256 \
        -subj "/CN=RootCA" \
        -extensions v3_ca \
        -out $ROOT_DIR/certs/root.cert.pem
}

# ============================================================
# Create Intermediate CA
# ============================================================
create_intermediate_ca() {
    echo "=== Creating Intermediate CA ==="
    init_ca_structure $INT_DIR
    create_openssl_conf $INT_DIR "intermediate"

    openssl genrsa -out $INT_DIR/private/intermediate.key.pem 4096
    chmod 400 $INT_DIR/private/intermediate.key.pem

    openssl req -config $INT_DIR/openssl.cnf \
        -new -sha256 \
        -subj "/CN=IntermediateCA" \
        -key $INT_DIR/private/intermediate.key.pem \
        -out $INT_DIR/csr/intermediate.csr.pem

    openssl ca -config $ROOT_DIR/openssl.cnf \
        -extensions v3_intermediate_ca \
        -days 1825 -notext -md sha256 \
        -in $INT_DIR/csr/intermediate.csr.pem \
        -out $INT_DIR/certs/intermediate.cert.pem \
        -batch
}

# ============================================================
# Create Web/Server CA
# ============================================================
create_web_ca() {
    echo "=== Creating Web/Server CA ==="
    init_ca_structure $WEB_DIR
    create_openssl_conf $WEB_DIR "web"

    openssl genrsa -out $WEB_DIR/private/web.key.pem 4096
    chmod 400 $WEB_DIR/private/web.key.pem

    openssl req -config $WEB_DIR/openssl.cnf \
        -new -sha256 \
        -subj "/CN=WebCA" \
        -key $WEB_DIR/private/web.key.pem \
        -out $WEB_DIR/csr/web.csr.pem

    openssl ca -config $ROOT_DIR/openssl.cnf \
        -extensions v3_server \
        -days 825 -notext -md sha256 \
        -in $WEB_DIR/csr/web.csr.pem \
        -out $WEB_DIR/certs/web.cert.pem \
        -batch
}

# ============================================================
# Renewal function
# ============================================================
renew_cert() {
    local CA_DIR=$1
    local NAME=$2
    local DAYS=$3

    echo "=== Renewing certificate for $NAME ==="

    openssl ca -config $CA_DIR/openssl.cnf \
        -in $CA_DIR/csr/${NAME}.csr.pem \
        -days $DAYS -notext -md sha256 \
        -out $CA_DIR/certs/${NAME}.renewed.cert.pem \
        -batch
}

# ============================================================
# Main Menu
# ============================================================
case "$1" in
    init)
        create_root_ca
        create_intermediate_ca
        create_web_ca
        ;;
    renew-root)
        renew_cert $ROOT_DIR "root" 3650
        ;;
    renew-intermediate)
        renew_cert $INT_DIR "intermediate" 1825
        ;;
    renew-web)
        renew_cert $WEB_DIR "web" 825
        ;;
    *)
        echo "Usage:"
        echo "  $0 init                # Create full PKI"
        echo "  $0 renew-root          # Renew Root CA"
        echo "  $0 renew-intermediate  # Renew Intermediate CA"
        echo "  $0 renew-web           # Renew Web CA"
        ;;
esac
