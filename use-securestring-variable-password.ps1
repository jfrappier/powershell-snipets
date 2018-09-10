#When storing a password as secure string, and reading into a variable to be used as a PSCredential
#Credetnails here were stored in a variable called $creds. See set-securestring-as-variable.ps1

#Adjust login format to the tool/utilities necessary format
login --username $creds.UserName --password $creds.GetNetworkCredential().Password
