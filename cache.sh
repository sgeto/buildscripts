#!/bin/bash

set -xe

# debugging
env | sort
df -h
free -g
if [ -d $HOME/android/lineage/ ] ; then
    du -sbh $HOME/android/lineage/*
fi

# init
git config --global user.name $APPVEYOR_REPO_COMMIT_AUTHOR
git config --global user.email $APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL

# Installing Dependencies
mkdir -p $HOME/bin
wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P $HOME/bin
chmod a+x ~/bin/repo
export PATH=$HOME/bin:$PATH

mkdir -p $HOME/android/lineage && cd $HOME/android/lineage

export TOP=$HOME/android/lineage

# Initialize your local repository using the LineageOS trees with a command
# repo init -u git://github.com/LineageOS/android.git -b lineage-16.0

repo init -u git://github.com/LineageOS/android.git --manifest-branch=$APPVEYOR_REPO_BRANCH --no-clone-bundle --depth=1

# Clone the repo:
git clone https://github.com/CustomROMs/android_local_manifests_i9300 .repo/local_manifests -b $APPVEYOR_REPO_BRANCH

# Sync LineageOS trees:
# repo sync --no-tags --no-clone-bundle --force-sync -c -j8
repo sync  --force-broken --force-sync --no-clone-bundle --no-tags --current-branch --quiet --jobs=$(nproc --all)

# Generate the keys used for ROM signing:
# From the root of your Android tree, run these commands, altering the subject line to reflect your information:

if [ ! -d "$TOP/.android-certs" ] ; then
    subject='/C=YE/ST=Aden/L=Aden/O=Blah/OU=BlahBlahBlah/CN=sgeto/emailAddress=sgeto@ettercap-project.org'
    # subject="/C=YE/ST=Aden/L=Aden/O=Blah/OU=BlahBlahBlah/CN=$APPVEYOR_ACCOUNT_NAME/emailAddress=$APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL"
    mkdir -p "$TOP/.android-certs"
    for x in releasekey platform shared media testkey; do \
        ./development/tools/make_key .android-certs/$x "$subject"; \
    done
fi

# repo archive

# To build:
  # . build/envsetup.sh
  # lunch lineage_i9300-userdebug
  # make -j8 bacon
