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
SOURCE_REPOSITORY="git@github.com:SooluThomas/qiskit.git"
TARGET_REPOSITORY="git@github.com:SooluThomas/testTranslation.git"
TARGET_DOC_DIR="locale/"
SOURCE_DOC_DIR="docs/_build/html/locale"
SOURCE_DIR=`pwd`
TRANSLATION_LANG="ja pt"



# Setup the deploy key.
# https://gist.github.com/qoomon/c57b0dc866221d91704ffef25d41adcf
echo "set ssh"
pwd
set -e
openssl aes-256-cbc -K $encrypted_a301093015c6_key -iv $encrypted_a301093015c6_iv -in tools/github_deploy_key.enc -out github_deploy_key -d
chmod 600 github_deploy_key
eval $(ssh-agent -s)
ssh-add github_deploy_key
echo "end of configuring ssh"

# Clone the sources and po files
# git clone $SOURCE_REPOSITORY docs_source --single-branch --branch translationDocs
# cp -r docs_source/docs/. $SOURCE_DIR/docs/

# echo "pwd before cd docs"
# pwd
# echo "ls before cd docs"
# ls
# echo "cd docs"
# cd $SOURCE_DIR/docs
# pwd
# ls

cd docs

# Make translated document
# make -e SPHINXOPTS="-Dlanguage='ja'" html
# /locale/$TRANSLATION_LANG/translated/
echo "Make translated document"
sudo apt-get install parallel
# for i in "${TRANSLATION_LANG[@]}"; do
#    echo $i;
#    sphinx-build -b html -D language=$i . _build/html/locale/$i
# done
parallel sphinx-build -b html -D language={} . _build/html/local/{} ::: $TRANSLATION_LANG

# Clone the landing page repository.
cd ..
pwd
echo "git clone for landing page repo"
git clone --depth 1 $TARGET_REPOSITORY tmp 
cd tmp
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

pwd
echo "list directory"
ls
tree
# Copy the new rendered files and add them to the commit.
mkdir -p $TARGET_DOC_DIR
echo "copy directory"
cp -r $SOURCE_DIR/$SOURCE_DOC_DIR/* $TARGET_DOC_DIR/

# git checkout translationDocs
echo "add to target dir"
git status
git add $TARGET_DOC_DIR

# Commit and push the changes.
echo "git commit"
git commit -m "Automated translated documentation update from meta-qiskit" -m "Commit: $TRAVIS_COMMIT" -m "Travis build: https://travis-ci.com/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
echo "git push"
git push --quiet
