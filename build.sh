#!/bin/bash

CMD="$1"
EXTRACMD="$2"
A_TOP=${PWD}
CUR_DIR=`dirname $0`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
CM_VERSION=10.1

# Common defines (Arch-dependent)
case `uname -s` in
    Darwin)
        txtrst='\033[0m'  # Color off
        txtred='\033[0;31m' # Red
        txtgrn='\033[0;32m' # Green
        txtylw='\033[0;33m' # Yellow
        txtblu='\033[0;34m' # Blue
        THREADS=`sysctl -an hw.logicalcpu`
        ;;
    *)
        txtrst='\e[0m'  # Color off
        txtred='\e[0;31m' # Red
        txtgrn='\e[0;32m' # Green
        txtylw='\e[0;33m' # Yellow
        txtblu='\e[0;34m' # Blue
        THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
        ;;
esac

check_root() {
    if [ ! $( id -u ) -eq 0 ]; then
        echo -e "${txtred}Please run this script as root."
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

check_machine_type() {
    echo "Checking machine architecture..."
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
        echo -e "${txtgrn}Detected: ${MACHINE_TYPE}. Good!"
        echo -e "\r\n ${txtrst}"
    else
        echo -e "${txtred}Detected: ${MACHINE_TYPE}. Bad!"
        echo -e "${txtred}Sorry, we do only support building on 64-bit machines."
        echo -e "${txtred}32-bit is soooo 1970, consider a upgrade. ;-)"
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

install_sun_jdk()
{
    add-apt-repository "deb http://archive.canonical.com/ lucid partner"
    apt-get update
    apt-get install sun-java6-jdk
}

install_arch_packages()
{
    # x86_64
    pacman -S jdk7-openjdk jre7-openjdk jre7-openjdk-headless perl git gnupg flex bison gperf zip unzip sdl wxgtk \
    squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
    optipng python2 perl-switch lib32-zlib lib32-ncurses lib32-readline \
    gcc-libs-multilib gcc-multilib lib32-gcc-libs binutils-multilib libtool-multilib
}

install_ubuntu_packages()
{
    # x86_64       
    apt-get install git-core gnupg flex bison gperf build-essential \
    zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
    libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
    libgl1-mesa-dev g++-multilib mingw32 openjdk-6-jdk tofrodos \
    python-markdown libxml2-utils xsltproc zlib1g-dev:i386 pngcrush
}

prepare_environment()
{
    echo "Which 64-bit distribution are you running?"
    echo "1) Ubuntu 11.04"
    echo "2) Ubuntu 11.10"
    echo "3) Ubuntu 12.04"
    echo "4) Ubuntu 12.10"
    echo "5) Arch Linux"
    echo "6) Debian"
    read -n1 distribution
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 11.04
        echo "Installing packages for Ubuntu 11.04"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "2")
        # Ubuntu 11.10
        echo "Installing packages for Ubuntu 11.10"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "3")
        # Ubuntu 12.04
        echo "Installing packages for Ubuntu 12.04"
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "4")
        # Ubuntu 12.10
        echo "Installing packages for Ubuntu 12.10"
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "5")
        # Arch Linux
        echo "Installing packages for Arch Linux"
        install_arch_packages
        mv /usr/bin/python /usr/bin/python.bak
        ln -s /usr/bin/python2 /usr/bin/python
        ;;
    "6")
        # Debian
        echo "Installing packages for Debian"
        apt-get update
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl libc6-dev lib32ncurses5 libncurses5-dev x11proto-core-dev \
        libx11-dev libreadline6-dev lib32readline-gplv2-dev libgl1-mesa-glx \
        libgl1-mesa-dev g++-multilib mingw32 openjdk-6-jdk tofrodos \
        python-markdown libxml2-utils xsltproc zlib1g-dev pngcrush \
        libcurl4-gnutls-dev comerr-dev krb5-multidev libcurl4-gnutls-dev \
        libgcrypt11-dev libglib2.0-dev libgnutls-dev libgnutls-openssl27 \
        libgnutlsxx27 libgpg-error-dev libgssrpc4 libgstreamer-plugins-base0.10-dev \
        libgstreamer0.10-dev libidn11-dev libkadm5clnt-mit8 libkadm5srv-mit8 \
        libkdb5-6 libkrb5-dev libldap2-dev libp11-kit-dev librtmp-dev libtasn1-3-dev \
        libxml2-dev tofrodos python-markdown lib32z-dev ia32-libs
        ln -s /usr/lib32/libX11.so.6 /usr/lib32/libX11.so
        ln -s /usr/lib32/libGL.so.1 /usr/lib32/libGL.so
        ;;
        
    *)
        # No distribution
        echo -e "${txtred}No distribution set. Aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac
    
    echo "Do you want us to get android sources for you? (y/n)"
    read -n1 sources
    echo -e "\r\n"

    case $sources in
    "Y" | "y")
        echo "Choose a branch:"
        echo "1) cm-7 (gingerbread)"
        echo "2) cm-9 (ics)"
        echo "3) cm-10 (jellybean mr0)"
        echo "4) cm-10.1 (jellybean mr1)"
        read -n1 branch
        echo -e "\r\n"

        case $branch in
            "1")
                # cm-7
                branch="gingerbread"
                ;;
            "2")
                # cm-9
                branch="ics"
                ;;
            "3")
                # cm-10
                branch="jellybean"
                ;;
            "4")
                # cm-10.1
                branch="cm-10.1"
                ;;
            *)
                # no branch
                echo -e "${txtred}No branch choosen. Aborting."
                echo -e "\r\n ${txtrst}"
                exit
                ;;
        esac

        echo "Target Directory (~/android/system):"
        read working_directory

        if [ ! -n $working_directory ]; then 
            working_directory="~/android/system"
        fi

        echo "Installing to $working_directory"
        mkdir ~/bin
        export PATH=~/bin:$PATH
        curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
        chmod a+x ~/bin/repo
        source ~/.profile
        repo selfupdate
        
        mkdir -p $working_directory
        cd $working_directory
        repo init -u git://github.com/CyanogenMod/android.git -b $branch
        mkdir -p $working_directory/.repo/local_manifests
        touch $working_directory/.repo/local_manifests/my_manifest.xml
        curl https://raw.github.com/teamhacksung/buildscripts/$branch/my_manifest.xml > $working_directory/.repo/local_manifests/my_manifest.xml
        repo sync -j15
        echo "Sources synced to $working_directory"        
        exit
        ;;
    "N" | "n")
        # nothing to do
        exit
        ;;
    esac
}

