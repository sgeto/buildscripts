#!/bin/bash

COMMAND="$1"
ADDITIONAL="$2"
TOP=${PWD}
CURRENT_DIR=`dirname $0`

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

install_sun_jdk()
{
    add-apt-repository "deb http://archive.canonical.com/ lucid partner"
    apt-get update
    apt-get install sun-java6-jdk
}

install_arch_packages()
{
    case $arch in
    "1")
        # i686
        pacman -S openjdk6 perl git gnupg flex bison gperf zip unzip sdl wxgtk \
        squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
        optipng
        ;;
    "2")
        # x86_64
        pacman -S openjdk6 perl git gnupg flex bison gperf zip unzip sdl wxgtk \
        squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
        optipng
        ;;
    *)
        # no arch
        echo -e "${txtred}No arch defined, aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac
}

install_ubuntu_packages()
{
    case $arch in
    "1")
        # i686
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev libncurses5-dev x11proto-core-dev \
        libx11-dev libreadline6-dev libgl1-mesa-dev tofrodos python-markdown \
        libxml2-utils xsltproc pngcrush
        ;;
    "2")
        # x86_64
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc pngcrush
        ;;
    *)
        # no arch
        echo -e "${txtred}No arch defined, aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac
}

prepare_environment()
{
    echo "Which distribution are you running?"
    echo "1) Ubuntu 10.04"
    echo "2) Ubuntu 10.10"
    echo "3) Ubuntu 11.04"
    echo "4) Ubuntu 11.10"
    echo "5) Ubuntu 12.04"
    echo "6) Arch Linux"
    echo "7) Debian"
    read -n1 distribution
    echo -e "\r\n"
    
    echo "Arch?"
    echo "1) i686"
    echo "2) x86_64"
    read -n1 arch
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 10.04
        echo "Installing packages for Ubuntu 10.04"
        install_sun_jdk
        install_ubuntu_packages
        ;;
    "2")
        # Ubuntu 10.10
        echo "Installing packages for Ubuntu 10.10"
        install_sun_jdk
        install_ubuntu_packages
        ln -s /usr/lib32/mesa/libGL.so.1 /usr/lib32/mesa/libGL.so
        ;;
    "3")
        # Ubuntu 11.04
        echo "Installing packages for Ubuntu 11.04"
        install_sun_jdk
        install_ubuntu_packages
        ;;
    "4")
        # Ubuntu 11.10
        echo "Installing packages for Ubuntu 11.10"
        install_sun_jdk
        install_ubuntu_packages
        apt-get install libx11-dev:i386
        ;;
    "5")
        # Ubuntu 12.04
        echo "Installing packages for Ubuntu 12.04"
        apt-get update
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
        libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev:i386 \
        g++-multilib mingw32 openjdk-6-jdk tofrodos python-markdown \
        libxml2-utils xsltproc zlib1g-dev:i386 pngcrush
        ;;
    
    "6")
        # Arch Linux
        echo "Installing packages for Arch Linux"
        install_arch_packages
        mv /usr/bin/python /usr/bin/python.bak
        ln -s /usr/bin/python2 /usr/bin/python
        ;;
    "7")
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
        echo "1) gingerbread"
        echo "2) ics"
        echo "3) jellybean"
        read -n1 branch
        echo -e "\r\n"

        case $branch in
            "1")
                # gingerbread
                branch="gingerbread"
                ;;
            "2")
                # ics
                branch="ics"
                ;;
            "3")
                # jellybean
                branch="jellybean"
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
        
        mkdir -p $working_directory
        cd $working_directory
        repo init -u git://github.com/CyanogenMod/android.git -b $branch
        repo sync
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
    if [ -e out/target/product/${COMMAND}/boot.img ]; then
        if [ -e ${TOP}/buildscripts/samsung/${COMMAND}/kernel_updater-script ]; then

            echo -e "${txtylw}Package KERNELUPDATE:${txtrst} out/target/product/${COMMAND}/kernel-cm-9-$(date +%Y%m%d)-${COMMAND}-signed.zip"
            cd out/target/product/${COMMAND}

            rm -rf kernel_zip
            rm kernel-cm-10-*

            mkdir -p kernel_zip/system/lib/modules
            mkdir -p kernel_zip/META-INF/com/google/android

            echo "Copying boot.img..."
            cp boot.img kernel_zip/
            echo "Copying kernel modules..."
            cp -R system/lib/modules/* kernel_zip/system/lib/modules
            echo "Copying update-binary..."
            cp obj/EXECUTABLES/updater_intermediates/updater kernel_zip/META-INF/com/google/android/update-binary
            echo "Copying updater-script..."
            cat ${TOP}/buildscripts/samsung/${COMMAND}/kernel_updater-script > kernel_zip/META-INF/com/google/android/updater-script
                
            echo "Zipping package..."
            cd kernel_zip
            zip -qr ../kernel-cm-10-$(date +%Y%m%d)-${COMMAND}.zip ./
            cd ${TOP}/out/target/product/${COMMAND}

            echo "Signing package..."
            java -jar ${TOP}/out/host/linux-x86/framework/signapk.jar ${TOP}/build/target/product/security/testkey.x509.pem ${TOP}/build/target/product/security/testkey.pk8 kernel-cm-10-$(date +%Y%m%d)-${COMMAND}.zip kernel-cm-10-$(date +%Y%m%d)-${COMMAND}-signed.zip
            rm kernel-cm-10-$(date +%Y%m%d)-${COMMAND}.zip
            echo -e "${txtgrn}Package complete:${txtrst} out/target/product/${COMMAND}/kernel-cm-10-$(date +%Y%m%d)-${COMMAND}-signed.zip"
            md5sum kernel-cm-10-$(date +%Y%m%d)-${COMMAND}-signed.zip
            cd ${TOP}
        else
            echo -e "${txtred}No instructions to create out/target/product/${COMMAND}/kernel-cm-10-$(date +%Y%m%d)-${COMMAND}-signed.zip... skipping."
            echo -e "\r\n ${txtrst}"
        fi
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
echo -e "${txtblu}                                   CyanogenMod 10 buildscript"
echo -e "${txtblu}                             visit us @ http://www.teamhacksung.org"
echo -e "${txtblu} \r\n"
echo -e "${txtblu} ###################################################################################################"
echo -e "\r\n ${txtrst}"

# Starting Timer
START=$(date +%s)

# Device specific settings
case "$COMMAND" in
    prepare)
        check_root
        prepare_environment
        exit
        ;;
	clean)
		make clean
		rm -rf ./out/target/product
		exit
		;;
	*)
		lunch=cm_${COMMAND}-userdebug
        brunch=${lunch}
	    ;;
esac

if [ "$ADDITIONAL" != "kernel" ]; then
    # Get prebuilts
    echo -e "${txtylw}Downloading prebuilts...${txtrst}"
    pushd vendor/cm
    ./get-prebuilts
    popd
fi

# Apply patches
if [ -f $CURRENT_DIR/patch.sh ]; then
    echo -e "${txtylw}Applying patches...${txtrst}"
    source $CURRENT_DIR/patch.sh
fi

# Setting up Build Environment
echo -e "${txtgrn}Setting up Build Environment...${txtrst}"
. build/envsetup.sh
lunch ${lunch}

# Allow setting of additional flags
if [ -f $CURRENT_DIR/env.sh ]; then
    source $CURRENT_DIR/env.sh
fi

# Start the Build
case "$ADDITIONAL" in
	kernel)
		echo -e "${txtgrn}Rebuilding bootimage...${txtrst}"

        rm -rf out/target/product/${COMMAND}/obj/KERNEL_OBJ
        rm -rf out/target/product/${COMMAND}/kernel_zip
        rm out/target/product/${COMMAND}/kernel
        rm out/target/product/${COMMAND}/boot.img
        rm out/target/product/${COMMAND}/root
        rm -rf out/target/product/${COMMAND}/ramdisk*

        make -j${THREADS} out/target/product/${COMMAND}/boot.img
        make -j${THREADS} updater
        if [ ! -e out/host/linux-x86/framework/signapk.jar ]; then
            make -j${THREADS} signapk
        fi
        create_kernel_zip
		;;
	recovery)
		echo -e "${txtgrn}Rebuilding recoveryimage...${txtrst}"

        rm -rf out/target/product/${COMMAND}/obj/KERNEL_OBJ
        rm out/target/product/${COMMAND}/kernel
        rm out/target/product/${COMMAND}/recovery.img
        rm out/target/product/${COMMAND}/recovery
        rm -rf out/target/product/${COMMAND}/ramdisk*

        make -j${THREADS} out/target/product/${COMMAND}/recovery.img
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
