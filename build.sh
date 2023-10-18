#!/bin/bash

# If using url:
if [[ $1 == "--url" ]]
then
    # Downlaod .spec file for packaging
    cd /root/rpmbuild/SPECS
    curl -o package.spec $2
    SPEC_FILE=package.spec
    echo "SPEC_FILE: $SPEC_FILE"
else if [[ $1 == "--git" ]]
then # if using git repository
    # Clone git repository
    cd /tmp
    if [[ $GITHUB_USER != "notconfigured" ]]
    then
        git config --global user.name $GITHUB_USER
    fi
    if [[ $GITHUB_EMAIL != "notconfigured" ]]
    then
        git config --global user.email $GITHUB_EMAIL
    fi
    if [[ $GITHUB_ACCESS_TOKEN != "notconfigured" ]]
    then
        git config --global user.password $GITHUB_ACCESS_TOKEN
    fi
    git clone $2 repo
    # Switch to the cloned repository and switch branch
    cd repo
    git checkout GITHUB_BRANCH
    # Copy .spec file to /root/rpmbuild/SPECS
    find . -name "*.spec" -exec cp {} /root/rpmbuild/SPECS \;
    # Get the name of the .spec file
    SPEC_FILE=$(find . -name "*.spec")
    echo "SPEC_FILE: $SPEC_FILE"
    # if build sequence file exist, use it as SPEC_FILE list
    test -f build-sequence && SPEC_FILE=$(cat build-sequence)
    echo "SPEC_FILE: $SPEC_FILE"
fi
fi

# enter loop to build all .spec files
for SPEC in $SPEC_FILE; do
# install dependencies
    echo "Installing dependencies"
    dnf builddep -y $SPEC

    # Download source code with spectool
    echo "Downloading source code"
    spectool -g -R $SPEC

    # Build the package
    echo "Building package"
    rpmbuild -ba $SPEC

    # Copy the RPMs to the output directory
    echo "Copying RPMs to output directory"
    cp /root/rpmbuild/RPMS/*/*.rpm /output
done

