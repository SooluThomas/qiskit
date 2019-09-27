#!/bin/bash

# This code is part of Qiskit.
#
# (C) Copyright IBM 2018, 2019.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

# Script for pushing the documentation to the qiskit.org repository.

# Non-travis variables used by this script.
TARGET_REPOSITORY="git@github.com:SooluThomas/testTranslation.git"
TARGET_DOC_REPO_DIR=$(mktemp -d)
TARGET_DOC_DIR="$TARGET_DOC_REPO_DIR/"
SOURCE_DOC_DIR="docs/_build/html"
SOURCE_DIR=`pwd`
SOURCE_LANG='en'
TRANSLATION_LANG='ja'

SOURCE_REPOSITORY="git@github.com:SooluThomas/qiskit.git"
TARGET_BRANCH_PO="poRepo"
DOC_DIR_2="docs/locale"

build_old_versions () {
    echo "Inside build old versions"
    pushd $SOURCE_DIR
    # Build stable docs
    while IFS=' ' read -ra VERSIONS; do
        for version in "${VERSIONS[@]}"; do
            echo "$version"
            if [[ $version == "0.7*" ]] ; then
                continue
            fi
            if [ -d "$TARGET_DOC_DIR/stable/$version" ] ; then
                continue
            fi
            git checkout $version
            virtualenv $version
            $version/bin/pip install .
            $version/bin/pip install -r ../requirements-dev.txt
            rm -rf $SOURCE_DIR/$SOURCE_DOC_DIR
            $version/bin/sphinx-build -b html docs docs/_build/html
            cp -r $SOURCE_DIR/$SOURCE_DOC_DIR $TARGET_DOC_DIR/stable/$version
        done
    done <<< "$(git tag --sort=-creatordate)"
    popd
}

# Build the documentation.
echo "make doc"
make doc
echo "end of make doc"

echo "show current dir: "
pwd

echo "cd docs"
cd docs

# Extract document's translatable messages into pot files
# https://sphinx-intl.readthedocs.io/en/master/quickstart.html
echo "Extract document's translatable messages into pot files: "
sphinx-build -b gettext -D language=en . _build/gettext

# Setup / Update po files
echo "Setup / Update po files"
sphinx-intl update -p _build/gettext -l en

# Setup the deploy key.
# https://gist.github.com/qoomon/c57b0dc866221d91704ffef25d41adcf
echo "set ssh"
pwd
set -e
openssl aes-256-cbc -K $encrypted_a301093015c6_key -iv $encrypted_a301093015c6_iv -in ../tools/github_deploy_key.enc -out github_deploy_key -d
chmod 600 github_deploy_key
eval $(ssh-agent -s)
ssh-add github_deploy_key
echo "end of configuring ssh"

# Clone to the working repository for .po and pot files
cd ..
pwd
echo "git clone for working repo"
git clone --depth 1 $SOURCE_REPOSITORY temp --single-branch --branch $TARGET_BRANCH_PO
cd temp
git branch
git config user.name "Qiskit Autodeploy"
git config user.email "qiskit@qiskit.org"

echo "git rm -rf for the translation po files"
# git rm -rf --ignore-unmatch $DOC_DIR_2/$TRANSLATION_LANG/**/*.po
git rm -rf --ignore-unmatch $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/$TRANSLATION_LANG/*.po \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/*.po \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/_* \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/aer \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/autodoc \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/aqua \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/terra \
    $DOC_DIR_2/$SOURCE_LANG/LC_MESSAGES/ignis

# Copy the new rendered files and add them to the commit.

rm -rf $SOURCE_DIR/$DOC_DIR_2/en/LC_MESSAGES/autodoc/

echo "copy directory"
cp -r $SOURCE_DIR/$DOC_DIR_2/ docs/

# git checkout translationDocs
echo "add to po files to target dir"
git add $DOC_DIR_2
ls

# Commit and push the changes.
echo "git commit"
git commit -m "Automated documentation update to add .po files from meta-qiskit" -m "Commit: $TRAVIS_COMMIT" -m "Travis build: https://travis-ci.com/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
echo "git push"
git push --quiet origin $TARGET_BRANCH
ls
echo "********** End of pushing po to working repo! *************"

# Clone the landing page repository.
cd ..
pwd
echo "git clone for landing page repo"
git clone --depth 1 $TARGET_REPOSITORY $TARGET_DOC_REPO_DIR
cd $TARGET_DOC_REPO_DIR
git config user.name "Qiskit Autodeploy"
git config user.email "qiskit@qiskit.org"

# Selectively delete files from the dir, for preserving versions and languages.
echo "git rm -rf"
git rm -rf --ignore-unmatch $TARGET_DOC_DIR/*.html \
    $TARGET_DOC_DIR/_* \
    $TARGET_DOC_DIR/aer \
    $TARGET_DOC_DIR/autodoc \
    $TARGET_DOC_DIR/aqua \
    $TARGET_DOC_DIR/terra \
    $TARGET_DOC_DIR/ignis

# Copy the new rendered files and add them to the commit.
echo "copy directory"

mkdir -p $TARGET_DOC_DIR
cp -r $SOURCE_DIR/$SOURCE_DOC_DIR/* $TARGET_DOC_DIR/

# Check if directory exists or not
# if [ ! -d $TARGET_DOC_DIR/ ]
# then
#     mkdir -p $TARGET_DOC_DIR && cp -r $SOURCE_DIR/$SOURCE_DOC_DIR/* $TARGET_DOC_DIR/
# else
#     cp -r $SOURCE_DIR/$SOURCE_DOC_DIR/* $TARGET_DOC_DIR/
# fi

build_old_versions

ls $TARGET_DOC_DIR/

# git checkout translationDocs
echo "add to target dir"
git add $TARGET_DOC_DIR

# Commit and push the changes.
echo "git commit"
git commit -m "Automated documentation update from meta-qiskit" -m "Commit: $TRAVIS_COMMIT" -m "Travis build: https://travis-ci.com/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
echo "git push"
git push --quiet
