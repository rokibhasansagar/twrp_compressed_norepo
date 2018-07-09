#!/bin/bash

# Authors - Neil "regalstreak" Agarwal, Harsh "MSF Jarvis" Shandilya, Tarang "DigiGoon" Kagathara
# 2017
# -----------------------------------------------------
# Modified by - Rokib Hasan Sagar @rokibhasansagar
# To be used to Release on AndroidFileHost
# -----------------------------------------------------

# Definitions
DIR=$(pwd)
echo $DIR
RecName=$1
LINK=$2
BRANCH=$3
GitHubMail=$4
GitHubName=$5
FTPHost=$6
FTPUser=$7
FTPPass=$8

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install pxz wput -y
wget -q 'https://github.com/tcnksm/ghr/releases/download/v0.10.1/ghr_v0.10.1_linux_amd64.tar.gz'
tar -xzf ghr_v0.10.1_linux_amd64.tar.gz && rm ghr_v0.10.1_linux_amd64.tar.gz
mkdir ~/bin; cp ghr_v0.10.1_linux_amd64/ghr ~/bin && PATH=~/bin:$PATH
rm -rf ghr_v0.10.1_linux_amd64/

# Get the latest repo
mkdir ~/bin; PATH=~/bin:$PATH
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
time repo sync -c -f -q --force-sync --no-clone-bundle --no-tags -j32
echo -e "\nSHALLOW Source Syncing done\n"

rm -rf .repo/

# Show Total Sizes of the checked-out non-repo files
cd $DIR
echo -en "The total size of the checked-out files is ---  "
du -sh $RecName
cd $RecName

# Compress non-repo folder in one piece
echo -e "Compressing files ---  "

export XZ_OPT=-9e
time tar -I pxz -cf $RecName-$BRANCH-norepo-$(date +%Y%m%d).tar.xz *
echo -e "Compression Done"

mkdir -p ~/project/files/ && mv $RecName-$BRANCH-norepo-$(date +%Y%m%d).tar.xz ~/project/files/
cd ~/project/files && md5sum $RecName*.tar.xz > $RecName-$BRANCH-norepo-$(date +%Y%m%d).md5sum

# Show Total Sizes of the compressed files
echo -en "Final Compressed size of the checked-out files is ---  "
du -sh ~/project/files/

cd $DIR
# Basic Cleanup
rm -rf $RecName

cd ~/project/files/
for file in $RecName-$BRANCH*; do wput $file ftp://"$FTPUser":"$FTPPass"@"$FTPHost"//$RecName-NoRepo/ ; done
echo -e " Done uploading "
echo -e "\nCongratulations! Job Done!"