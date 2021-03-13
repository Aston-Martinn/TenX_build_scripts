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

# Create directory & enter it
mkdir 10x && cd 10x

# Sync TenX Sources
echo -e "$red*************************************************"
echo -e "            Initializing TenX repos                  "
echo -e "***********************************************$nocol"
repo init -u git://github.com/TenX-OS/manifest_TenX -b eleven
echo -e "$red*************************************************"
echo -e "            Initialized TenX Repos                   "
echo -e "***********************************************$nocol"

# Sync TenX Repos
echo -e "$blue*************************************************"
echo -e "                 Syncing TenX Repos                   "
echo -e "************************************************$nocol"
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
echo -e "$yellow*************************************************"
echo -e "                 Syncing Completed                      "
echo -e "**************************************************$nocol"

# Clone the device trees
function clone_xt() {
git clone https://github.com/KharaMe-devs/android_device_realme_RMX1921.git -b eleven device/realme/RMX1921
git clone https://github.com/KharaMe-devs/android_device_realme_sdm710-common.git -b xt device/realme/sdm710-common
git clone https://github.com/KharaMe-devs/proprietary_vendor_realme.git -b eleven vendor/realme
git clone https://github.com/KharaMe-devs/android_kernel_realme_sdm710.git -b XT kernel/realme/sdm710
}

function clone_asus() {
git clone https://github.com/Ten-X-Devices/device_asus_X00T.git -b eleven device/asus/X00T
git clone https://github.com/Ten-X-Devices/vendor_asus.git -b eleven vendor/asus
git clone https://github.com/ArrowOS-Devices/android_kernel_asus_X00T.git -b arrow-11.0 kernel/asus/sdm660
}

# Build commands
function build_10x_for_xt() {
. b*/e*
lumch aosp_RMX1921-userdebug
export CUSTOM_BUILD_TYPE=Official
source ~/.bashrc
export USE_CCACHE=1
ccache -M 100G
brunch RMX1921 | tee build.log
}

function build_10x_for_asus() {
. b*/e*
lumch aosp_X00T-userdebug
export CUSTOM_BUILD_TYPE=Official
source ~/.bashrc
export USE_CCACHE=1
ccache -M 100G
brunch X00T | tee build.log
}

function print_exit_status() {
     echo -e "$cyan************************************************"
     echo -e "                 Invalid Choices                     "
     echo -e "***********************************************$nocol"
     exit
}

function set_device() {
case $device in
  1)
  build_10x_for_xt
  ;;
  2)
  build_10x_for_asus
  ;;
  *)
  print_exit_status
  ;;
esac
}

# Options
function options() {
  echo -e " Select your Device "
  echo -e " 1.Realme XT"
  echo -e " 2.Asus Zenfone Max Pro M1"
  echo -n " Your choice : ? "
  read ch

case $ch in
  1) echo -e "$cyan************************************************"
     echo -e "         Cloning Device Trees for Realme XT          "
     echo -e "***********************************************$nocol"
     clone_xt ;;
  2) echo -e "$cyan***********************************************************"
     echo -e "         Cloning Device Trees for Asus Zenfone Max Pro M1       "
     echo -e "**********************************************************$nocol"
     clone_asus ;;
esac

case $ch in
  1)
  clone_xt
  ;;
  2)
  clone_asus
  ;;
  *)
  print_exit_status
  ;;
esac
}

# Build options
function build_options() {
  echo -e " Do you want to start your Build "
  echo -e " 1.Yes"
  echo -e " 2.No"
  echo -n " Your choice : ? "
  read build

case $build in
  1) echo -e "$cyan************************************************"
     echo -e "                         Yes                         "
     echo -e "***********************************************$nocol"
     choose_device
     ;;
  2) echo -e "$cyan************************************************"
     echo -e "                         No                         "
     echo -e "***********************************************$nocol"
     exit
     ;;
  *)
     print_exit_status
     ;;
esac

# Choose device
function choose_device() {
  echo -e " Choose your Device "
  echo -e " 1.Realme XT"
  echo -e " 2.Asus Zenmfone Max Pro M1"
  echo -n " Your choice : ? "
  read device

case $device in
  1) echo -e "$cyan************************************************"
     echo -e "                   Realme XT                         "
     echo -e "***********************************************$nocol"
     build_10x_for_xt ;;
  2) echo -e "$cyan***********************************************************"
     echo -e "                  Asus Zenfone Max Pro M1                       "
     echo -e "**********************************************************$nocol"
     build_10x_for_asus ;;
esac

case $build in
  1)
  set_device
  ;;
  2)
  exit
  ;;
  *)
  exit
  ;;
esac
 }
}

options
build_options
choose_device
set_device
