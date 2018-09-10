#This line will prompt the person logged in for a string and encrypt it. 
#Encryption is based on the user and computer account, thus cannot be decrypted on another computer.
#Assumes directory named scripts is available on the C drive

read-host -assecurestring | convertfrom-securestring | out-file c:\scripts\vault.txt
