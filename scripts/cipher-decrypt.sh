echo $1 | openssl enc -aes-256-cbc -md sha512 --pbkdf2 -a -d -salt -pass pass:$__CIPHER_KEY__
