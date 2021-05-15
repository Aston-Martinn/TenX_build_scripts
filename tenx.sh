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
    echo -e "$green Enter the name of the ROM directory : $nocol"
    read dir
    echo -e "$green Entered Directory name is $dir $nocol"
    echo -e ""
}

# Device name
function device_name() {
    echo -e "$blue Enter your Device name (Small letters only) : $nocol"
    read device
    echo -e "$green Entered Device name is $device $nocol"
    echo -e ""
}

# Device codename
function device_codename() {
    echo -e "$red Enter your Device Codename : $nocol"
    read codename
    echo -e "$green Entered Device codename is $codename $nocol"
    echo -e ""
}

# Create directory
function create_dir() {
    echo -e "$yellow Directory has be created Succussfully. $nocol"
    mkdir $dir
    cd $dir
}

# Clone Realme XT's Trees if codename is RMX1921
function clone_xt() {
    git clone --quiet https://github.com/Ten-X-Devices/device_realme_RMX1921.git -b eleven device/realme/RMX1921 > /dev/null
    git clone --quiet https://github.com/Ten-X-Devices/kernel_realme_sdm710.git -b eleven kernel/realme/sdm710 > /dev/null
    git clone --quiet https://github.com/Ten-X-Devices/vendor_realme_RMX1921.git -b eleven vendor/realme/RMX1921 > /dev/null
}

function what_to_do() {
   echo -e "$red What you would like to do? $nocol"
   echo -e "$yellow 1. Sync, Build & Upload. $nocol"
   echo -e "$yellow 2. Build & upload only. $nocol"
   echo -e "$yellow 3. Upload only. $nocol"
   echo -e "$green Enter your choice: $nocol"
   read to_do
   echo -e "$red Your choice was $to_do $nocol"

   case $to_do in
     1)
     create_dir
     sync_tenx
     echo -e ""
     echo -e "$blue Checking for Realme XT (RMX1921) $nocol"
     if [ $codename == RMX1921 ]; then
         echo -e "$green Device detected as Realme XT (RMX1921), Cloning Device Trees! $nocol"
         clone_xt
     else
         echo -e ""
         echo -e "$red Entered codename is not Realme XT, It is $codename, Continuing! $nocol"
     fi
     echo -e ""
     clone_dt
     clone_kt
     clone_vt
     build_tenx
     upload
     ;;
     2)
     echo -e "$green Checking for $dir Directory...$nocol"
     if [[ -d $dir ]]; then
        echo -e "$red $dir Exists, Continuing!$nocol"
     else
        echo -e "$green $dir Doesn't Exists, Exiting!$nocol"
        exit
     fi
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
    echo -e "$green Enter the device tree link : $nocol"
    read dt_link
    echo -e "$yellow Enter the branch name : $nocol"
    read dt_branch
    git clone --quiet $dt_link -b $dt_branch device/$device/$codename > /dev/null

    echo -e "$blue Do you want to modify your device trees as per TenX base ?$nocol"
    echo -e "$green 1. Yes $nocol"
    echo -e "$red 2. No $nocol"
    echo -e "$yellow Enter your choice $nocol"
    read modify
    echo -e "$blue Your choice was $modify $nocol"

    case $modify in
      1)
      modify_tree
      ;;
      2)
      echo -e "$yellow Continuing cloning trees... $nocol"
      ;;
    esac
}

# Auto tree modification
function modify_tree() {
    cd device/$device/$codename
    mv *_$codename.mk aosp_$codename.mk
    mv *.dependencies aosp.dependencies

    echo -e "$cyan What to replace with aosp? $nocol"
    read what_to

    sed -i "s|$what_to|aosp|g" aosp_$codename.mk
    sed -i "s|$what_to|aosp|g" AndroidProducts.mk

    echo -e "$green Checking for Gapps flags $nocol"
    if grep -Fxq "TARGET_GAPPS_ARCH := arm64" aosp_X00T.mk
    then
       echo -e "$cyan Gapps flag exists, Continuing $nocol"
    else
       echo -e "$green Gapps flag doesn't exixts, Adding... $nocol"
       echo "" >> aosp_$codename.mk
       echo "# Ten-X Extras" >> aosp_$codename.mk
       echo "TARGET_GAPPS_ARCH := arm64" >> aosp_$codename.mk
       echo -e "$green You're good to go... $nocol"
    fi

    echo -e "$red Checking for Bootanimation res flag $nocol"
    if grep -Fxq "TARGET_BOOT_ANIMATION_RES := 1080" aosp_X00T.mk
    then
       echo -e "$green Bootanimation flag exists, Continuing $nocol"
    else
       echo -e "$green Bootanimation flag doesn't exists, Adding $nocol"
       echo -e "$yellow Enter the Bootanimation res $nocol"
       read res
       echo "TARGET_BOOT_ANIMATION_RES := $res" >> aosp_$codename.mk
    fi

    git add .
    git commit --quiet -m "$codename: Init TenX-OS" --signoff > /dev/null
    echo -e "$cyan Do you want to push your Device tree? $nocol"
    echo -e "$yellow 1. Yes $nocol"
    echo -e "$yellow 2. No $nocol"
    echo -e "$green Enter your choice $nocol"
    read push
    echo -e "$yellow Your choice was $push $nocol"

    case $push in
     1)
     echo -e "$blue Enter the link of the repo to push $nocol"
     read repo
     git push --quiet -u $repo HEAD:eleven > /dev/null
     ;;
     2)
     echo -e "$red Fine, you can push it later, Continuing! $nocol"
     ;;
   esac
}

