#!/bin/bash
#Something you need to prepare before you run this script
#Need to create the KEY_FOLDER(GW7557LG_RSA_Keys) and copy the private and public key to that

function setoption() {
####################Personal Settings####################
SSH_ACCOUNT="ed_lee"

####################parameters for source building code####################
#OPTIONS for build arm code
if [ "$1" == "GA" ]; then
ARM_PATCH_BUILD_VER="0"
ARM_BUILD_BUILD_VER="99" #This just only support number
ARM_VENDOR_BUILD_VER=""
ARM_IS_THE_FIRMWARE_GA_RELEASE="y"
else
ARM_PATCH_BUILD_VER="0"
ARM_BUILD_BUILD_VER="4"
ARM_VENDOR_BUILD_VER="-ENG2test"
ARM_IS_THE_FIRMWARE_GA_RELEASE="n"
fi
ARM_SELECT_BUILD_PROFILE="gw7557c_lgi" #with lower case
if [ -n "${ARM_VENDOR_BUILD_VER}" ]; then
VERSION="6.15.${ARM_PATCH_BUILD_VER}.${ARM_BUILD_BUILD_VER}${ARM_VENDOR_BUILD_VER}"
else
VERSION="6.15.${ARM_PATCH_BUILD_VER}.${ARM_BUILD_BUILD_VER}"
fi
echo -e "\n"
echo ${VERSION} #debug used

ARM_ENABLE_SHELL_COMMAND_ON_CONSOLE="y"
ARM_IS_THE_FIRMWARE_FOR_DEVELOPMENT="n"
ARM_IS_THIS_CORRECT="y"

#Options for build atom code
ATOM_BUILD_BUILD_VER=${ARM_PATCH_BUILD_VER} #"0"
if [ -n "${ARM_VENDOR_BUILD_VER}" ]; then
ATOM_VENDOR_BUILD_VER=".${ARM_BUILD_BUILD_VER}${ARM_VENDOR_BUILD_VER}" #"2-2"
else
ATOM_VENDOR_BUILD_VER=".${ARM_BUILD_BUILD_VER}" #"2-2"
fi
echo ${ATOM_VENDOR_BUILD_VER} #debug used
ATOM_SELECT_BUILD_PROFILE="GW7557LG" #Upper case is ok
ATOM_IS_THIS_CORRECT="y"

####################parameters for source code control####################
HOME_FOLDER="/home/${SSH_ACCOUNT}"
BUILD_FOLDER=`pwd`
VERSION_PROJECT="GW7557LG-${VERSION}"
RELEASE_INFO="Release tag ${VERSION}"
ARM_REPOSITORY_NAME="PUMA6_61_RGW_ARM"
ATOM_REPOSITORY_NAME="PUMA6_61_ATOM"
NORMAL_BRANCH_NAME="develop"
ARM_BRANCH_NAME="GW7557LG-6.15.1.1a"
ATOM_BRANCH_NAME="GW7557LG-CL2400_4.7.23.12"


####################parameters for image####################

echo "${VERSION}"
echo "${VERSION_PROJECT}"
echo "${RELEASE_INFO}"
}

#######################################
#######Start Set Environment....################
#######################################
echo "1. for GA Env"
echo "2. for ENG Env"
read option
case "$option" in
	"1")
        setoption GA
		echo -e "\n"
    ;;
	"2")
        setoption ENG
		echo -e "\n"
    ;;
	"*")
        echo "Not supported"
    ;;
	
esac

function Checkout_Source_For_ARM() {
    git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ARM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    sync
    cd ${ARM_REPOSITORY_NAME}
    git checkout ${ARM_BRANCH_NAME}
}
function Checkout_Source_And_Add_The_Tag_For_ARM() {
    #Do the tag for ARM
    echo "Add tag ${VERSION_PROJECT} for ARM"
    #git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ARM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    #sync
    #cd ${ARM_REPOSITORY_NAME}
    #git checkout ${ARM_BRANCH_NAME}
    Checkout_Source_For_ARM
    LATEST_ARM_COMMIT_NUMBER=`git log | head -1 | awk '{print $2}'`
    git tag -a ${VERSION_PROJECT} ${LATEST_ARM_COMMIT_NUMBER} -m "${RELEASE_INFO}"
    git push origin ${VERSION_PROJECT}
    cd ../
}

