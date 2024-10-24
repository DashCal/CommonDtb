#!/usr/bin/env bash
########################
# The default pulseaudio server address is 127.0.0.1
# 本机默认音频服务地址为127.0.0.1,默认端口为4713。
# Die Standard-Audiodienst Adresse dieses Geräts lautet 127.0.0.1
# tcp:192.168.x.x:4713 or unix:/run/pulse.socket
export PULSE_SERVER=${PULSE_SERVER:-127.0.0.1}

# The default resolution is 1440x720, it is recommended that you adjust it according to the screen ratio.
# 默认分辨率为1440x720,您可以修改为其他值
# 16:9 [3840x2160, 3200x1800, 2560X1440, 1920x1080, 1600x900, 1366x768, 1280x720, 1024x576, 960x540]
# 16:10 [3840x2400, 2560x1600, 1920x1200, 1680x1050, 1440x900]
# 18:9 [3840x1920, 2880x1440, 2160x1080, 1440x720]
# 19:9 [3800x1800, 3040x1440, 2280x1080, 1520x720]
# 21:9 [3440x1440, 2560x1080, 1792x768]
# 4:3 [3840x2880, 2400x1800, 2048x1536, 1920x1440, 1600x1200, 1400x1050, 1024x768, 640x480]
VNC_RESOLUTION=2880x1800

# If the display number=2,then vnc port=5902.
# 若显示编号为2,则vnc端口为$((5900+2))=5902。
# Wenn die Anzeigenummer 2 ist, ist der vnc-Port 5902
unset WAYLAND_DISPLAY
VNC_DISPLAY=2
RFB_PORT=$((5900 + VNC_DISPLAY))

# You can specify a VNC user. The current user is $(id -un)
# 您可以指定VNC用户，例如root或ubuntu，默认为$(id -un)
# Sie können einen VNC-Benutzer angeben
VNC_USER=$(id -un)

# Only allow connections from localhost.Default is false.
# 当此变量的值为true时，仅允许本机连接；为false时，允许局域网连接。默认为false
# Wenn dieser Parameterwert "true" ist, lassen Sie nur Verbindungen von localhost zu
VNC_LOCALHOST=false

# You can choose tiger or tight.
# 服务端可选tiger或tight。
# Sie können "tiger" oder "tight" wählen.
VNC_SERVER=tiger

# Zlib compression level for ZRLE encoding (it does not affect Tight encoding). Acceptable values are between 0  and  9.
# 压缩级别,可选0至9,默认为0。
# Die Standardkomprimierungsstufe für zlib ist 0
ZLIB_LEVEL=0

# Specify the pixel depth in bits of the desktop to be created. Default is 24.
# 色彩/位/像素深度，可选16、24或32,默认为24，建议选用16或者24。
# Die Standardpixeltiefe beträgt 24
PIXEL_DEPTH=24

# Always treat incoming connections as shared, regardless of the client-specified setting. Default is true.
ALWAYS_SHARED=true

# If the value is true, "sudo service dbus start" will be executed automatically every time.
AUTO_START_DBUS=true

# Before each start, vnc will be automatically stopped.
# If the value is true, then "startvnc" => "restart vnc"
AUTO_STOP_VNC=true

# If you are using arch and cannot start dbus-daemon, then change the value to true.
# TMOE_CHROOT=false

# vnc log file
VNC_LOG_FILE=$HOME/.vnc/vnc.log
# Each time vnc is started, the previous log is cleared
AUTO_VNC_LOG_CLEARING=true

# vnc desktop name
# VNC_DESKTOP_NAME="my_ubuntu/arch/fedora_xfce-desktop"

