#------------------
# The search path for function definitions
#------------------
fpath+="${0:h}"

#------------------
# Aliases
#------------------
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'
alias avll='aws-vault login -s'
alias avs='aws-vault server'

# aliases for functions
alias avc='aws-vault-chrome'
alias avp='aws-vault-profile'

#------------------
# Functions
#------------------
function aws-vault-profile() {
  local aws_profile=${1:-$AWS_VAULT}
  if [[ -z "$1" ]]; then
    unset AWS_VAULT AWS_SDK_LOAD_CONFIG
    unset AWS_REGION AWS_DEFAULT_REGION
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE
    unset AWS_SESSION_EXPIRATION AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
    echo AWS Profile cleared.
    return
  else
    export AWS_SDK_LOAD_CONFIG=true
    export AWS_PROFILE=$aws_profile
    export AWS_DEFAULT_PROFILE=$aws_profile
    export AWS_EB_PROFILE=$aws_profile
    export $(aws-vault exec $aws_profile -- env | grep AWS)
    echo "Switched to AWS Profile: ${aws_profile}"
  fi
}

function aws-vault-chrome() {
  local aws_profile=${1:-$AWS_VAULT}

  if [[ -z "$aws_profile" ]]; then
    echo 'Please add an AWS Profile name e.g. avc <aws_profile>' >&2
    return 1
  fi

  aws_status=$?
  url=$(aws-vault login $aws_profile --stdout)
  profile_dir_name=${aws_profile//[^a-zA-Z0-9_-]/__}
  user_data_dir=$(mktemp -d /tmp/awschrome_userdata.XXXXXXXX)
  extension_dir="${HOME}/.aws/awschrome/extensions/i-dont-care-about-cookies"

  if [[ ${aws_status} -ne 0 ]]; then
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