function Checkout_Source_For_ATOM() {
    git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ATOM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    sync
    cd ${ATOM_REPOSITORY_NAME}
    git checkout ${ATOM_BRANCH_NAME}
}
function Checkout_Source_And_Add_The_Tag_For_ATOM() {
    #Do the tag for ATOM
    echo "Add tag ${VERSION_PROJECT} for ATOM"
    #git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ATOM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    #sync
    #cd ${ATOM_REPOSITORY_NAME}
    #git checkout ${ATOM_BRANCH_NAME}
    Checkout_Source_For_ATOM
    LATEST_ATOM_COMMIT_NUMBER=`git log | head -1 | awk '{print $2}'`
    git tag -a ${VERSION_PROJECT} ${LATEST_ATOM_COMMIT_NUMBER} -m "${RELEASE_INFO}"
    git push origin ${VERSION_PROJECT}
    cd ..
}

function Do_Before_Start_Build(){
    #Start to build release firmware
    rm -rf PUMA6_61_ATOM PUMA6_61_RGW_ARM
    mkdir SH NOSH

    Do_Checkout_Source_And_Tag

    #Copy the source code to build folder

    cp -ar ${ARM_REPOSITORY_NAME} ${ATOM_REPOSITORY_NAME} SH
    cp -ar ${ARM_REPOSITORY_NAME} ${ATOM_REPOSITORY_NAME} NOSH
}

function Do_Checkout_Source_And_Tag() {
    #Download the suorce code and switch to tag 
    git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ARM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    cd ${ARM_REPOSITORY_NAME}
    git checkout ${VERSION_PROJECT}
    cd ..

    git clone ssh://${SSH_ACCOUNT}@xb6:29418/${ATOM_REPOSITORY_NAME} -b ${NORMAL_BRANCH_NAME}
    cd ${ATOM_REPOSITORY_NAME}
    git checkout ${VERSION_PROJECT}
    cd ..
}



function Build_ARM_Code(){

    cd ${ARM_REPOSITORY_NAME}
    #Version 1, 2, 3, 4
    
    ARM_ENABLE_SHELL_COMMAND_ON_CONSOLE="$1"
    if [ -n "${ARM_VENDOR_BUILD_VER}" ]; then
        echo -e "${ARM_ENABLE_SHELL_COMMAND_ON_CONSOLE}\n${ARM_IS_THE_FIRMWARE_GA_RELEASE}\n${ARM_IS_THE_FIRMWARE_FOR_DEVELOPMENT}\n${ARM_IS_THIS_CORRECT}\n" | ./image_build.sh ${ARM_PATCH_BUILD_VER} ${ARM_BUILD_BUILD_VER} ${ARM_VENDOR_BUILD_VER} ${ARM_SELECT_BUILD_PROFILE}
    else
#exit 1 #debug used
        #echo -e "${ARM_ENABLE_SHELL_COMMAND_ON_CONSOLE}\n${ARM_IS_THE_FIRMWARE_GA_RELEASE}\n${ARM_IS_THE_FIRMWARE_FOR_DEVELOPMENT}\n${ARM_IS_THIS_CORRECT}\n" | ./image_build.sh ${ARM_PATCH_BUILD_VER} ${ARM_BUILD_BUILD_VER} "" ${ARM_SELECT_BUILD_PROFILE}
        echo -e "\n${ARM_ENABLE_SHELL_COMMAND_ON_CONSOLE}\n${ARM_IS_THE_FIRMWARE_GA_RELEASE}\n${ARM_IS_THIS_CORRECT}\n" | ./image_build.sh ${ARM_PATCH_BUILD_VER} ${ARM_BUILD_BUILD_VER} "" ${ARM_SELECT_BUILD_PROFILE}
		#\n==>zz->enter SHELL command on console       Enter  firmware GA release          Enter  Is this correct?  Enter
    fi
    cd ..
}
function Build_ARM_Code_SH(){
    cd SH
    Build_ARM_Code "y"
    cd ..
}
function Build_ARM_Code_NOSH(){
    cd NOSH
    Build_ARM_Code "n"
    cd ..
}

