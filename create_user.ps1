#########################################
#-> Auteur: Alexandre Chammbelland      #
#-> Date: 11.07.2020                    #
#-> Version: 1.0                        #
#########################################

function check_username
{
    $username = Read-Host "Nom d'utilisateur"
    if ($username -eq ""){
        Write-Host "Username non conforme"
        check_username
    }
    else {
        return $username
    }
}


function check_password
{
    $password = Read-Host "Mot de passe"
    if ($password -eq "" -or $password.Length -lt 4){
        Write-Host "Mot de passe non conforme"
        check_password
    }
    else {
        return $password | ConvertTo-SecureString -AsPlainText -Force
    }    
}


function check_group
{
    $group = Read-Host "Groupe utilisateur :`n[1]- User`n[2]- Admin"
    if ($group -eq "1"){
        return $false
    }
    elseif ($group -eq "2"){
        return $true
    }
    else{
        Write-Host "Saisie incorrecte"
        check_group
    }
}


function create_user($param)
{
    try {
        Write-Host "`n-> Création du compte en cours..." -ForegroundColor Cyan
        sleep(2)
        New-LocalUser $param[0] -Password $param[1]
        Write-Host "====> Création du compte réussie !`n---------------------------------" -ForegroundColor Green
        if ($param[2] -eq $true) {
            Write-Host "`n-> Ajout des droits admins en cours...`n" -ForegroundColor Cyan
            sleep(2)
            Add-LocalGroupMember -Group "Administrateurs" -Member $param[0]
            Write-Host "====> Droits admins ajoutés !`n---------------------------------`n" -ForegroundColor Green
        }
    }
    catch {Write-Host "====> Erreur lors de la création du compte !" -ForegroundColor Red}
}

Write-Host "##################################`nScript de création d'utilisateur`n##################################`n`n=> Vous pouvez créer des utilisateurs Administrateurs ou non via ce script`n" -ForegroundColor Cyan
$username = check_username
$password = check_password
$admin = check_group
write-host "`nLe compte suivant va être crée :`n---------------------------------`nUsername :"$username "`nDroits Admins :"$admin "`nCTRL+C pour Annuler`n---------------------------------" -ForegroundColor cyan
sleep(5)
create_user($username, $password, $admin)
PAUSE
