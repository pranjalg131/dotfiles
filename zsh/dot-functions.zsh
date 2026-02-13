# Functions

helper() {
    if [[ $1 == '-h' || $1 == '--help' ]]; then
        echo $2
        return 0
    fi
    return 1
}

aws-switch() {
helper $1 "Switch AWS profile\n Usage: aws-switch <aws-profile-name>"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    export AWS_PROFILE=$1
}

aws-switchk(){
helper $1 "Switch AWS profile and kubectl context\n Usage: aws-switchk <aws-profile-name>"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    export AWS_PROFILE=$1
    kubectx $1
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