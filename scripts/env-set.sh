# This bash file is meant to be source'd, not executed.

export WEBDEV_REPO=../site-webdev

if [[ -d $WEBDEV_REPO ]]; then
  source $WEBDEV_REPO/scripts/env-set.sh "$@"
  return 0
fi

echo "WARNING: expected to find webdev repo at $WEBDEV_REPO, but none found."
echo "WARNING: running local copy of setup script."

# This is a copy of the site-webdev script. It is embedded here so that
# we don't force all users to clone site-webdev. This isn't DRY, but it is temporary.

SITE_WEBDEV_ENV_SET_INSTALL_OPT="--no-install"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset)    unset NGIO_ENV_DEFS; shift;;
    --install)  SITE_WEBDEV_ENV_SET_INSTALL_OPT="--install"; shift;;
    *)          echo "WARNING: Unrecognized option for env-set.sh: $1"; shift;;
  esac
done

if [[ -z "$(type -t rvm)" ]]; then
  echo "ERROR: rvm not installed. See site-webdev README. Skipping setup."
elif [[ -z "$(type -t nvm)" ]]; then
  echo "ERROR: nvm not installed. See site-webdev README. Skipping setup."
elif [[ -z "$NGIO_ENV_DEFS" ]]; then
  export NGIO_ENV_DEFS=1
  export ANSI_YELLOW="\033[33;1m"
  export ANSI_RESET="\033[0m"
  echo -e "${ANSI_YELLOW}Setting environment variables from scripts/env-set.sh${ANSI_RESET}"

  if [[ "$SITE_WEBDEV_ENV_SET_INSTALL_OPT" == "--install" ]]; then
    nvm install 8
  else
    nvm use 8
  fi
  source scripts/get-ruby.sh "$SITE_WEBDEV_ENV_SET_INSTALL_OPT"

  export NGIO_REPO=../angular.io
  export NG_REPO=../angular
  export NGDOCEX=examples/ng/doc
  export ACX_REPO=../angular_components

  if [ ! $(type -t travis_fold) ]; then
      # In case this is being run locally. Turn travis_fold into a noop.
      travis_fold () { true; }
  fi
  export -f travis_fold

  case "$(uname -a)" in
      Darwin\ *) _OS_NAME=macos ;;
      Linux\ *) _OS_NAME=linux ;;
      *) _OS_NAME=linux ;;
  esac
  export _OS_NAME

  : ${TMP:=$HOME/tmp}
  : ${PKG:=$TMP/pkg}
  export TMP
  export PKG

  if [[ -n "$TRAVIS" ]]; then
    [[ ! -d "$TMP" ]] && mkdir "$TMP"
    [[ ! -d "$PKG" ]] && mkdir "$PKG"
  else
    if [[ -z "$(type -t dart)" && ! $PATH =~ \/dart-sdk ]]; then
        export DART_SDK="$PKG/dart-sdk"
        # Updating PATH to include access to Dart bin.
        export PATH="$PATH:$DART_SDK/bin"
        export PATH="$PATH:$HOME/.pub-cache/bin"
    fi
  fi
fi

return 0
