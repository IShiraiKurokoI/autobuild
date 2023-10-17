#!/bin/bash

# Downlaod .spec file for packaging
cd /root/rpmbuild/SPECS
curl -o package.spec $1

# install dependencies
dnf builddep -y package.spec

# Download source code with spectool
spectool -g -R package.spec

# Build the package
rpmbuild -ba package.spec