# create kernel zip after successfull build
create_kernel_zip()
{
    echo -e "${txtgrn}Creating kernel zip...${txtrst}"
    if [ -e ${ANDROID_PRODUCT_OUT}/boot.img ]; then
        echo -e "${txtgrn}Bootimage found...${txtrst}"
        if [ -e ${A_TOP}/buildscripts/targets/${CMD}/kernel_updater-script ]; then

            echo -e "${txtylw}Package KERNELUPDATE:${txtrst} out/target/product/${CMD}/kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip"
            cd ${ANDROID_PRODUCT_OUT}

            rm -rf kernel_zip
            rm kernel-cm-${CM_VERSION}-*

            mkdir -p kernel_zip/system/lib/modules
            mkdir -p kernel_zip/META-INF/com/google/android

            echo "Copying boot.img..."
            cp boot.img kernel_zip/
            echo "Copying kernel modules..."
            cp -R system/lib/modules/* kernel_zip/system/lib/modules
            echo "Copying update-binary..."
            cp obj/EXECUTABLES/updater_intermediates/updater kernel_zip/META-INF/com/google/android/update-binary
            echo "Copying updater-script..."
            cat ${A_TOP}/buildscripts/targets/${CMD}/kernel_updater-script > kernel_zip/META-INF/com/google/android/updater-script
                
            echo "Zipping package..."
            cd kernel_zip
            zip -qr ../kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}.zip ./
            cd ${ANDROID_PRODUCT_OUT}

            echo "Signing package..."
            java -jar ${ANDROID_HOST_OUT}/framework/signapk.jar ${A_TOP}/build/target/product/security/testkey.x509.pem ${A_TOP}/build/target/product/security/testkey.pk8 kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}.zip kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip
            rm kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}.zip
            echo -e "${txtgrn}Package complete:${txtrst} out/target/product/${CMD}/kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip"
            md5sum kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip
            cd ${A_TOP}
        else
            echo -e "${txtred}No instructions to create out/target/product/${CMD}/kernel-cm-${CM_VERSION}-$(date +%Y%m%d)-${CMD}-signed.zip... skipping."
            echo -e "\r\n ${txtrst}"
        fi
    else
        echo -e "${txtred}Bootimage not found... skipping."
        echo -e "\r\n ${txtrst}"
    fi
}

echo -e "${txtblu} ###################################################################################################"
echo -e "${txtblu} \r\n"
echo -e "${txtblu}        _______ ______          __  __ _    _          _____ _  __ _____ _    _ _   _  _____ "
echo -e "${txtblu}       |__   __|  ____|   /\   |  \/  | |  | |   /\   / ____| |/ // ____| |  | | \ | |/ ____|"
echo -e "${txtblu}          | |  | |__     /  \  | \  / | |__| |  /  \ | |    | ' /| (___ | |  | |  \| | |  __ "
echo -e "${txtblu}          | |  |  __|   / /\ \ | |\/| |  __  | / /\ \| |    |  <  \___ \| |  | | . ' | | |_ |"
echo -e "${txtblu}          | |  | |____ / ____ \| |  | | |  | |/ ____ \ |____| . \ ____) | |__| | |\  | |__| |"
echo -e "${txtblu}          |_|  |______/_/    \_\_|  |_|_|  |_/_/    \_\_____|_|\_\_____/ \____/|_| \_|\_____|"
echo -e "${txtblu} \r\n"
echo -e "${txtblu}                                   CyanogenMod ${CM_VERSION} buildscript"
echo -e "${txtblu}                             visit us @ http://www.teamhacksung.org"
echo -e "${txtblu} \r\n"
echo -e "${txtblu} ###################################################################################################"
echo -e "\r\n ${txtrst}"

# Check for build target
if [ -z "${CMD}" ]; then
	echo -e "${txtred}No build target set."
	echo -e "${txtred}Usage: ./build.sh i9300 (complete build)"
	echo -e "${txtred}       ./build.sh i9300 kernel (bootimage only)"
	echo -e "${txtred}       ./build.sh clean"
    echo -e "${txtred}       ./build.sh prepare (prepares the build environment)"
    echo -e "\r\n ${txtrst}"
    exit
fi

# Starting Timer
START=$(date +%s)

# Device specific settings
case "$CMD" in
    prepare)
        check_root
        check_machine_type
        prepare_environment
        exit
        ;;
    clean)
        make clean
        rm -rf ./out/target/product
        exit
        ;;
    *)
        lunch=cm_${CMD}-userdebug
        brunch=${lunch}
        ;;
esac

# Get prebuilts once per day
if [ "$EXTRACMD" != "kernel" ]; then
    prebuilts=$(cat prebuilts.log)
    if [ "$DATE" != "$prebuilts" ]; then
        echo -e "${txtylw}Downloading prebuilts...${txtrst}"
        pushd vendor/cm
        ./get-prebuilts
        popd
        echo $DATE > prebuilts.log
    fi
fi

# Apply patches
if [ -f $CUR_DIR/patch.sh ]; then
    echo -e "${txtylw}Applying patches...${txtrst}"
    source $CUR_DIR/patch.sh
fi

# Setting up Build Environment
echo -e "${txtgrn}Setting up Build Environment...${txtrst}"
. build/envsetup.sh
lunch ${lunch}

# Allow setting of additional flags
if [ -f $CUR_DIR/env.sh ]; then
    source $CUR_DIR/env.sh
fi

# fix module copy for archlinux
mkdir -p ${ANDROID_PRODUCT_OUT}/system/lib
mkdir -p ${ANDROID_PRODUCT_OUT}/system/usr
cd ${ANDROID_PRODUCT_OUT}/system/usr
ln -sf ../lib .
cd -

# Start the Build
case "$EXTRACMD" in
    kernel)
        echo -e "${txtgrn}Rebuilding bootimage...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
        rm -rf ${ANDROID_PRODUCT_OUT}/kernel_zip
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/boot.img
        rm -rf ${ANDROID_PRODUCT_OUT}/root
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*
        rm -rf ${ANDROID_PRODUCT_OUT}/combined*

        mka bootimage
        mka updater
        if [ ! -e ${ANDROID_HOST_OUT}/framework/signapk.jar ]; then
            mka signapk
        fi
        create_kernel_zip
        ;;
    recovery)
        echo -e "${txtgrn}Rebuilding recoveryimage...${txtrst}"

        rm -rf ${ANDROID_PRODUCT_OUT}/obj/KERNEL_OBJ
        rm ${ANDROID_PRODUCT_OUT}/kernel
        rm ${ANDROID_PRODUCT_OUT}/recovery.img
        rm ${ANDROID_PRODUCT_OUT}/recovery
        rm -rf ${ANDROID_PRODUCT_OUT}/ramdisk*

        mka ${ANDROID_PRODUCT_OUT}/recovery.img
        ;;
    *)
        echo -e "${txtgrn}Building Android...${txtrst}"
        brunch ${brunch}
        create_kernel_zip
        ;;
esac

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "${txtgrn}Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n ${txtrst}" $E_SEC
