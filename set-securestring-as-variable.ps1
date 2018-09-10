#This will read a secure string created with prompt-for-securestring.ps1
#For example, if a user has encrypted a password needed to run a script, you can read the results of vault.txt
#Now you do not need to store the password in the script, or other plain text readable file

#variable $password is set by reading the value of vault.txt

$password = get-content C:\scripts\vault.txt | ConvertTo-SecureString

#PowerShell credentials set by supplying a username and using the the $password variable.
#Similarly, username could be stored as an encrypted value and read into the script and referenced as $username

$creds = New-Object System.Management.Automation.PSCredential -ArgumentList username, $password
