#!/usr/bin/env bash

if ! command -v git &> /dev/null; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "Installing git."
  brew install git
fi

dotfiles_dir=$HOME/.dotfiles

if [ -d $dotfiles_dir ]; then
  while read -p  "Dotfiles directory '$dotfiles_dir' already exists, would you like to overwrite it? (yes/no) " yn; do
    case $yn in
      yes) echo "Deleting $dotfiles_dir"; rm -rf $dotfiles_dir; break;;
      no) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
fi

echo "Creating dotfiles directory '$dotfiles_dir'."
mkdir -p $dotfiles_dir

echo "Cloning dotfiles repository into '$dotfiles_dir'."
git clone --quiet https://github.com/maximus1108/dotfiles.git $dotfiles_dir
cd $dotfiles_dir

dotfiles=$(ls -a dotfiles | xargs -I{} bash -c "if ! [ -d {} ]; then echo {}; fi")

backup_folder=$HOME/.dotfiles-backup
mkdir -p $backup_folder
for dotfile in $dotfiles; do
  if [ -f $HOME/$dotfile ]; then
    echo "Backing up pre-existing $dotfile in $backup_folder.";
    mv $HOME/$dotfile $backup_folder/$dotfile
  fi
  echo "Creating symlink for $dotfile."
  ln -s -f $dotfiles_dir/dotfiles/$dotfile $HOME/$dotfile
done
