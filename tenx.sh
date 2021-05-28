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

echo -e "$green Who is the Host? $nocol"
read host

if [ $host == Advaith_Bhat ] || [ $host == Advaith-Bhat ] || [ $host == AdvaithBhat ]; then
   echo "Enter the BOT API Key"
   read -s -r key

   TG_BOT_API_KEY=$key
   TG_CHAT_ID=-1001460035339

   [[ -z "${TG_BOT_API_KEY}" ]] && echo "BOT_API_KEY not defined, exiting!" && exit 1
   function sendTG() {
           curl -s "https://api.telegram.org/bot${TG_BOT_API_KEY}/sendmessage" --data "text=${*}&chat_id=${TG_CHAT_ID}&parse_mode=Markdown" >/dev/null
   }

   [[ -z "${TG_BOT_API_KEY}" ]] && echo "BOT_API_KEY not defined, exiting!" && exit 1
   function sendTGLogs() {
           curl -s "https://api.telegram.org/bot${TG_BOT_API_KEY}/sendmessage" --data "text=${*}&chat_id=${TG_CHAT_ID}&parse_mode=Markdown" >/dev/null
   }

   # Full device name
   echo -e "Enter your Full Device name: "
   read full_dev_name

   # Code name
   echo -e "Enter your Device Codename: "
   read c_name

sendTG "Executing my Build Script

