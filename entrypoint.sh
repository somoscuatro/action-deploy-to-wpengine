#!/bin/bash

WPENGINE_HOST="git.wpengine.com"
WPENGINE_ENVIRONMENT_DEFAULT="production"
WPENGINE_BRANCH_DEFAULT="main"
SSH_KEY_TYPE_DEFAULT="rsa"
WPENGINE_ENV=${WPENGINE_ENVIRONMENT:-$WPENGINE_ENVIRONMENT_DEFAULT}
LOCAL_BRANCH_DEFAULT="main"
BRANCH=${LOCAL_BRANCH:-$LOCAL_BRANCH_DEFAULT}

function init_checks() {
  if [[ -z "$WPENGINE_SSH_PRIVATE_KEY" ]] || [[ -z "$WPENGINE_SSH_PUBLIC_KEY" ]] || [[ -z "$WPENGINE_ENVIRONMENT_NAME" ]]; then
    missing_secret="WPENGINE_SSH_PRIVATE_KEY and/or WPENGINE_SSH_PUBLIC_KEY and/or WPENGINE_ENVIRONMENT_NAME"
    printf "[\e[0;31mERROR\e[0m] Secret \`$missing_secret\` is missing. Please add it to this action for proper execution.\nRefer https://github.com/somoscuatro/action-deploy-to-wpengine for more information.\n"
    exit 1
  fi
}

function setup_safe_directory() {
  git config --global --add safe.directory "$GITHUB_WORKSPACE"
}

function setup_ssh_access() {
  printf "[\e[0;34mNOTICE\e[0m] Setting up SSH access to server.\n"

  SSH_PATH="$HOME/.ssh"
  mkdir "$SSH_PATH"
  chmod 700 "$SSH_PATH"

  KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
  WPENGINE_SSH_PRIVATE_KEY_PATH="$SSH_PATH/wpengine_key"
  WPENGINE_SSH_PUBLIC_KEY_PATH="$SSH_PATH/wpengine_key.pub"

  setup_private_key
}

function setup_private_key() {
  echo "$WPENGINE_SSH_PRIVATE_KEY" > "$WPENGINE_SSH_PRIVATE_KEY_PATH"
  echo "$WPENGINE_SSH_PUBLIC_KEY" > "$WPENGINE_SSH_PUBLIC_KEY_PATH"

  ssh-keyscan -t "${SSH_KEY_TYPE:-$SSH_KEY_TYPE_DEFAULT}" "$WPENGINE_HOST" >> "$KNOWN_HOSTS_PATH"

  chmod 644 "$KNOWN_HOSTS_PATH"
  chmod 600 "$WPENGINE_SSH_PRIVATE_KEY_PATH"
  chmod 644 "$WPENGINE_SSH_PUBLIC_KEY_PATH"

  git config --global core.sshCommand "ssh -i $WPENGINE_SSH_PRIVATE_KEY_PATH -o UserKnownHostsFile=$KNOWN_HOSTS_PATH"
}

function clone_wpengine_repo() {
  printf "[\e[0;34mNOTICE\e[0m] Cloning WPEngine's repository.\n"

  cd "$GITHUB_WORKSPACE/../.." && \
  git clone --branch "${WPENGINE_BRANCH:-$WPENGINE_BRANCH_DEFAULT}" git@$WPENGINE_HOST:$WPENGINE_ENV/$WPENGINE_ENVIRONMENT_NAME.git
}

function cleanup_wpengine_repo() {
  printf "[\e[0;34mNOTICE\e[0m] Cleaning up WPEngine's repository.\n"

  cd "$GITHUB_WORKSPACE/../../$WPENGINE_ENVIRONMENT_NAME" && rm -rf *
}

function cleanup_local_repo() {
  printf "[\e[0;34mNOTICE\e[0m] Cleaning up local repository.\n"

  rm "$GITHUB_WORKSPACE/.gitignore"
  rm -rf "$GITHUB_WORKSPACE/.git"
}

function copy_local_repo_to_wpengine() {
  printf "[\e[0;34mNOTICE\e[0m] Copying Local repo to WPEngine's repository.\n"

  cp -r "$GITHUB_WORKSPACE/." "$GITHUB_WORKSPACE/../../$WPENGINE_ENVIRONMENT_NAME/"
}

function cleanup_blocklist_files() {
  printf "[\e[0;34mNOTICE\e[0m] Removing files in excluded list.\n"

  readarray -t filefolders < "$GITHUB_WORKSPACE/.github/workflows/deploy/excluded"
    for filefolder in "${filefolders[@]}"
    do
      rm -rf "$GITHUB_WORKSPACE/../../$WPENGINE_ENVIRONMENT_NAME/$filefolder"
    done
}

function setup_remote_user() {
  printf "[\e[0;34mNOTICE\e[0m] Setting up remote repository.\n"

  cd "$GITHUB_WORKSPACE/../../$WPENGINE_ENVIRONMENT_NAME" && \
  git config user.name "somoscuatro" && \
  git config user.email "tech@somoscuatro.es"
}

function deploy() {
  printf "[\e[0;34mNOTICE\e[0m] Deploying $BRANCH to $WPENGINE_ENV.\n"

  cd "$GITHUB_WORKSPACE/../../$WPENGINE_ENVIRONMENT_NAME" && \
  git add --all && \
  git commit -m "GitHub Actions Deployment" && \
  git status && \
  git push -v -o remove-empty-dirs -u origin "${WPENGINE_BRANCH:-$WPENGINE_BRANCH_DEFAULT}"
}

function main() {
  init_checks
  setup_safe_directory
  setup_ssh_access
  clone_wpengine_repo
  cleanup_wpengine_repo
  cleanup_local_repo
  copy_local_repo_to_wpengine
  cleanup_blocklist_files
  setup_remote_user
  deploy
}

main