# xdg runtime dir
# export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
###################
set_vnc_env_1() {
    if [[ ${VNC_USER} != $(whoami) && -n ${VNC_USER} ]]; then
        if grep -q "^${VNC_USER}:" /etc/passwd; then
            CURRENT_HOME=$(grep "^${VNC_USER}:" /etc/passwd | awk -F ':' '{print $6}' | head -n 1)
            HOME=${CURRENT_HOME}
        else
            printf "\033[33m%s\033[m %s \033[32m%s \033[m%s\n" "WARNING！" "You should type" "useradd -m ${VNC_USER}" "to create it."
            unset VNC_USER
        fi
        #sudo su - ${VNC_USER} -c "startvnc" || su - ${VNC_USER} -c "startvnc"
        #return 0
    fi
    ###################
    X509_VNC_ENABLED=false
    #Default is false.
    X509_KEY=${HOME}/.vnc/x509-key.pem
    #Path to the key of the X509 certificate in PEM format
    X509_CERTIFICATE=${HOME}/.vnc/x509-cert.pem
    #Path to the X509 certificate in PEM format
    ###################
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    PURPLE=$(printf '\033[35m')
    CYAN=$(printf '\033[36m')
    RESET=$(printf '\033[m')
    BOLD=$(printf '\033[1m')
    printf "${GREEN}%s ${YELLOW}%s${RESET} %s\n" "Starting" "vnc server" "..."
    printf "%s\n" "The current ${BLUE}vnc port${RESET} is ${YELLOW}${RFB_PORT}${RESET}, and vnc address is ${GREEN}localhost${YELLOW}:${RFB_PORT}${RESET}"
    export USER=${VNC_USER}
    [[ ${AUTO_STOP_VNC} != true ]] || stopvnc -no-stop-dbus 2>/dev/null
    ###################
    TMOE_LINUX_DIR='/usr/local/etc/tmoe-linux'
    TMOE_GIT_DIR="${TMOE_LINUX_DIR}/git"
    TMOE_TOOL_DIR="${TMOE_GIT_DIR}/share/old-version/tools"
    TMOE_VNC_PASSWD_FILE="${HOME}/.vnc/passwd"
    XSESSION_FILE='/etc/X11/xinit/Xsession'
    TMOE_LOCALE_FILE="${TMOE_LINUX_DIR}/locale.txt"
    TIGERVNC_CONFIG_FILE='/etc/tigervnc/vncserver-config-tmoe'
    TIGERVNC_VIEWER_WIN10='/mnt/c/Users/Public/Downloads/tigervnc/vncviewer64.exe'
    # TIGERVNC_BIN='/usr/bin/tigervncserver'
    unset TMOE_WSL
}
###################
check_tmoe_locale() {
    if [[ -r ${TMOE_LOCALE_FILE} ]]; then
        TMOE_LANG=$(head -n 1 ${TMOE_LOCALE_FILE})
    else
        case ${LANG} in
        *UTF-8) TMOE_LANG=${LANG} ;;
        *) TMOE_LANG="zh_CN.UTF-8" ;;
        esac
    fi
    export LANG="${TMOE_LANG}"
}
###################
check_current_user_name_and_group() {
    CURRENT_USER_NAME=$(grep "${HOME}" /etc/passwd | awk -F ':' '{print $1}' | head -n 1)
    CURRENT_USER_GROUP=$(grep "${HOME}" /etc/passwd | awk -F ':' '{print $4}' | cut -d ',' -f 1 | head -n 1)
    if [[ -z ${CURRENT_USER_GROUP} ]]; then
        CURRENT_USER_GROUP=${CURRENT_USER_NAME}
    fi
}
###################
fix_vnc_permissions() {
    CURRENT_USER_VNC_FILE_PERMISSION=$(ls -l "${TMOE_VNC_PASSWD_FILE}" | awk -F ' ' '{print $3}')
    case ${CURRENT_USER_VNC_FILE_PERMISSION} in
    "${CURRENT_USER_NAME}") ;;
    *)
        cd "${HOME}" || exit
        VNC_FILE=".vnc"
        for i in ".ICEauthority" ".Xauthority" ".config"; do
            [[ ! -e "${i}" ]] || VNC_FILE="${VNC_FILE} ${i}"
        done
        sudo -E chown -Rv "${CURRENT_USER_NAME}":"${CURRENT_USER_GROUP}" ${VNC_FILE} || su -c "chown -Rv ${CURRENT_USER_NAME}:${CURRENT_USER_GROUP} ${VNC_FILE}"
        ;;
    esac
}
###################
check_wsl() {
    if [[ -r /proc/version ]]; then
        UNAME="$(head -n 1 /proc/version)"
        case "${UNAME}" in
        *Microsoft* | *microsoft*)
            TMOE_CHROOT=true
            TMOE_WSL=true
            export TMOE_CHROOT TMOE_WSL
            source ${TMOE_LINUX_DIR}/wsl_pulse_audio
            ;;
        esac
    fi
}
git_pull_tmoe_git_dir() {
    ${SUDO_CMD} git reset --hard origin/master
    ${SUDO_CMD} git pull --rebase --stat origin master --allow-unrelated-histories || ${SUDO_CMD} git rebase --skip
}
set_passwd() {
    mkdir -pv ~/.config/tmoe-linux ~/.vnc
    if [[ ! -s "${TMOE_VNC_PASSWD_FILE}" ]]; then
        for i in /root/.vnc/passwd /root/.vnc/x11passwd; do
            sudo -E cp -fv ${i} ~/.vnc
        done
        if [ ! -e "${TMOE_VNC_PASSWD_FILE}" ]; then
            printf "%s\n" "${GREEN}updating${RESET} ..."
            cd ${TMOE_GIT_DIR} || exit 1
            printf "%s\n" "${GREEN}git pull ${YELLOW}--rebase --stat ${BLUE}origin master ${PURPLE}--allow-unrelated-histories${RESET}"
            case $(id -u) in
            0)
                SUDO_CMD=""
                git_pull_tmoe_git_dir
                ./share/old-version/tools/app/tool -passwd
                ;;
            *)
                SUDO_CMD="sudo"
                git_pull_tmoe_git_dir
                sudo -E bash ./share/old-version/tools/app/tool -passwd
                ;;
            esac
        fi
        sudo -E chown -Rv "${CURRENT_USER_NAME}":"${CURRENT_USER_GROUP}" ~/.vnc/
    fi
}
reset_passwd() {
    if [[ ! -e ${HOME}/.vnc/passwd ]]; then
        printf "%s\n" \
            "发生错误，正在重置密码，请输入6至8位数的密码 :" \
            "Resetting the password ..." \
            "Please enter a new passwd :"
        vncpasswd
        if [[ ! -s ${HOME}/.vnc/passwd ]]; then
            x11vncpasswd
            cp ~/.vnc/x11passwd ~/.vnc/passwd
        fi
        for i in ~/.vnc/*passwd; do
            chmod -v 600 "${i}"
        done
    fi
}
remove_proot_meta_files() {
    for i in ~/.vnc/.proot*; do
        if [[ -e ${i} ]]; then
            printf "%s\n" "${GREEN}sudo ${RED}rm ${YELLOW}-fv ${BLUE}${i}${RESET}"
            rm -fv "${i}" || sudo rm -fv "${i}"
        fi
    done
}
tmoe_vnc_preconfigure() {
    check_tmoe_locale
    check_current_user_name_and_group
    set_passwd
    reset_passwd
    remove_proot_meta_files
    fix_vnc_permissions
    check_wsl
}
###################
check_vnc_ip() {
    TMOE_IP_ADDR=$(ip -4 -br -c a | awk '{print $NF}' | cut -d '/' -f 1 | grep -v '127\.0\.0\.1' | sed "s@\$@:${RFB_PORT}@")
    TMOE_IPV6_ADDR=$(ip -6 -c a | grep '/' | grep -v 'fe80::.*/64' | awk '{print $2}' | cut -d '/' -f 1 | sed "s@^@[@g;s@\$@]:${RFB_PORT}@g")
}
display_vnc_ip_addr() {
    # check_vnc_port
    check_vnc_ip
    case ${TMOE_LANG} in
    zh_*UTF-8)
        cat <<-EOF