function Build_ATOM_Code(){

    cd ${ATOM_REPOSITORY_NAME}
    #Version 1, 2, 3, 4
    

    #ENABLE_SAS=""
    if [ "$1" == "y" ]
    then
        SHELL_COMMAND_ON_CONSOLE="--enable-shell"
    else
        SHELL_COMMAND_ON_CONSOLE="--disable-shell"
    fi
    echo -e "${ATOM_IS_THIS_CORRECT}\n" | ./image_build.sh --profile ${ATOM_SELECT_BUILD_PROFILE} --disable-sas ${SHELL_COMMAND_ON_CONSOLE} --build-version ${ATOM_BUILD_BUILD_VER} --vendor-version ${ATOM_VENDOR_BUILD_VER}
    cd ..
}

function Build_ATOM_Code_SH(){
    cd SH
    Build_ATOM_Code "y"
    cd ..
}
function Build_ATOM_Code_NOSH(){
    cd NOSH
    Build_ATOM_Code "n"
    cd ..
}

####################parameters for image####################
ARM_OUTPUT_IMAGE_PATH="build/products/configs/images"
ARM_IMAGE_PATH="${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}"
ATOM_IMAGE_PATH="products/configs/images/GW7557LG-4.50.18.${ATOM_BUILD_BUILD_VER}${ATOM_VENDOR_BUILD_VER}"
ARM_ORI_SH_IMAGE_FILENAME="${VERSION_PROJECT}-SH"
ATOM_ORI_SH_IMAGE_FILENAME="GW7557LG-4.50.18.${ATOM_BUILD_BUILD_VER}${ATOM_VENDOR_BUILD_VER}-NOSAS-SH_appcpuImage"
ARM_SH_IMAGE_FILENAME="${VERSION_PROJECT}-SH"
ATOM_SH_IMAGE_FILENAME="${ARM_SH_IMAGE_FILENAME}_appcpuImage"
ALL_IMAGE_FILENAME=""
BUILD_DATE=`date +"%Y%m%d"`
ARM_TEMP_IMAGE_FILENAME="${ARM_SELECT_BUILD_PROFILE}_${VERSION}-${BUILD_DATE}_npcpu-appcpu.img" #gw7557c_lgi_6.12.0.2-2-20200527_npcpu-appcpu.img
ATOM_TEMP_IMAGE_FILENAME="${ARM_SELECT_BUILD_PROFILE}_${VERSION}-${BUILD_DATE}_npcpu.img" #gw7557c_lgi_6.12.0.2-2-20200527_npcpu.img

ARM_ORI_NOSH_IMAGE_FILENAME="${VERSION_PROJECT}-NOSH"
ATOM_ORI_NOSH_IMAGE_FILENAME="GW7557LG-4.50.18.${ATOM_BUILD_BUILD_VER}${ATOM_VENDOR_BUILD_VER}-NOSAS-NOSH_appcpuImage"
ARM_NOSH_IMAGE_FILENAME="${VERSION_PROJECT}-NOSH"
ATOM_NOSH_IMAGE_FILENAME="${ARM_NOSH_IMAGE_FILENAME}_appcpuImage"


ENCRYPTIMAGE_TOOL_FOLDERNAME="cbnEncryptImage_v2"
KEY_FOLDER="${HOME_FOLDER}/GW7557LG_RSA_Keys"
SH_PUBLIC_KEY_NAME="GW7557LG-SH.pub"
SH_PRIVATE_KEY_NAME="GW7557LG-SH.pem"
NOSH_PUBLIC_KEY_NAME="GW7557LG-NOSH.pub"
NOSH_PRIVATE_KEY_NAME="GW7557LG-NOSH.pem"
RELEASE_FOLDER="Release"

