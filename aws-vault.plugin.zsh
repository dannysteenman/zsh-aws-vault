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
    aws-vault clear $aws_profile
    unset $(env | grep -o '^AWS[^=]*')
    return
  elif [[ "$AWS_PROFILE" ]]; then
    echo "Switch from AWS Profile: $AWS_PROFILE to $aws_profile"
    aws-vault clear $AWS_PROFILE
    unset $(env | grep -o '^AWS[^=]*')
    export AWS_SDK_LOAD_CONFIG=true
    export AWS_PROFILE=$aws_profile
    export AWS_DEFAULT_PROFILE=$aws_profile
    export AWS_EB_PROFILE=$aws_profile
    export $(aws-vault exec $aws_profile -- env | grep AWS)
    return
  else
    echo "Switch to AWS Profile: ${aws_profile}"
    export AWS_SDK_LOAD_CONFIG=true
    export AWS_PROFILE=$aws_profile
    export AWS_DEFAULT_PROFILE=$aws_profile
    export AWS_EB_PROFILE=$aws_profile
    export $(aws-vault exec $aws_profile -- env | grep AWS)
  fi
}

function aws-vault-chrome() {
  local aws_profile=${1:-$AWS_VAULT}
  local login_url

  if [[ -z "$aws_profile" ]]; then
    echo 'Please add an AWS Profile name e.g. avc <aws_profile>' >&2
    return 1
  fi

  login_url=$(aws-vault login $aws_profile --stdout)

  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --no-default-browser-check \
    --no-first-run \
    --new-window \
    --disk-cache-dir=$(mktemp -d /tmp/chrome.XXXXXXXX) \
    --user-data-dir=$(mktemp -d /tmp/chrome.XXXXXXXX) \
    --disable-extensions-except=$(fd -td i-dont-care-about-cookies $HOME -H --max-depth 4) \
    ${login_url} \
    >/dev/null 2>&1 &
}
