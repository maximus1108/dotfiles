#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# A script to install some common tools and applications that I use.
# -----------------------------------------------------------------------------

red='\033[0;31m'
color_reset='\033[0m' 

function print_err {
  echo -e "${red}$1${color_reset}"
}

failed_installs=()
function brew_install {
  local package=$1
  if ! command -v $package &> /dev/null; then
    if ! brew install $package; then
      print_err "Failed to install $package."
      failed_installs+=("$package")
      return 1
    else
      echo " package installed."
      return 0
    fi
  fi
  return 1
}

if ! command -v brew &> /dev/null; then
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    print_err "Failed to install Homebrew."
    failed_installs+=("Homebrew")
  else
    echo "Homebrew installed."
  fi
fi

if ! command -v zsh &> /dev/null; then
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
    print_err "Failed to install zsh."
    failed_installs+=("zsh")
  else
    echo "zsh installed."
  fi
fi

brew_install "git"
brew_install "go"

if brew_install "pyenv"; then
  py_version=$(pyenv install --list | grep -E "^\s+\d"  | egrep -Ev "[a-zA-Z]" | tail -n 1 | tr -d ' ')
  if ! pyenv install $py_version; then
    print_err "Failed to install python."
    failed_installs+=("python")
  else
    pyenv global $py_version
    echo "python $py_version installed."
  fi
fi

if ! command -v docker &> /dev/null; then
  if ! brew install --cask docker; then
    print_err "Failed to install docker."
    failed_installs+=("docker")
  else
    echo "docker installed."
  fi
fi

brew_install "kubectl"

if brew_install "tfenv"; then
  if ! tfenv install latest; then
    print_err "Failed to install terraform."
    failed_installs+=("terraform")
  else
    tfenv use latest
    echo "$(terraform --version | head -n 1) installed."
  fi
fi

brew_install "jq"
brew_install "yq"
brew_install "minikube"
brew_install "vim"

if ! command -v code &> /dev/null; then
  if ! brew install --cask visual-studio-code; then
    print_err "Failed to install vscode."
    failed_installs+=("vscode")
  else
    echo "vscode installed."
  fi
fi

. $(brew --prefix nvm)/nvm.sh &> /dev/null
if brew_install nvm; then
  . $(brew --prefix nvm)/nvm.sh
  if ! nvm install --lts; then
    print_err "Failed to install node."
    failed_installs+=("node")
  else
    nvm use --lts
    echo "node $(node --version) installed."
  fi
fi

if ! command -v rvm &> /dev/null; then
  if ! curl -sSL https://get.rvm.io | bash -s stable --ruby; then
    print_err "Failed to install rvm."
    failed_installs+=("rvm")
  else
    echo "rvm installed."
    if ! rvm install ruby > /dev/null; then
      print_err "Failed to install ruby."
      failed_installs+=("ruby")
    else
      rvm --default use ruby
      echo "$(ruby --version) installed."
    fi
  fi
fi

if [ ${#failed_installs[@]} -ne 0 ]; then
  print_err "Failed to install the following: ${failed_installs[*]}"
fi
