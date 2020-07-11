<# 

Ce script permet de mettre en place des profils itinérants pour tous les utilisateurs d'une OU  définie dans la variable $Scope. Il scan tous les utilisateurs pour voir s'ils ont déja un profil itinérant et si ce n'est pas le cas, il en crée un avec le droits adéquats et le mappe à son profil. Les variables et chemins sont à modifier selon vos besoin.

Je réponds à vos questions à alexandre@famillechambelland.fr  

#>



#Test si le dosser racine des profils itinérants existe sinon on le crée avec les bons droit
$FolderProfiles = Test-Path "C:\profiles"
if ($FolderProfiles -eq $false) {
	New-Item -Path "C:\profiles" -ItemType Directory
	New-SmbShare -Name "profiles$" -Path "C:\profiles" -FullAccess "Administrateurs"
	Grant-SmbShareAccess -Name "profiles$" -AccountName "Utilisateurs" -AccessRight Change -Force
}

#Variables
$Scope = "OU=Utilisateurs,DC=poc,DC=local"
$allUsers = Get-ADUser -SearchBase $scope -Filter* -Properties *

#Mapper le dossier itinérant pour chaque utilisateur
foreach ($user in $allUsers) {
	if ($user.ProfilePath -eq $null) {
		$samAccountName = $user.SamAccountName
		Set-ADUser -Identity $samAccountName -ProfilePath "\\srv-ad\profiles$\%username%"
	}
	else {
		"Profil itinerant existant"
	}
}
