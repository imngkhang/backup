export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# 1. Tìm socket của gnome-keyring
KEYRING_SOCKET=$(find /run/user/$UID -name control 2>/dev/null | grep keyring | head -n 1)

if [ -n "$KEYRING_SOCKET" ]; then
    export GNOME_KEYRING_CONTROL=$(dirname "$KEYRING_SOCKET")
else
    eval $(gnome-keyring-daemon --start --components=secrets)
    export GNOME_KEYRING_CONTROL
fi

# 2. Giải mã bằng user tss và Unlock
TPM_FILE="$HOME/.config/gnome-keyring.tpm12"

if [ -f "$TPM_FILE" ]; then
   #$HOME/.local/bin/update-keyring > /dev/null 2>&1
# Dùng sudo -u tss để lấy mật khẩu từ chip TPM
    # 2>/dev/null để giấu lỗi nếu chip chưa sẵn sàng
    TPM_PASS=$(sudo -u tss /usr/bin/tpm_unsealdata -z -i "$TPM_FILE" 2>/dev/null | tr -d '\0')
    
    if [ -n "$TPM_PASS" ]; then
        # Đẩy mật khẩu vào script python để mở khóa
        echo -n "$TPM_PASS" | $HOME/.local/bin/unlock.py > /dev/null 2>&1
        unset TPM_PASS
    fi
fi


