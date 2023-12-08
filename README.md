# scripts

### whattimeis 
Display specified time (optionally specified time in specific timezone) in other timezones. 

usage: `whatimeis 9pm Asia/Seoul`

### sw
Stopwatch on the cmdline 

### rclone-backup
Backups a directory and encrypts it to an rclone remote.

#### Environment Variables
DIRECTORY_TO_ARCHIVE=<full path to directory to backup>
REMOTE_NAME=<remote service to use e.g. gdrive>
REMOTE_PATH=<remote path to use>
CCENCRYPT_PASS=<passphrase to encrypt archive with>
