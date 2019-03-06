[CmdletBinding()] 
Param (

[Parameter(Mandatory=$False)] 
$Afile = "./",  

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Branch = "master", 

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Sshuser = "sshuser", 

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Rhost = "10.11.22.33" ,

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Project = "project" ,

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Syncuser = "syncuser",  

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Transpath = "/home/syncuser/deploy", 

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Rproject = "project" ,

[Parameter(Mandatory=$False)] 
[ValidateNotNullOrEmpty()] 
[string] $Gitrepo = "https://github.com/shiqstone/utils.git" 
) 

$psboundparameters.keys | ForEach { 
    Write-Output "($_)=($($PSBoundParameters.$_))" 
}

[string]$largs=$Afile


if(Test-Path $Project){
	cd $Project
	if($Branch -ne "master"){
		git checkout $Branch
	}
	git pull
	cd ..
}else{
	git clone $Gitrepo $Project
	if($Branch -ne "master"){
		cd $Project
		git checkout $Branch
		cd ..
	}
}

ssh -t $Sshuser@$Rhost `"sudo chown -R $Sshuser:$Sshuser $Transpath/$Rproject`"

if($Afile.Count -gt 0){
	cd collection
	foreach($file in $Afile){
		echo "scp -r $file $Sshuser@$Rhost:/$Transpath/$Rproject/$file"
		scp -r $file $Sshuser@$Rhost:$Transpath/$Rproject/$file
	}
	cd ..
}else{
	#echo "scp -r .\collection\ $Sshuser@$Rhost:$Transpath/"
	scp -r .\collection\ $Sshuser@$Rhost:$Transpath/
}
#exit

$rsucmd=" cd $Transpath; ./deploy_beta.sh $largs; "
#echo $rsucmd
$rcmd="sudo chown -R Syncuser:Syncuser $Transpath/$Rproject; sudo su Syncuser -c `\`"$rsucmd`\`""
#echo $rcmd
echo "ssh -t $Sshuser@$Rhost `"$rcmd`""

ssh -t $Sshuser@$Rhost `"$rcmd`"

