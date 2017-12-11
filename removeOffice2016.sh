#!/usr/bin/env bash
#
# Remove Microsoft Office 2016 from macOS
#

export LOG_FILE="/Library/Logs/Microsoft/Office2016-uninstall.log"
export TEMP_LOG="/private/tmp/$(basename ${LOG_FILE})"
export LOG_TAG="Office2016Uninstaller"
export TODAY=$(date +"%Y-%m-%d")

backup() {
    if [[ -e "${1}" ]]; then
        cp "${1}" "${1}.${TODAY}.bak"
        if [[ -e "${1}.${TODAY}.bak" ]]; then
            printlog -g "Backup of '${1}' succeeded."
            return 0
        else
            printlog -r "Backup of '${1}' failed."
            return 1
        fi
    else
        printlog -y "'${1}' does not exist. Skipping."
        return 0
    fi
}

printlog() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0;0m'

    if [[ "$1" == "-r" ]]; then
        shift
        logger -is -p local3.info -t ${LOG_TAG} "$*" 2>> ${TEMP_LOG}
        printf "${RED}$*${NC}\n"
    elif [[ "$1" == "-y" ]]; then
        shift
        logger -is -p local3.info -t ${LOG_TAG} "$*" 2>> ${TEMP_LOG}
        printf "${YELLOW}$*${NC}\n"
    elif [[ "$1" == "-g" ]]; then
        shift
        logger -is -p local3.info -t ${LOG_TAG} "$*" 2>> ${TEMP_LOG}
        printf "${GREEN}$*${NC}\n"
    else
        logger -is -p local3.info -t ${LOG_TAG} "$*" 2>> ${TEMP_LOG}
        printf "$*\n"
    fi
}

finalizelog() {
    cat ${TEMP_LOG} >> ${LOG_FILE}
    rm ${TEMP_LOG}
    if [[ -e "${TEMP_LOG}" ]]; then
        logger -is -p local3.info -t ${LOG_TAG} "Removal of ${TEMP_LOG} failed." 2>> ${LOG_FILE}
        return 1
    else
        logger -is -p local3.info -t ${LOG_TAG} "Removal of ${TEMP_LOG} succeeded." 2>> ${LOG_FILE}
        return 1
    fi
}

remove() {
    if [[ -e "${1}" ]]; then
        rm -Rf "${1}"
        if [[ -e "${1}" ]]; then
            printlog -r "Removal of '${1}' failed."
            return 1
        else
            printlog -g "Removal of '${1}' succeeded."
            return 0
        fi
    else
        printlog -y "'${1}' does not exist. Skipping."
        return 0
    fi
}

userIteration() {
    for ITERATED_USER in $(dscl . list /Users UniqueID | awk '$2 >= 500 {print $1}'); do
        su $ITERATED_USER -c "$*"
    done
}

# Export functions to make accesible to userIteration

export -f backup
export -f printlog
export -f remove

# Check that script is running as root

if ! [ $(id -u) = 0 ]; then
   printf "Must be run as root.\n"
   exit 1
fi

# Change working directory to a shared space to prevent ugly errors.

cd "/private/tmp"

# Make TEMP_LOG accesible to all Users
touch ${TEMP_LOG}
chmod 666 ${TEMP_LOG}

# Remove Application Bundles

remove "/Applications/Microsoft Excel.app"
remove "/Applications/Microsoft OneNote.app"
remove "/Applications/Microsoft Outlook.app"
remove "/Applications/Microsoft PowerPoint.app"
remove "/Applications/Microsoft Word.app"

# Remove supporting files from Library

remove "/Library/LaunchDaemons/com.microsoft.office.licensingV2.helper.plist"
remove "/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist"
remove "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper"
remove "/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper"
remove "/Library/Preferences/com.microsoft.office.licensingV2.plist"

# Remove supporting files from user libraries

userIteration 'remove "$HOME/Library/Containers/com.microsoft.errorreporting"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.Excel"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.netlib.shipassertprocess"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.Office365ServiceV2"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.Outlook"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.Powerpoint"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.RMS-XPCService"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.Word"'
userIteration 'remove "$HOME/Library/Containers/com.microsoft.onenote.mac"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.ms"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"'

# Remove any perpetual or volume license

backup "/Library/Preferences/com.microsoft.office.licensingV2.plist"
remove "/Library/Preferences/com.microsoft.office.licensingV2.plist"

# Remove supporting files from user library group containers

userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/com.microsoft.Office365.plist"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/com.microsoft.e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O.plist"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/com.microsoft.Office365V2.plist"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/com.microsoft.O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e.plist"'
userIteration 'remove "$HOME/Library/Group Containers/UBF8T346G9.Office/O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e"'

# Remove any keychain entries for Office

userIteration '/usr/bin/security delete-internet-password -s "msoCredentialSchemeADAL"'
userIteration '/usr/bin/security delete-internet-password -s "msoCredentialSchemeLiveId"'
userIteration '/usr/bin/security delete-generic-password -l "Microsoft Office Identities Settings 2"'
userIteration '/usr/bin/security delete-generic-password -l "Microsoft Office Identities Cache 2"'

# Remove the "Belongs To" information

userIteration '/usr/bin/defaults delete com.microsoft.office OfficeActivationEmailAddress | printlog'

# Reset the first run experience for each licensed app

userIteration '/usr/bin/defaults write com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool FALSE | printlog'
userIteration '/usr/bin/defaults write com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool FALSE | printlog'
userIteration '/usr/bin/defaults write com.microsoft.Powerpoint kSubUIAppCompletedFirstRunSetup1507 -bool FALSE | printlog'
userIteration '/usr/bin/defaults write com.microsoft.Outlook FirstRunExperienceCompletedO15 -bool FALSE | printlog'

# Restart the CFPreferences daemon to ensure that all caches are flushed

/usr/bin/killall cfprefsd

# Append cat of $TEMP_LOG into $LOG_FILE and remove $TEMP_LOG

finalizelog
