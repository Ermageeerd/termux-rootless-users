#!/data/data/com.termux/files/usr/bin/sh
# Fakesu installer

PREFIX="/data/data/com.termux/files/usr"
ALPINE_ETC="$PREFIX/var/lib/proot-distro/installed-rootfs/alpine/etc"
HOST_ETC="$PREFIX/etc"

add_binaries() {
    mkdir "$PREFIX/var/lib/proot-distro/installed-rootfs/alpine/etc/suhelp"
    cp ./suauth.py "$PREFIX/var/lib/proot-distro/installed-rootfs/alpine/etc/suhelp/suauth.py"
    cp ./su "$PREFIX/bin/su"
    chmod +x "$PREFIX/bin/su"
    echo "su installed"
    cp ./adduser "$PREFIX/bin/adduser"
    chmod +x "$PREFIX/bin/adduser"
    echo "adduser installed"
    cp ./deluser "$PREFIX/bin/deluser"
    chmod +x "$PREFIX/bin/deluser"
    echo "deluser installed"
    pkg reinstall termux-auth
    mkdir $PREFIX/bin/unused
    mv $PREFIX/bin/passwd $PREFIX/bin/unused/passwd
    cp ./passwd "$PREFIX/bin/passwd"
    chmod +x "$PREFIX/bin/passwd"
    echo "passwd installed"
}

install_manpage() {
    cp ./man/su.1 "$PREFIX/share/man/man1/su.1"
    gzip -f "$PREFIX/share/man/man1/su.1"
    makewhatis "$PREFIX/share/man"
    echo "Manpage added"
}

link_passwd() {
    if [ ! -d "$HOST_ETC" ]; then
        mkdir -p "$HOST_ETC"
    fi
    if [ -f "$ALPINE_ETC/passwd" ]; then
        proot-distro login alpine -- ln -sf /etc/passwd "$HOST_ETC/passwd"
        proot-distro login alpine -- ln -sf /etc/shadow "$HOST_ETC/shadow"
        echo "Linked Alpine /etc/passwd to Termux etc"
    else
        echo "Alpine's /etc/passwd not found. Has Alpine been initialized?"
    fi
}

main_install() {
    pkg upgrade -y
    echo "Upgraded Packages."
    install_manpage
    pkg install -y proot-distro
    proot-distro install alpine
    add_binaries
    link_passwd
    echo "su: successful install"
    echo "su: try it out by typing 'su'"
}

if ! command -v su >/dev/null 2>&1; then
    echo "No su installed, installing..."
    main_install
elif [ -x "$(command -v su)" ] && [ -f ./su ]; then
    installed_sha="$(sha256sum "$(command -v su)" | awk '{print $1}')"
    local_sha="$(sha256sum ./su | awk '{print $1}')"
    if [ "$installed_sha" = "$local_sha" ]; then
        echo "Rootless su is already installed."
        exit 0
    else
        echo "Installed su is not rootless su, installing..."
        main_install
    fi
else
    echo "FATAL ERROR: Installer file ./su is missing."
    exit 1
fi
