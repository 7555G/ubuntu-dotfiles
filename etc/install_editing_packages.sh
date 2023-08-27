#!/usr/bin/env bash

main() {
    if [[ "$(lsb_release -si)" != "Ubuntu" ]]; then
        echo "Failed: only source this in Ubuntu."
        return 1
    fi

    local BR_TEXT='\033[1;97m'
    local TEXT='\033[0m'

    # install mambaforge
    if ! [[ -d /opt/mambaforge ]]; then
        local CONDA_DIR="/opt/mambaforge"

        echo -e "${BR_TEXT}\n- Setting up Mambaforge in ${CONDA_DIR}${TEXT}"
        curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
        sudo bash "Mambaforge-$(uname)-$(uname -m).sh" -b -p /opt/mambaforge
        sudo chmod -R o+w /opt/mambaforge # allow write access for all users
        rm "Mambaforge-$(uname)-$(uname -m).sh"
        export MAMBA_NO_BANNER=1
        source "${CONDA_DIR}/etc/profile.d/conda.sh"
        source "${CONDA_DIR}/etc/profile.d/mamba.sh"
        mamba update --name base --all -y
        #mamba create --name editing -y
    fi

    # remove old clang
    if command -v "clang-10" &> /dev/null; then
        echo -e "${BR_TEXT}\n- Removing clang-10 ${TEXT}"
        sudo apt remove -y \
            clang-10 \
            clang \
            libclang-common-10-dev \
            libclang-cpp10
    fi

    # install a specific clang version
    local version="17"
    if ! command -v "clang-${version}" &> /dev/null; then
        echo -e "${BR_TEXT}\n- Installing clang-17 ${TEXT}"
        wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
        sudo add-apt-repository -y "deb http://apt.llvm.org/$(lsb_release -sc) llvm-toolchain-$(lsb_release -sc)-${version} main"
        sudo apt update
        local tools=("clang" "clangd" "clang-format" "clang-tidy")
        for tool in "${tools[@]}"; do
            sudo apt install -y "${tool}-${version}"
            echo -n "Adding symlink: "
            sudo cp -nv --no-dereference \
                "$(which "${tool}-${version}")" \
                "$(dirname "$(which "${tool}-${version}")")/${tool}"
        done
    fi

    # install other linters and fixers
    echo -e "${BR_TEXT}\n- Installing some code linters and fixers${TEXT}"
    sudo apt install -y \
        gdb \
        cppcheck \
        python3-pip \
        python3-bashate
    sudo snap install bash-language-server --classic
    sudo snap install shellcheck
    sudo snap install universal-ctags
    #mamba install -y --name editing \
    #    mamba-bash-completion \
    sudo pip install \
        cmakelang \
        python-lsp-server \
        python-lsp-ruff \
        autopep8 \
        isort

    if [[ "$(lsb_release -sc)" == "focal" ]] && [[ "$(arch)" == "aarch64" ]]; then
        # install shfmt manually on arm64 Focal
        curl http://ports.ubuntu.com/pool/universe/s/shfmt/shfmt_3.4.3-1_arm64.deb --output temp.deb
        sudo dpkg -i temp.deb
        rm temp.debcode linters and fixers
    else
        sudo snap install shfmt
    fi

    # (optional) install GCC7
    if [[ "$(lsb_release -sc)" == "focal" ]]; then
        echo -e "${BR_TEXT}\n- Installing GCC7${TEXT}"
        sudo apt install -y gcc-7 g++-7
    fi

    # install latest vim
    echo -e "${BR_TEXT}\n- Installing the latest Vim${TEXT}"
    sudo add-apt-repository -y ppa:jonathonf/vim
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y vim-gtk # has clipboard support

    # install some other packages
    echo -e "${BR_TEXT}\n- Installing some other packages${TEXT}"
    sudo apt install -y \
        ubuntu-restricted-extras \
        cmake \
        htop \
        tree \
        jq \
        doxygen

    echo -e "${BR_TEXT}\n- Finished${TEXT}"
}

main "$@"
unset main