▪️Device: \`$full_dev_name\`
▪️Codename: \`$c_name\`
▪️Host: \`Advaith Bhat\`
▪️Host-Machine: \`Kuntao-server\`"
fi

# Your choice
function your_choice() {
    echo -e "$green How would you like to start with? $nocol"
    echo -e "$blue 1. Automated $nocol"
    echo -e "$blue 2. Manual $nocol"
    read my_ch

    if [[ $my_ch -eq 1 ]]; then
        echo -e "$red Warning! This condition is only for Realme XT. $nocol"
        echo -e "$green Do you want to continue? $nocol"
	select yn in "Yes" "No"; do
        case $yn in
	Yes)
	  echo -e "$green Continuing. $nocol"
          echo -e ""
          continue_for
	  ;;
	No)
	  echo -e "$red Exiting $nocol"
          exit 1
	  ;;
        esac
      done
    fi
}

function continue_for() {
    case $my_ch in
      1)
      echo -e "$cyan Checking for directory... $nocol"
      echo -e ""
      if [[ -d 10x ]]; then
          echo -e "$cyan 10X directory exists, starting the build... $nocol"
          cd 10x
          build_tenx_for_XT
          upload_to_gdrive
      else
          echo -e "$cyan Directory not found. $nocol"
          echo -e ""
      fi
      echo -e "$cyan Creating & entering the Directory! $nocol"
      mkdir 10x
      cd 10x
      echo -e "$green Succussfully completed the first Task, Goodluck ahead. $nocol"
      sleep 10
      echo -e "$cyan Initializing TenX-OS Repos. $nocol"
      repo init -u git://github.com/TenX-OS/manifest_TenX -b eleven
      echo -e "$cyan Syncing TenX-OS Repos. $nocol"
      repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
      echo -e "$greeen Succussfully completed the second Task, Goodluck ahead. $nocol"
      sleep 20
      echo -e "$cyan Cloning Device Trees for Realme XT. $nocol"
      clone_xt
      sleep 10
      build_tenx_for_XT
      upload_to_gdrive
      ;;
      2)
      echo -e "$blue Starting the Scripts. $nocol"
      ;;
    esac
}

# Build for XT
function build_tenx_for_XT() {
   . b*/e*
   lunch aosp_RMX1921-userdebug
   export CUSTOM_BUILD_TYPE=Official
   source ~/.bashrc
   export USE_CCACHE=1
   ccache -M 30G
   brunch RMX1921

   local ret=$?
   if [[ $ret -eq 0 ]]; then
       upload
   else
       echo -e "$red I've found some errors, stopping the Script, Fix them & Re-run me !! $nocol"
       exit
     fi
}

# Upload to gdrive
function upload_to_gdrive() {
   cd out/target/product/RMX1921
   echo -e "$green Uploading to Gdrive $nocol"
   gdrive upload TenX*.zip
}

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
   echo -e "$yellow 4. Clone my Device Trees & Build. $nocol"
   echo -e "$green Enter your choice: $nocol"
   read to_do
   echo -e "$red Your choice was $to_do $nocol"

   case $to_do in
     1)
     create_dir
     sync_tenx
     echo -e "$blue Good night, for a power nap $nocol"
     sleep 10
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
     if [ $codename == RMX1921 ]; then
        build_tenx
     else
        clone_dt
        clone_kt
        clone_vt
        echo -e "$blue Good night, for a power nap $nocol"
        sleep 10
        build_tenx
     fi
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
     echo -e "$blue Good night, for a power nap $nocol"
     sleep 10
     build_tenx
     upload
     ;;
     3)
     cd $dir
     upload
     ;;
     4)
     clone_dt
     clone_kt
     clone_vt
     echo -e "$blue Good night, for a power nap $nocol"
     sleep 10
     build_tenx
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
    echo -e ""
    echo -e "$green Device tree link was [git clone $dt_link -b $dt_branch device/$device/$codename] $nocol"
    echo -e "$yellow was that correct? $nocol"
    select yn in "Yes" "No"; do
    case $yn in
       Yes)
          echo -e "$green Cloning your Device Tree. $nocol"
          git clone --quiet $dt_link -b $dt_branch device/$device/$codename > /dev/null
          modify_tree
          break
          ;;
        No)
          echo -e "$red Okk Fine $nocol"
          clone_dt
          modify_tree
          break
          ;;
      esac
    done
}

# Auto tree modification
function modify_tree() {
    echo -e "$blue Do you want to modify your device trees as per TenX base ?$nocol"
    echo -e "$green 1. Yes $nocol"
    echo -e "$red 2. No $nocol"
    echo -e "$yellow Enter your choice $nocol"
    read modify
    echo -e "$blue Your choice was $modify $nocol"

    case $modify in
      1)
      modify_in
      ;;
      2)
      echo -e "$yellow Continuing cloning trees... $nocol"
      clone_kt
      ;;
    esac
}

function modify_in() {
    cd device/$device/$codename
    mv *_$codename.mk aosp_$codename.mk
    mv *.dependencies aosp.dependencies

    echo -e "$cyan What to replace with aosp? $nocol"
    read what_to

    sed -i "s|$what_to|aosp|g" aosp_$codename.mk
    sed -i "s|$what_to|aosp|g" AndroidProducts.mk

    echo -e "$green Checking for Gapps flags $nocol"
    if grep -Fxq "TARGET_GAPPS_ARCH := arm64" aosp_$codename.mk
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
      clone_kt
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
    echo -e ""
    echo -e "$green Kernel Tree link was [git clone $kt_link -b $kt_branch kernel/$device/$target] $nocol"
    echo -e "$yellow was that correct? $nocol"
    select yn1 in "Yes" "No"; do
    case $yn1 in
       Yes)
          echo -e "$green Cloning your Kernel Tree. $nocol"
          git clone --quiet $kt_link -b $kt_branch kernel/$device/$target > /dev/null
          clone_vt
          break
          ;;
        No)
          echo -e "$red Okay Fine $nocol"
          clone_kt
          clone_vt
          break
          ;;
      esac
    done
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
      echo -e "Entered Vendor Tree link was [git clone $vt_link -b $vt_branch vendor/$device] $nocol"
      echo -e "$yellow was that correct? $nocol"
      select yn2 in "Yes" "No"; do
      case $yn2 in
         Yes)
             echo -e "$green Cloning your Vendor Tree... $nocol"
             git clone --quiet $vt_link -b $vt_branch vendor/$device > /dev/null
             build_tenx
             break
             ;;
          No)
             echo -e "$red Okay Fine $nocol"
             clone_vt
             build_tenx
             break
             ;;
         esac
       done
      ;;
      2)
      echo -e "Entered Vendor Tree link was [git clone $vt_link -b $vt_branch vendor/$device/$codename] $nocol"
      echo -e "$yellow was that correct? $nocol"
      select yn3 in "Yes" "No"; do
      case $yn3 in
         Yes)
             echo -e "$green Cloning your Vendor Tree... $nocol"
             git clone --quiet $vt_link -b $vt_branch vendor/$device/$codename > /dev/null
             build_tenx
             break
             ;;
          No)
             echo -e "$red Okay Fine $nocol"
             clone_vt
             build_tenx
             break
             ;;
         esac
       done
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
   echo -e "$green Enter your choice: $nocol"
   read  make_build
   echo -e "$blue Your choice was $ch $nocol"

   case $make_build in
     1)
     . b*/e*
     make installclean
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
    echo -e "$green Enter your choice: $nocol"
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
     brunch $codename

     local ret=$?
     if [[ $ret -eq 0 ]]; then
         upload
     else
        echo -e "$red I've found some errors, stopping the Script, Fix them & Re-run me !! $nocol"
        exit
     fi
}

# Upload
function upload() {
    # Check for TenX-OS zip file
    echo -e "$blue Do you want to upload your build? $nocol"
    echo -e "$red 1. Yes $nocol"
    echo -e "$green 2. No $nocol"
    echo -e "$cyan Enter your choice: $nocol"
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
    echo -e "$cyan Enter your choice: $nocol"
    read upload_to
    echo -e "$blue Your choice was $upload $nocol"

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
    esac
}

your_choice
dir_name
device_name
device_codename
what_to_do
