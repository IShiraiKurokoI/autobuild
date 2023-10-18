#!/bin/bash
set -e
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
    # reorganize url into https://{$github_user}:{$github_token}@{$github_url}
    GITHUB_URL=$(echo $2 | sed -e 's/https:\/\///g')
    CREDENTIALS=$(echo $GITHUB_TOKEN@)
    if [[ $CREDENTIALS == ":@" ]]
    then
        CREDENTIALS=""
    fi
    GITHUB_URL=https://$CREDENTIALS$GITHUB_URL
    echo "Cloning from $GITHUB_URL"
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

