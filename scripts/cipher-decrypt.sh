echo $1 | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:$2