# Clone kernel tree
function clone_kt() {
    echo -e "$yellow*************************************************"
    echo -e "                  Cloning Kernel Tree                   "
    echo -e "**************************************************$nocol"
    echo -e "$blue Enter the kernel tree link :$nocol"
    read kt_link
    echo -e "$blue Enter the device platform or the kernel target name : $nocol"
    echo -e "$cyan Example - sdm710 or sdm660 $nocol"
    read target
    echo -e "$cyan Enter the branch name: $nocol"
    read kt_branch
    git clone --quiet $kt_link -b $kt_branch kernel/$device/$target > /dev/null
}

# Clone vendor tree
function clone_vt() {
    echo -e "$green*************************************************"
    echo -e "                 Cloning Vendor Tree                   "
    echo -e "*************************************************$nocol"
    echo -e "$cyan Enter the vendor tree link : $nocol"
    read vt_link
    echo -e "$blue Enter the branch name: $nocol"
    read vt_branch

    # Some device's vendor trees has the files inside their codename, so
    echo -e "$red What is the format to clone your vendor tree ?$nocol"
    echo -e "$yellow 1. vendor/device $yellow"
    echo -e "$yellow 2. vendor/device/codename $yellow"
    echo -e "$green Enter your choice: $nocol"
    read ch
    echo -e "$blue Your choice was $ch $nocol"


    case $ch in
      1)
      git clone --quiet $vt_link -b $vt_branch vendor/$device > /dev/null
      ;;
      2)
      git clone --quiet $vt_link -b $vt_branch vendor/$device/$codename > /dev/null
      ;;
      *)
      echo -e "$red Invalid option, Exiting!$nocol"
      exit
      ;;
    esac
}

# Clean build or dirty build
function build_make() {
   echo -e "$green Do you want to clean build ?$nocol"
   echo -e "$red 1. Yes $nocol"
   echo -e "$red 2. No $nocol"
   echo -e "$green Enter your choice $nocol"
   read  make_build
   echo -e "$blue Your choice was $ch $nocol"

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
     echo -e "$red Invalid option, Exiting! $nocol"
     exit
     ;;
   esac
}

# Build type
function build_type() {
    echo -e "$green Choose the build type :$nocol"
    echo -e "$red 1. Unofficial $nocol"
    echo -e "$blue 2. Official $nocol"
    echo -e "$yellow 3. Developer $nocol"
    echo -e "$green Enter your choice $nocol"
    read build_type
    echo -e "$blue Your choice was $ch $nocol"

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
      echo -e "$yellow Invalid option, Exiting! $nocol"
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
}

# Upload
function upload() {
    # Check for TenX-OS zip file
    echo -e "$blue Do you want to upload your build? $nocol"
    echo -e "$red 1. Yes $nocol"
    echo -e "$green 2. No $nocol"
    echo -e "$cyan Enter your choice $nocol"
    read upload
    echo -e "$blue Your choice was $upload $nocol"

    case $upload in
      1)
      $upload_to
      ;;
      2)
      exit
      ;;
      *)
      echo -e "$cyan Invalid option, Exiting! $nocol"
      exit
      ;;
    esac

    echo -e "$green Please choose where to upload your build: $nocol"
    echo -e "$yellow 1. Gdrive $nocol"
    echo -e "$red 2. Mega $nocol"
    echo -e "$green 3. Sourceforge $nocol"
    echo -e "$cyan Enter your choice $nocol"
    read upload_to

    case $upload_to in
      1)
      echo -e "$blue**************************************************"
      echo -e "                    Uploading to Gdrive                "
      echo -e "*************************************************$nocol"
      echo -e "$cyan Checking for gdrive upload $nocol"
      if [[ -f /usr/local/bin/gdrive ]]; then
         echo -e "$green Gdrive File exists, Uploading $nocol"
      else
         echo -e "$red Gdrive file doesn't exists, Please install Gdrive. Exiting. $nocol"
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
      echo -e "$blue Checking for mega upload $nocol"
      if [[ -f /usr/local/bin/rmega-up ]]; then
         echo -e "$yellow Mega File Exists, uploading $nocol"
      else
        echo -e "$red Mega file doesn't exists, please install mega. Exiting. $nocol"
        exit
      fi
      cd out/target/product/$codename
      echo -e "$green Enter your mega Email id : $nocol"
      read email
      rmega-up TenX-OS*.zip -u $email
      exit
      ;;
      3)
      echo -e "$green Checking whether the build is Official or not $nocol"
      if [[ $build_type -eq 2 ]]; then
          echo -e "$green Official build found. $nocol"
      else
          echo -e "$red Your build is not Official, Exiting! $nocol"
          exit
      fi
      echo -e "$blue**************************************************"
      echo -e "                    Uploading to Sourceforge           "
      echo -e "*************************************************$nocol"
      cd out/target/product/$codename
      echo -e "$yellow Enter your sourceforge username : $nocol"
      read user_name
      sftp $user_name@frs.sourceforge.net
      cd /home/frs/projects/tenxos/$codename
      put TenX-OS*.zip
      exit
      ;;
      *)
      echo -e "$red Invalid option, Exiting! $nocol"
      exit
      ;;
    esac
}

dir_name
device_name
device_codename
what_to_do
