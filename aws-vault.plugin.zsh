#------------------
# Aliases
#------------------
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'
alias avll='aws-vault login -s'
alias avs='aws-vault server'
alias avc='aws-vault-chrome'
alias avp='aws-vault-profile'

#------------------
# Functions
#------------------
function aws-vault-profile() {
  if [[ -z "$1" ]]; then
    unset AWS_SDK_LOAD_CONFIG
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SESSION_EXPIRATION
    echo AWS Profile cleared.
    return
  fi

  export AWS_SDK_LOAD_CONFIG=true
  export AWS_DEFAULT_PROFILE=$1
  export AWS_PROFILE=$1
  export AWS_EB_PROFILE=$1

  creds=$(mktemp -d)/creds.json
  aws-vault exec ${AWS_PROFILE} -- env | grep AWS >$creds
  export AWS_ACCESS_KEY_ID=$(cat ${creds} | grep "AWS_ACCESS_KEY_ID" | cut -d '=' -f 2)
  export AWS_SECRET_ACCESS_KEY=$(cat ${creds} | grep "AWS_SECRET_ACCESS_KEY" | cut -d '=' -f 2)
  export AWS_SESSION_TOKEN=$(cat ${creds} | grep "AWS_SESSION_TOKEN" | cut -d '=' -f 2)
  export AWS_SESSION_EXPIRATION=$(cat ${creds} | grep "AWS_SESSION_EXPIRATION" | cut -d '=' -f 2)
  echo "Switched to AWS Profile: ${AWS_PROFILE}"
}

function aws-vault-chrome() {
  # set to yes to create one-time use profiles in /tmp
  # anything else will create them in $HOME/.aws/awschrome
  TEMP_PROFILE="yes"

  aws_profile="$1"
  if [[ -z "$aws_profile" ]]; then
    echo "aws_profile is a required argument" >&2
    return 1
  fi

  # replace non word and not - with __
  profile_dir_name=${aws_profile//[^a-zA-Z0-9_-]/__}
  user_data_dir="${HOME}/.aws/awschrome/${profile_dir_name}"
  extension_dir="~/.aws/awschrome/extensions/i-dont-care-about-cookies"

  if [[ "$TEMP_PROFILE" = "yes" ]]; then
    user_data_dir=$(mktemp -d /tmp/awschrome_userdata.XXXXXXXX)
  fi

  url=$(aws-vault login $aws_profile --stdout)
  aws_status=$?

  if [[ ${aws_status} -ne 0 ]]; then
    # zsh will also capture stderr, so echo $url
    echo ${url}
    return ${aws_status}
  fi

  mkdir -p ${user_data_dir}
  disk_cache_dir=$(mktemp -d /tmp/awschrome_cache.XXXXXXXX)
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --disable-background-networking \
    --disable-breakpad \
    --disable-default-apps \
    --disable-domain-reliability \
    --disable-extensions-except=${extension_dir} \
    --disable-notifications \
    --disable-sync \
    --new-window \
    --no-default-browser-check \
    --no-first-run \
    --user-data-dir=${user_data_dir} \
    --disk-cache-dir=${disk_cache_dir} \
    ${url} \
    >/dev/null 2>&1 &
}
