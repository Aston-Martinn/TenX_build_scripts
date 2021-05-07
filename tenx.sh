#!/bin/bash

# Colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
green='\033[32m'
nocol='\033[0m'

# Print Aston-martinn
echo -e "$red  █████╗ ███████╗████████╗ ██████╗ ███╗   ██╗      ███╗   ███╗ █████╗ ██████╗ ████████╗██╗███╗   ██╗███╗   ██╗$nocol"
echo -e "$red ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗████╗  ██║      ████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██║████╗  ██║████╗  ██║$nocol"
echo -e "$red ███████║███████╗   ██║   ██║   ██║██╔██╗ ██║█████╗██╔████╔██║███████║██████╔╝   ██║   ██║██╔██╗ ██║██╔██╗ ██║$nocol"
echo -e "$red ██╔══██║╚════██║   ██║   ██║   ██║██║╚██╗██║╚════╝██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║██║╚██╗██║██║╚██╗██║$nocol"
echo -e "$red ██║  ██║███████║   ██║   ╚██████╔╝██║ ╚████║      ██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ██║██║ ╚████║██║ ╚████║$nocol"
echo -e "$red ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝      ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝$nocol"

# Simple bash script to compile TenX-OS

# Directory name
function dir_name() {
    echo -e "Enter the name of the ROM directory :"
    read dir
}

# Device name
function device_name() {
    echo -e "Enter your Device name :"
    read device
}

# Device codename
function device_codename() {
    echo -e "Enter your Device Codename :"
    read codename
}

# Create directory
function create_dir() {
    mkdir $dir
    cd $dir
}

function what_to_do() {
   echo -e "What you would like to do?"
   echo -e "1. Sync, Build & Upload."
   echo -e "2. Build & upload only."
   echo -e "3. Upload only."
   read to_do

   case $to_do in
     1)
     create_dir
     sync_tenx
     clone_dt
     clone_kt
     clone_vt
     build_tenx
     upload
     ;;
     2)
     cd $dir
     build_make
     build_tenx
     upload
     ;;
     3)
     cd $dir
     upload
     ;;
   esac
}

# Sync TenX-OS
function sync_tenx() {
    echo -e "$red*************************************************"
    echo -e "            Initializing TenX repos                  "
    echo -e "***********************************************$nocol"
    repo init -u git://github.com/TenX-OS/manifest_TenX -b eleven
    echo -e "$red*************************************************"
    echo -e "            Initialized TenX Repos                   "
    echo -e "***********************************************$nocol"
    echo -e "$blue*************************************************"
    echo -e "                 Syncing TenX Repos                   "
    echo -e "************************************************$nocol"
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    echo -e "$yellow*************************************************"
    echo -e "                 Syncing Completed                      "
    echo -e "**************************************************$nocol"
}

# Clone device trees
function clone_dt() {
    echo -e "$cyan*************************************************"
    echo -e "                Cloning Device Tree                   " 
    echo -e "************************************************$nocol"
    echo -e "Enter the device tree link :"
    read dt_link
    echo -e "Enter the branch name: "
    read dt_branch
    git clone --quiet $dt_link -b $dt_branch device/$device/$codename > /dev/null

    echo -e "Do you want to modify your device trees as per TenX base ?"
    echo -e "1. Yes"
    echo -e "2. No"
    read modify

    case $modify in
      1)
      modify_tree
      ;;
      2)
      echo -e "Continuing cloning trees"
      ;;
    esac
}

# Auto tree modification
function modify_tree() {
    cd device/$device/$codename
    mv *_$codename.mk aosp_$codename.mk
    mv *.dependencies aosp.dependencies

    echo -e "What to replace with aosp?"
    read what_to

    sed -i "s|$what_to|aosp|g" aosp_$codename.mk
    sed -i "s|$what_to|aosp|g" AndroidProducts.mk

    echo -e "Checking for Gapps flags"
    if grep -Fxq "TARGET_GAPPS_ARCH := arm64" aosp_X00T.mk
    then
       echo -e "Gapps flag exists, Continuing"
    else
       echo -e "Gapps flag doesn't exixts, Adding"
       echo "" >> aosp_$codename.mk
       echo "# Ten-X Extras" >> aosp_$codename.mk
       echo "TARGET_GAPPS_ARCH := arm64" >> aosp_$codename.mk
    fi

    echo -e "Checking for Bootanimation res flag"
    if grep -Fxq "TARGET_BOOT_ANIMATION_RES := 1080" aosp_X00T.mk
    then
       echo -e "Bootanimation flag exists, Continuing"
    else
       echo -e "Bootanimation flag doesn't exists, Adding"
       echo -e "Enter the Bootanimation res"
       read res
       echo "TARGET_BOOT_ANIMATION_RES := $res" >> aosp_$codename.mk
    fi

    git add .
    git commit --quiet -m "$codename: Init TenX-OS" --signoff > /dev/null
    echo -e "Do you want to push your Device tree?"
    echo -e "1. Yes"
    echo -e "2. No"
    read push

    case $push in
     1)
     echo -e "Enter the link of the repo to push"
     read repo
     git push -u $repo HEAD:eleven
     ;;
     2)
     echo -e "Fine, you can puish it later, Continuing!"
     ;;
   esac
}

