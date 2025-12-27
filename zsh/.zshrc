export LC_ALL="en_US.UTF-8"
export ZSH="$HOME/.oh-my-zsh"

plugins=(
	git 
	copyfile
	copybuffer
    	copypath
	dirhistory
	zsh-syntax-highlighting
   	zsh-autosuggestions
	history
)

source $ZSH/oh-my-zsh.sh

# My Config to disable auto complete on urls.
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

## Aliases
alias ls="eza --icons=always --color=always --git"

# AWS Config 
aws-login() {
	aws sso login --sso-session $1
}

aws-switch() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    export AWS_PROFILE=$1
}

# Kubernetes Config
alias k="kubectl"

aws-switchk(){
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
export AWS_PROFILE=$1
kubectx $1
}

###### Config and Functions from Anuj ###########

helper() {
    if [[ $1 == '-h' || $1 == '--help' ]]; then
        echo $2
        return 0
    fi
    return 1
}

aws-assume-role() {
helper $1 "Assume AWS role\n Usage: aws-assume-role <aws-role-arn> <role-session-name>"
    if [ $? -ne 0 ]; then
        OUT=$(aws sts assume-role --role-arn $1 --role-session-name $2);\
        export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials''.AccessKeyId');\
        export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials''.SecretAccessKey');\
        export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials''.SessionToken');
    fi
}

# Starship Prompt
eval "$(starship init zsh)"

# Mise 
eval "$(mise activate)"
