#These commands will pull the SecretString from AWS Secrets Manager
#For example storing a secret named test/posh with keys of:
#username with a value of batman
#password with a value of passwordisasentance
#This is two seaprate key/value pairs in a single AWS Secrets Manager resource
#
#Assumes the user configured to use aws cli has been granted at least read to the arn of the secret

#Gets key using aws cli and stores in $PoshResponse which is converted from JSON using ConvertFrom-Json cmdlet
$PoshResponse = aws secretsmanager get-secret-value --secret-id test/posh | ConvertFrom-Json

#Reads the SecretString which is still stored as JSON. See Expected results section below
$Creds = $PoshResponse.SecretString | ConvertFrom-Json

#If you need the password in secrure string format to support certain PowerShell cmdlets, you can convert the password into the correct format.
$SecStrngPW = ConvertTo-SecureString -String $($Creds.password) -AsPlainText -Force

#Expected results
# PS C:\> $Creds
#username password           
#-------- --------           
#batman   passwordisasentance
#
# PS C:\> $Creds.username
#batman
#
# PS C:\> $creds.password
#passwordisasentance
#
#Example AWS Policy, though I believe DescribeSecret can be removed
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "VisualEditor0",
#            "Effect": "Allow",
#            "Action": [
#                "secretsmanager:GetSecretValue",
#                "secretsmanager:DescribeSecret"
#            ],
#            "Resource": "arn:aws:secretsmanager:us-west-2:847548833:secret:test/posh-75WJ57"
#        }
#    ]
#}