正在启动vnc服务,${YELLOW}本机${RESET}vnc地址 ${BLUE}localhost${GREEN}:${RFB_PORT}${RESET}
${YELLOW}IPv6${RESET}地址 ${TMOE_IPV6_ADDR}
The LAN VNC address ${YELLOW}局域网${RESET}地址 ${TMOE_IP_ADDR}
EOF
        ;;
    *)
        cat <<-EOF
The ${YELLOW}local${RESET} vnc address is ${BLUE}localhost${GREEN}:${RFB_PORT}${RESET}
The ${YELLOW}IPv6${YELLOW} address is ${TMOE_IPV6_ADDR}
The ${YELLOW}LAN${RESET} vnc address is ${TMOE_IP_ADDR}
EOF
        ;;
    esac

}
###################
start_win10_tigervnc() {
    case ${TMOE_WSL} in
    true)
        cd "${HOME}" || cd /tmp || exit 1
        nohup ${TIGERVNC_VIEWER_WIN10} -PasswordFile "${TMOE_VNC_PASSWD_FILE}" localhost:${RFB_PORT} &>/dev/null &
        cd - &>/dev/null || exit 1
        ;;
    esac
}
###################
cat_vnc_log() {
    local Cat_bin Sleep_time
    Cat_bin='cat'
    Sleep_time=$1
    for i in batcat bat; do
        if [[ -n $(command -v $i) ]]; then
            Cat_bin=$i
            break
        fi
    done

    printf "%s\n" \
        "${GREEN}${Cat_bin} ${YELLOW}-n ${BLUE}${VNC_LOG_FILE}${RESET}"

    sleep "$Sleep_time"

    if [[ ! -s ${VNC_LOG_FILE} ]]; then
        echo "Start vnc timeout ..."
        sleep "$Sleep_time"
        if [[ ! -s ${VNC_LOG_FILE} ]]; then
            return 1
        fi
    fi

    case ${Cat_bin} in
    batcat | bat) grep -Ev 'tigervnc.org|xkbcomp|keysym' ${VNC_LOG_FILE} | ${Cat_bin} -pp -l log - ;;
    *) grep -Ev 'tigervnc.org|xkbcomp|keysym' ${VNC_LOG_FILE} | cat -n - ;;
    esac
}
start_tmoe_xvnc() {
    local XVNC_BIN TMOE_VNC_BIN Desktop_name
    case ${VNC_SERVER} in
    tight* | Tight*)
        XVNC_BIN='Xtightvnc'
        TMOE_VNC_BIN='tight'
        if [[ ! $(command -v ${XVNC_BIN}) ]]; then
            printf "%s\n" "${PURPLE}sudo ${GREEN}apt ${YELLOW}install ${BLUE}tightvncserver${RESET}"
            sudo apt install tightvncserver || su -c "apt install -y tightvncserver"
        fi
        ;;
    tiger* | Tiger* | *)
        XVNC_BIN='Xtigervnc'
        TMOE_VNC_BIN='tiger'
        [[ $(command -v ${XVNC_BIN}) ]] || XVNC_BIN='Xvnc'
        ;;
    esac
    source ${TIGERVNC_CONFIG_FILE} 2>/dev/null

    if [[ ! ${ZLIB_LEVEL} =~ ^[0-9]+$ ]]; then
        ZLIB_LEVEL=0
    elif ((ZLIB_LEVEL >= 10)); then
        ZLIB_LEVEL=9
    fi
    if [[ ! ${PIXEL_DEPTH} =~ ^[0-9]+$ ]]; then
        ZLIB_LEVEL=24
    elif ((PIXEL_DEPTH > 32)); then
        PIXEL_DEPTH=32
    fi

    if [[ -n ${VNC_DESKTOP_NAME} ]]; then
        Desktop_name=${VNC_DESKTOP_NAME}
    elif [[ -n ${desktop} ]]; then
        Desktop_name=${desktop}
    fi

    if [[ ${TMOE_VNC_BIN} = tiger ]]; then
        set -- "${@}" "-ZlibLevel=${ZLIB_LEVEL}"
    fi
    # In tigervnc v1.12.0, `-rfbwait` & `-wm` has been deprecated.
    # set -- "${@}" "-rfbwait" "30000"
    # set -- "${@}" "-wm"
    set -- "${@}" "-pn"
    if [[ -e /etc/X11/fontpath.d ]]; then
        set -- "${@}" "-fp" "catalogue:/etc/X11/fontpath.d"
    fi
    set -- "${@}" "-rfbport" "${RFB_PORT}"
    if ${VNC_LOCALHOST}; then
        set -- "${@}" "-localhost"
    fi

    if [[ ${X509_VNC_ENABLED} = true && -e ${X509_KEY} && -e ${X509_CERTIFICATE} ]]; then
        set -- "${@}" "-SecurityTypes" "X509Vnc,X509Plain,X509None,VncAuth,TLSVnc"
        set -- "${@}" "-X509Key" "${X509_KEY}"
        set -- "${@}" "-X509Cert" "${X509_CERTIFICATE}"
    fi
    if ${ALWAYS_SHARED}; then
        set -- "${@}" "-alwaysshared"
    fi
    set -- "${@}" "-a" "5"

    if [[ ${VNC_RESOLUTION} =~ ^[0-9]+x[0-9]+$ ]]; then
        set -- "${@}" "-geometry" "${VNC_RESOLUTION}"
    else
        printf "%s\n" \
            "${RED}ERROR${RESET}, your ${GREEN}vnc resolution ${YELLOW}is ${BLUE}\"${VNC_RESOLUTION}\"${RESET}" \
            "Please ${PURPLE}reset ${RESET}it." \
            "The value of ${BLUE}VNC_RESOLUTION${GREEN} should be ${CYAN}horizontal pixels ${YELLOW}x ${CYAN}vertical pixels${RESET}, e.g ${BLUE}2160x1080${RESET}"
        set -- "${@}" "-geometry" "2160x1080"
    fi

    set -- "${@}" "-once"
    set -- "${@}" "-depth" "${PIXEL_DEPTH}"
    #set -- "${@}" "-deferglyphs" "16"
    set -- "${@}" "-rfbauth" "${TMOE_VNC_PASSWD_FILE}"
    set -- "${@}" "-desktop" "${Desktop_name}"
    set -- "${@}" ":${VNC_DISPLAY}"
    set -- "${XVNC_BIN}" "${@}"
    if [[ $(id -u ${VNC_USER}) = $(id -u) || -z ${VNC_USER} ]]; then
        # [[ -n ${XDG_RUNTIME_DIR} ]] || export XDG_RUNTIME_DIR=/tmp/runtime-${UID}
        # [[ -e ${XDG_RUNTIME_DIR} ]] || mkdir -pv ${XDG_RUNTIME_DIR}
        if ${AUTO_VNC_LOG_CLEARING}; then
            rm -f ${VNC_LOG_FILE}
        fi
        "${@}" &>>${VNC_LOG_FILE} &
        Vnc_pid=$!

        echo "$Vnc_pid" >~/.vnc/vnc.pid
        printf "%s\n" "${CYAN}vnc pid${BOLD}: ${BLUE}$Vnc_pid${RESET}"
        if [[ ! -e /proc/${Vnc_pid} ]]; then
            printf "%s\n" \
                "${RED}ERROR, ${PURPLE}failed ${RESET} to start ${BLUE}vnc${RESET}" \
                "You can report this issue"
            cat ${VNC_LOG_FILE}
        fi
    else
        sudo su - "${VNC_USER}" -c '"$0" "$@" &' -- "$@" || su - "${VNC_USER}" -c '"$0" "$@" &' -- "$@"
    fi
    export DISPLAY=:${VNC_DISPLAY}

    if [[ ${VNC_USER} = $(whoami) || -z ${VNC_USER} ]]; then
        bash ${XSESSION_FILE} &>~/.vnc/x.log &
        # bash ${XSESSION_FILE} 2>&1 | tee ~/.vnc/x.log &
        Xsession_pid=$!
        echo "$Xsession_pid" >~/.vnc/x.pid
        printf "%s\n" "${CYAN}session pid${BOLD}: ${BLUE}$Xsession_pid${RESET}"
        if [[ ! -e /proc/${Xsession_pid} ]]; then
            printf "%s\n" \
                "${RED}ERROR, ${PURPLE}failed ${RESET} to start ${BLUE}session${RESET}" \
                "You can report this issue"
            cat ~/.vnc/x.log
        fi
        # sleeptime=0.2
        cat_vnc_log 0.2
    else
        sudo su - "${VNC_USER}" -c "export LANG=${LANG} PULSE_SERVER=${PULSE_SERVER} TMOE_CHROOT=${TMOE_CHROOT} TMOE_PROOT=${TMOE_PROOT} DISPLAY=${DISPLAY};bash ${XSESSION_FILE} &" || su - "${VNC_USER}" -c "export LANG=${LANG} PULSE_SERVER=${PULSE_SERVER} TMOE_CHROOT=${TMOE_CHROOT} TMOE_PROOT=${TMOE_PROOT} DISPLAY=${DISPLAY};bash ${XSESSION_FILE} &"
    fi
    start_win10_tigervnc
    exit 0
}
###################
check_dbus_servcie() {
    if [[ ${AUTO_START_DBUS} = true ]]; then
        source ${TMOE_TOOL_DIR}/gui/launch_dbus_daemon
    fi
}
###################
check_xvnc() {
    if [[ -n $(command -v Xvnc) ]]; then
        start_tmoe_xvnc
        exit 0
    else
        startx11vnc
    fi
}
###################
main() {
    set_vnc_env_1
    tmoe_vnc_preconfigure
    check_dbus_servcie
    display_vnc_ip_addr
    check_xvnc
}
# -------------------
main "${@}"