function Do_The_Checksum(){
    foldername=$1
    md5sum "${BUILD_FOLDER}/$foldername/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}/"* > "${BUILD_FOLDER}/$foldername/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}/md5.txt"
}
function Sync_SH_Image_To_Release_Folder(){
    cd "${BUILD_FOLDER}"
    cd "SH/${ARM_REPOSITORY_NAME}"
    mkdir -p ${RELEASE_FOLDER}
    #copy ATOM file to Release folder
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ATOM_SH_IMAGE_FILENAME}" ${RELEASE_FOLDER}
    #copy ARM file to Release folder
    cp "${ENCRYPTIMAGE_TOOL_FOLDERNAME}/${VERSION_PROJECT}-SH-PA" ${RELEASE_FOLDER}
    #copy P7 file to Release folder
    cp "${ENCRYPTIMAGE_TOOL_FOLDERNAME}/${VERSION_PROJECT}-SH.p7" ${RELEASE_FOLDER}
    #copy public key to Release folder
    cd ~
    cp "${KEY_FOLDER}/${SH_PUBLIC_KEY_NAME}" "${BUILD_FOLDER}/SH/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}"
    #show the file information
    ls -al "${BUILD_FOLDER}/SH/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}"
    #do the ckecum
    Do_The_Checksum "SH"
}

function Sync_NOSH_Image_To_Release_Folder(){
    cd "${BUILD_FOLDER}"
    cd "NOSH/${ARM_REPOSITORY_NAME}"
    mkdir -p ${RELEASE_FOLDER}
    #copy ATOM file to Release folder
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ATOM_NOSH_IMAGE_FILENAME}" ${RELEASE_FOLDER}
    #copy ARM file to Release folder
    cp "${ENCRYPTIMAGE_TOOL_FOLDERNAME}/${VERSION_PROJECT}-NOSH-PA" ${RELEASE_FOLDER}
    #copy P7 file to Release folder
    cp "${ENCRYPTIMAGE_TOOL_FOLDERNAME}/${VERSION_PROJECT}-NOSH.p7" ${RELEASE_FOLDER}
    #copy public key to Release folder
    cd ~
    cp "${KEY_FOLDER}/${NOSH_PUBLIC_KEY_NAME}" "${BUILD_FOLDER}/NOSH/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}"
    #show the file information
    ls -al "${BUILD_FOLDER}/NOSH/${ARM_REPOSITORY_NAME}/${RELEASE_FOLDER}"
    #do the ckecum
    Do_The_Checksum "NOSH"
}

function Generate_FW_Image_SH(){
    cd SH
    cp "${ATOM_REPOSITORY_NAME}/${ATOM_IMAGE_PATH}/${ATOM_ORI_SH_IMAGE_FILENAME}" "${ARM_REPOSITORY_NAME}/${ARM_OUTPUT_IMAGE_PATH}/${ATOM_SH_IMAGE_FILENAME}"
    cd ${ARM_REPOSITORY_NAME}
    make filesystem ATOM_BUILD_NUM=${ARM_ORI_SH_IMAGE_FILENAME}
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ARM_TEMP_IMAGE_FILENAME}" "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-SH-PA"
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ATOM_TEMP_IMAGE_FILENAME}" "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-SH"
    cp "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-SH-PA" ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cp ${KEY_FOLDER}/${SH_PRIVATE_KEY_NAME} ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cp ${KEY_FOLDER}/${SH_PUBLIC_KEY_NAME} ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cd ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    ./cbnEncryptImage2 sign ${SH_PRIVATE_KEY_NAME} "${VERSION_PROJECT}-SH-PA" "${VERSION_PROJECT}-SH.p7"
    ./cbnEncryptImage2 verify ${SH_PUBLIC_KEY_NAME} "${VERSION_PROJECT}-SH.p7" "${VERSION_PROJECT}-SH-PA-output"
    md5sum "${VERSION_PROJECT}-SH-PA" "${VERSION_PROJECT}-SH-PA-output"
    echo "Ready to enter Sync_SH_Image_To_Release_Folder"
    Sync_SH_Image_To_Release_Folder
}

