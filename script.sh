#!/bin/bash

# Authors - Neil "regalstreak" Agarwal, Harsh "MSF Jarvis" Shandilya, Tarang "DigiGoon" Kagathara
# 2017
# -----------------------------------------------------
# Modified by - Rokib Hasan Sagar @rokibhasansagar
# To be used to Release on AndroidFileHost
# -----------------------------------------------------

# Definitions
DIR=$(pwd)
RecName=$1
LINK=$2
BRANCH=$3
GitHubMail=$4
GitHubName=$5
FTPHost=$6
FTPUser=$7
FTPPass=$8

# Colors
CL_XOS="\033[34;1m"
CL_PFX="\033[33m"
CL_INS="\033[36m"
CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

# Get the latest repo
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Github Authorization
git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true

# Main Function Starts HERE
cd $DIR; mkdir $RecName; cd $RecName

# Initialize the repo data fetching
repo init -q -u $LINK -b $BRANCH --depth 1

# Sync it up!
time repo sync -c -f --force-sync --no-clone-bundle --no-tags -j32
echo -e $CL_RED"\nSHALLOW Source Syncing done"$CL_RST

rm -rf .repo/

# Compress non-repo folder in one piece
echo -e $CL_RED"Compressing files ---  "$CL_RST

export XZ_OPT=-9e
time tar -I pxz -cf $RecName-$BRANCH-norepo-$(date +%Y%m%d).tar.xz *

# Show Total Sizes of the compressed files
echo -en $CL_BLU"Final Compressed size of the checked-out files is ---  "$CL_RST
du -sh $RecName-$BRANCH-norepo*.tar.xz

# Basic Cleanup
mv $RecName-$BRANCH* upload/
cd .. && rm -rf $RecName

cd upload
echo -e $CL_PFX" Taking md5sums "$CL_RST
md5sum $RecName-$BRANCH* > $RecName-$BRANCH-norepo-$(date +%Y%m%d).md5sum

for file in $RecName-$BRANCH*; do wput $file ftp://"$FTPUser":"$FTPPass"@"$FTPHost"//$RecName-NoRepo/ ; done
echo -e $CL_XOS" Done uploading "$CL_RST

cd $DIR
echo -e $CL_GRN"\nCongratulations! Job Done!"$CL_RST
