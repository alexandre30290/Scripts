<#

Ce script permet de mettre en place un homedirectory pour tous les utilisateurs d'une OU définie dans la variable $Scope. Ce script scanne tous les utilisateurs de cette OU et leur crée un homedirectory s'ils en ont pas déja un avec les droits adéquats. Il vous faudra simplement modifier les chemins et variables pour l'adapter à votre infrastructure et vos besoins.

Je réponds à vos questions à alexandre@famillechambelland.fr

#>

#Check de la présence du dossier racine sinon on le créer
$FolderShare = Test-Path "C:\sharedhome"
if ($FolderShares -eq $false) {
	New-Item -Path "C:\sharedhome" -ItemType Directory
}

#Variables
$Scope = "OU=Utilisateurs,DC=poc,DC=local"
$Letter = "X"
$allUsers = Get-ADUser -SearchBase "$($Scope)" -Filter *

#Pour chaque utilisateur
foreach($user in $allUsers) {
	
	#Recupere le SamAccountName de l'user
	$samAccountName = $user.SamAccountName
	
	#Emplacement reseau
	$homeDirectory = "\\srv-ad\$($samAccountName)$"
	
	#localisation sur le serveur
	$localFolder = "C:\sharedhome\$($samAccountName)"
	
	#On récupere l'objet utilisateur
	$user = Get-ADUser -Identity $user -Properties *
	
	#Verifie la presence du dossier personnel
	$testPath = Test-Path $homeDirectory
	
	#On le crée si non existant
	if (($user.HomeDirectory -eq $null) -or ($testPath -eq $false)) {
		New-Item -Path $localFolder -ItemType Directory
		New-SmbShare -Name "$($samAccountName)$" -Path $localFolder -FullAccess "Administrateurs"
		Set-ADUser $user -HomeDrive $letter -HomeDirectory $homeDirectory -ea stop
		Grant-SmbShareAccess -Name "$($samAccountName)$" -AccountName "POC\$($samAccountName)" -AccessRight Change -Force
		Write-Host ("HomeDirectory crée pour$samAccountName ici : $homeDirectory!") -ForegroundColor Green
	}
	else {
		Write-Host "Possede deja un HomeDirectory pour $samAccountName" -ForegroundColor Red
	}
}