function Generate_FW_Image_NOSH(){
    cd NOSH
    cp "${ATOM_REPOSITORY_NAME}/${ATOM_IMAGE_PATH}/${ATOM_ORI_NOSH_IMAGE_FILENAME}" "${ARM_REPOSITORY_NAME}/${ARM_OUTPUT_IMAGE_PATH}/${ATOM_NOSH_IMAGE_FILENAME}"
    cd ${ARM_REPOSITORY_NAME}
    make filesystem ATOM_BUILD_NUM=${ARM_ORI_NOSH_IMAGE_FILENAME}
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ARM_TEMP_IMAGE_FILENAME}" "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-NOSH-PA"
    cp "${ARM_OUTPUT_IMAGE_PATH}/${ATOM_TEMP_IMAGE_FILENAME}" "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-NOSH"
    cp "${ARM_OUTPUT_IMAGE_PATH}/${VERSION_PROJECT}-NOSH-PA" ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cp ${KEY_FOLDER}/${NOSH_PRIVATE_KEY_NAME} ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cp ${KEY_FOLDER}/${NOSH_PUBLIC_KEY_NAME} ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    cd ${ENCRYPTIMAGE_TOOL_FOLDERNAME}
    ./cbnEncryptImage2 sign ${NOSH_PRIVATE_KEY_NAME} "${VERSION_PROJECT}-NOSH-PA" "${VERSION_PROJECT}-NOSH.p7"
    ./cbnEncryptImage2 verify ${NOSH_PUBLIC_KEY_NAME} "${VERSION_PROJECT}-NOSH.p7" "${VERSION_PROJECT}-NOSH-PA-output"
    md5sum "${VERSION_PROJECT}-NOSH-PA" "${VERSION_PROJECT}-NOSH-PA-output"
    Sync_NOSH_Image_To_Release_Folder
}

function Delete_Tag(){
    cd ${ARM_REPOSITORY_NAME}
    git push --delete origin ${VERSION_PROJECT}
    cd ..
    cd ${ATOM_REPOSITORY_NAME}
    git push --delete origin ${VERSION_PROJECT}
    cd ..
}
#######################################
#######Start Script....################
#######################################

echo "SOP for build SH image: 1->2->3 done"
echo "SOP for build NOSH image: 1->2->4 done"
echo "SOP for build SH/NOSH image: 1->2->3 and create another shell run 4 only"
echo "1. Add the tag"
echo "2. Create the SH and NOSH data"
echo "3. Build the SH version and Generate firmware"
echo "4. Build the NOSH version and Generate firmware"
echo "5. Generate SH firmware"
echo "6. Generate NOSH firmware"
echo "10. Run step from 1 to 4"
echo "11. Delete temp build folder"
echo "99. Delete test tag"
read option

case "$option" in
    "1")
        Checkout_Source_And_Add_The_Tag_For_ARM
        Checkout_Source_And_Add_The_Tag_For_ATOM
    ;;
    "2")
        Do_Before_Start_Build
    ;;
    "3")
        echo "====================SH FW Build Start====================================="
        Build_ARM_Code_SH
        Build_ATOM_Code_SH
        Generate_FW_Image_SH
        echo "====================SH FW Build End====================================="
    ;;
    "4")
        echo "====================NOSH FW Build Start====================================="
        Build_ARM_Code_NOSH
        Build_ATOM_Code_NOSH
        Generate_FW_Image_NOSH
        echo "====================NOSH FW Build End====================================="
    ;;
    "5")
        Generate_FW_Image_SH
    ;;
    "6")
        Generate_FW_Image_NOSH
    ;;
    "10")
        #11
        current_path=`pwd`
        echo "====================Build Start====================================="
        start_time=`date`
        rm -rf NOSH SH/ PUMA6_61_RGW_ARM/ PUMA6_61_ATOM/
        #1
        Checkout_Source_And_Add_The_Tag_For_ARM
        Checkout_Source_And_Add_The_Tag_For_ATOM
        #2
        Do_Before_Start_Build
        #3
        Build_ARM_Code_SH
        Build_ATOM_Code_SH
        Generate_FW_Image_SH
        cd "$current_path"
        #4
        Build_ARM_Code_NOSH
        Build_ATOM_Code_NOSH
        Generate_FW_Image_NOSH
        end_time=`date`
        echo "====================Build End====================================="
        echo "Total time is from $start_time to $end_time"
    ;;
    "11")
        rm -rf NOSH SH/ PUMA6_61_RGW_ARM/ PUMA6_61_ATOM/
    ;;
    "99")
        Delete_Tag
    ;;
    "*")
        echo "Not supported"
    ;;
esac



#Do_The_Tag_For_ARM
#Do_The_Tag_For_ATOM
#Do_Before_Start_Build
#test ok
#Build_ARM_Code_NOSH
#Build_ATOM_Code_NOSH
#test ok

#Build_ARM_Code_SH
#Build_ATOM_Code_SH
#Generate_FW_Image_SH
#Generate_FW_Image_NOSH