# Clone kernel tree
function clone_kt() {
    echo -e "$yellow*************************************************"
    echo -e "                  Cloning Kernel Tree                   "
    echo -e "**************************************************$nocol"
    echo -e "Enter the kernel tree link :"
    read kt_link
    echo -e "Enter the device platform or the kernel target name : "
    echo -e "Example - sdm710 or sdm660"
    read target
    echo -e "Enter the branch name: "
    read kt_branch
    git clone --quiet $kt_link -b $kt_branch kernel/$device/$target > /dev/null
}

# Clone vendor tree
function clone_vt() {
    echo -e "$green*************************************************"
    echo -e "                 Cloning Vendor Tree                   "
    echo -e "*************************************************$nocol"
    echo -e "Enter the vendor tree link : "
    read vt_link
    echo -e "Enter the branch name: "
    read vt_branch

    # Some device's vendor trees has the files inside their codename, so
    echo -e "What is the format to clone your vendor tree ?"
    echo -e "1. vendor/device"
    echo -e "2. vendor/device/codename"
    read ch

    case $ch in
      1)
      git clone --quiet $vt_link -b $vt_branch vendor/$device > /dev/null
      ;;
      2)
      git clone --quiet $vt_link -b $vt_branch vendor/$device/$codename > /dev/null
      ;;
      *)
      echo -e "Invalid option, Exiting!"
      exit
      ;;
    esac
}

# Clean build or dirty build
function build_make() {
   echo -e "Do you want to clean build ?"
   echo -e "1. Yes"
   echo -e "2. No"
   read  make_build

   case $make_build in
     1)
     . b*/e*
     make clean
     make clobber
     ;;
     2)
     $build_tenx
     ;;
     *)
     echo -e "Invalid option, Exiting!"
     exit
     ;;
   esac
}

# Build type
function build_type() {
    echo -e "Choose the build type :"
    echo -e "1. Unofficial"
    echo -e "2. Official"
    echo -e "3. Developer"
    read build_type

    case $build_type in
      1)
      export CUSTOM_BUILD_TYPE=UnOfficial
      ;;
      2)
      export CUSTOM_BUILD_TYPE=Official
      ;;
      3)
      export CUSTOM_BUILD_TYPE=Developer
      ;;
      *)
      echo -e "Invalid option, Exiting!"
      exit
      ;;
    esac
}

# Time to cook TenX-OS
function build_tenx() {
     echo -e "$blue**************************************************"
     echo -e "                    Building TenX-OS                   "
     echo -e "*************************************************$nocol"
     . build/envsetup.sh
     lunch aosp_$codename-userdebug
     build_type
     source ~/.bashrc
     export USE_CCACHE=1
     ccache -M 30G
     brunch $codename | tee build.log

     local ret=$?
     if [[ $ret -eq 0 ]]; then
        upload
     else
        echo -e "Error occured"
        exit
     fi
}

# Upload
function upload() {
    # Check for TenX-OS zip file
    echo -e "Do you want to upload your build?"
    echo -e "1. Yes"
    echo -e "2. No"
    read upload

    case $upload in
      1)
      $upload_to
      ;;
      2)
      exit
      ;;
      *)
      echo -e "Invalid option, Exiting!"
      exit
      ;;
    esac

    echo -e "Please choose where to upload your build: "
    echo -e "1. Gdrive"
    echo -e "2. Mega"
    echo -e "2. Sourceforge"
    echo -e "Option 3 is only for Official builds"
    read upload_to

    case $upload_to in
      1)
      echo -e "$blue**************************************************"
      echo -e "                    Uploading to Gdrive                "
      echo -e "*************************************************$nocol"
      echo -e "Ckecking for gdrive upload"
      if [[ -f /usr/local/bin/gdrive ]]; then
         echo -e "Gdrive File exists, Uploading"
      else
         echo -e "Gdrive file doesn't exists, Please install Gdrive. Exiting."
         exit
      fi
      cd out/target/product/$codename
      gdrive upload TenX-OS*.zip
      exit
      ;;
      2)
      echo -e "$blue**************************************************"
      echo -e "                    Uploading to Mega                  "
      echo -e "*************************************************$nocol"
      echo -e "Checking for mega upload"
      if [[ -f /usr/local/bin/rmega-up ]]; then
         echo -e "Mega File Exists, uploading"
      else
        echo -e "Mega file doesn't exists, please install mega. Exiting."
        exit
      fi
      cd out/target/product/$codename
      echo -e "Enter your mega Email id :"
      read email
      rmega-up TenX-OS*.zip -u $email
      exit
      ;;
      3)
      echo -e "$blue**************************************************"
      echo -e "                    Uploading to Sourceforge           "
      echo -e "*************************************************$nocol"
      cd out/target/product/$codename
      echo -e "Enter your sourceforge username :"
      read user_name
      sftp $user_name@frs.sourceforge.net
      cd /home/frs/projects/tenxos/$codename
      put TenX-OS*.zip
      exit
      ;;
      *)
      echo -e "Invalid option, Exiting!"
      exit
      ;;
    esac
}

dir_name
device_name
device_codename
what_to_do
