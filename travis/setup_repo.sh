#!/bin/bash
# The git clone command in this script is needed because travis always performs git clone using a branch.
# This makes it impossible to get all the branch and tag information needed without fully cloning.
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  COMMIT_SHA=${TRAVIS_COMMIT}
else
  COMMIT_SHA=${TRAVIS_PULL_REQUEST_SHA}
fi

echo "We will use this commit SHA: ${COMMIT_SHA}"
echo "Travis build dir: ${TRAVIS_BUILD_DIR}"
echo "Travis repo slug: ${TRAVIS_REPO_SLUG}"

# This step deletes the shallow clone travis automatically creates on bootstrapping of builds
# so we can do a full clone where travis expects it.
rm -rfv ${TRAVIS_BUILD_DIR} && mkdir ${TRAVIS_BUILD_DIR}

cd $TRAVIS_BUILD_DIR
git clone https://github.com/$TRAVIS_REPO_SLUG.git $TRAVIS_BUILD_DIR/
git checkout -qf $COMMIT_SHA


