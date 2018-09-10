#This line will write a message to the file specified in Out-File in syslog format
#Variable #BackupLogs must be set before using e.g. Set-Variable -name BackupLogs -value c:\scripts\backup\logs.txt

"$(Get-Date -Format "yyyy:MM:dd:-HH:mm:ss zzz") End log backup and moved to S3" | Out-File $BackupLogs -Append
