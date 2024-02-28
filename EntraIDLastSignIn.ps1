<#

.SYNOPSIS

    Script extracts last sign in for all or specific users.

 

.DESCRIPTION

    This script uses Microsoft Graph to extract attributes lastSignInDateTime,lastNonInteractiveSignInDateTime and LastSuccessfulSignInDateTime.

    The exraction can be of all on-prem synced enabled users or specific user list with UPN.

    Functions in this script are mainly used to display menu to help with exporting of data.

   

.NOTES

    Userful links:

    Different types of last login in Entra ID -> https://learn.microsoft.com/en-us/graph/api/resources/signinactivity?view=graph-rest-beta

   

 

.Required

    Entra ID P1 or P2

 

    Powershell Modules:

    Microsoft.Graph.Users

    Microsoft.Graph.Beta.Users

    Microsoft.Graph.Authentication

   

    Microsoft Garph application needs AuditLog.Read.All and Directory.Read.All permissions on Entra ID tenant

 

    User executing the script needs atleast one of these Entra ID roles: Global reader, Security Reader or Report Reader


.Author

    Chetinder Pal Singh - ginnisingh139@gmail.com

#>

 

#Function to show Main menu

function Show-Menu

{

    param(

        [string]$Title = 'Fetch Last Login from Entra ID'

    )

    Write-Host "---------------- $Title ----------------"$nl

    Write-Host "0: Press '0' to get info"

    Write-Host "1: Press '1' to fetch data with Standard commands"

    Write-Host "2: Press '2' to fetch data with Beta commands"

    Write-Host "3: Press 'q' to quit"

}

 

#Function to show Sub menu

function Show-SubMenu

{

    param(

        [string]$Title1 = 'Fetching data with Standard commands'

    )

   

    Write-Host "---------------- $Title1 ----------------"$nl

    Write-Host "1: Press '1' to fetch last login for all users"

    Write-Host "2: Press '2' to fetch last login for specific users"

    Write-Host "3: Press 'q' to quit"

}

 

#Function to show Beta Sub menu

function Show-BetaSubMenu

{

    param(

        [string]$Title2 = 'Fetching data with Beta commands'

    )

   

    Write-Host "---------------- $Title2 ----------------"$nl

    Write-Host "1: Press '1' to fetch last login for all users"

    Write-Host "2: Press '2' to fetch last login for specific users"

    Write-Host "3: Press 'q' to quit"

}

 

#Function to show account info

function Show-accountinfo{

    param(

        [string]$Title3 = 'Account info'

    )

   

    Write-Host "---------------- $Title3 ----------------"$nl

    Write-Host "Account:" $check.Account

    Write-Host "Application:" $check.AppName

    Write-Host "Scopes:" $check.Scopes $nl

    Write-Host "Output will be saved to directory:" $DefaultPath -ForegroundColor Yellow -BackgroundColor Black

    Write-Host "Input will be fetched from:" $FetchPath -ForegroundColor Yellow -BackgroundColor Black

 

}

 

Clear-Host

 

#Use if execution policy restricts script from running

#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

 

$nl = $null

$Selection = $null

$DefaultPath = $null

$FetchPath = $null

$check = $null

$Org = $null

$requiredModules = $null

$recommendedModules = $null

 

$requiredModules = @("Microsoft.Graph.Users", "Microsoft.Graph.Beta.Users")

 

foreach ($module in $requiredModules) {

    if (-not (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {

        Write-Host "Required Powershell Graph Module not installed:" $module -BackgroundColor Black -ForegroundColor Red

    }

    else

    {

    #Write-Host "Importing Module.." $module

    Import-Module $module

    } 

}

 

$recommendedModules = @("Microsoft.Graph.Authentication")

 

foreach ($module in $recommendedModules) {

    if (-not (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {

        Write-Host "Recommended Powershell Graph Module not installed:" $module -BackgroundColor Black -ForegroundColor Yellow

    }

    else

    {

    #Write-Host "Importing Module.." $module

    Import-Module $module

    } 

}

 

$nl = [Environment]::NewLine

$DateTime = Get-Date -uformat "%Y.%m.%d-%H%M"

$DefaultPath = "C:\Temp\"

$FetchPath = $DefaultPath + "input.txt"

 

#check if user is already connect to Microsoft Graph

if(!($check)){

Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All" -NoWelcome

$check = Get-MgContext -ErrorAction SilentlyContinue

}

 

Write-Host "Output will be saved to directory:" $DefaultPath -ForegroundColor Yellow -BackgroundColor Black

Write-Host "Input will be fetched from:" $FetchPath -ForegroundColor Yellow -BackgroundColor Black

 

#While loop continues until user input is not 'q'

while($Selection -notmatch 'Q'){

    $nl

 

    #Show the main menu

    Show-Menu

 

    #Read input from user

    $Selection = Read-Host "Please select an option"

 

    switch($Selection){

 

   

    '0'{

        Clear-Host

 

        #Shows logged account info

        Show-accountinfo

    }

 

   

    '1'{

       

        $Select = $null

 

        Write-Host "You selected to fetch data using Standard commands" -ForegroundColor Cyan -BackgroundColor Black

       

        while($Select -notmatch 'Q'){

           

            #Shows Sub Menu for standard commands

            Show-SubMenu

 

            $Select = Read-Host "Please select an option"

 

            switch($Select){

 

                '1'{

                    $FilePath = $null

                    $List = $null

                    $u = $null

                    $c = 0

       

                    $FilePath = $DefaultPath + "All_Users_"+$DateTime+".csv"

 

                    Clear-Host

 

                    Write-Host "You selected to fetch last login for all users using standard commands" -ForegroundColor Cyan -BackgroundColor Black

 

                    #Fetching data from Microsoft Graph

                    Write-Host "Fetching data from Microsoft Graph API..." -ForegroundColor Yellow

                    $List = Get-MgUser -Filter "onPremisesSyncEnabled eq true and AccountEnabled eq true" -Property "UserPrincipalName,signInActivity" | select UserPrincipalName,signInActivity -ErrorAction SilentlyContinue

                    Write-Host "Finished fetching data from Microsoft Graph API." -ForegroundColor Green

 

                    #Saving data to destination folder

                    Write-Host "Saving data to destination folder..." -ForegroundColor Yellow

                    foreach($u in $List){

   

                        $C++

                        Write-Progress -Activity "Saving.." -Status "Querying $($C) OF $($list.count) - User: $($u.UserPrincipalName)" -PercentComplete (($C/$list.Count) * 100)

 

                        #Exclude users from *.onmicrosoft.com domain from list

                        if(!(($u.UserPrincipalName).Contains("onmicrosoft.com"))){

 

                            $Table = $null

                            $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime"

 

                            $Table.UserPrincipalName = $u.UserPrincipalName

                            $Table.lastSignInDateTime = $u.SignInActivity.LastSignInDateTime

                            $Table.lastNonInteractiveSignInDateTime = $u.SignInActivity.LastNonInteractiveSignInDateTime

 

                            $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

 

                            }

                        }

 

                    Write-Progress -Completed -Activity "Closing..."

                    Write-Host "Output destination path" $FilePath -ForegroundColor Green -BackgroundColor Black

                    }

 

                '2'{

 

                    $FilePath = $null

                    $List = $null

                    $User = $null

                    $c = 0

 

                    $FilePath = $DefaultPath + "Specific_Users_"+$DateTime+".csv"

                   

                    Clear-Host

 

                    Write-Host "You selected to fetch last login for specific users using standard commands" -ForegroundColor Cyan -BackgroundColor Black

 

                    Write-Host "Trying to get specific user list from file" $FetchPath -ForegroundColor Yellow

 

                    if(Test-Path -Path $FetchPath){

 

                        $List = Get-Content -Path $FetchPath

 

                        if(($List).count -gt 0){

                           

                            foreach($user in $List){

                               

                                $u = $null

                                $utente = $null

                                $C++

                                Write-Progress -Activity "Fetching data.." -Status "Querying $($C) OF $($list.count) - User: $($user)" -PercentComplete (($C/$list.Count) * 100)

                               

                                try{

                                    $u = Get-MgBetaUser -UserId (Get-MgBetaUser -UserId $user -Property "Id" -ErrorAction Stop).Id -Property "UserPrincipalName,signInActivity" | select UserPrincipalName,signInActivity -ErrorAction Stop

                                   

                                    $Table = $null

                                    $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime"

 

                                    $Table.UserPrincipalName = $user

                                    $Table.lastSignInDateTime = $u.SignInActivity.LastSignInDateTime

                                    $Table.lastNonInteractiveSignInDateTime = $u.SignInActivity.LastNonInteractiveSignInDateTime

 

                                    $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

                                    }

                                catch{

                                    Write-Host "Some issue occur when fetching data for user:" $user -ForegroundColor Red -BackgroundColor Black

 

                                    $Table = $null

                                    $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime"

 

                                    $Table.UserPrincipalName = $user

                                    $Table.lastSignInDateTime = "N/A"

                                    $Table.lastNonInteractiveSignInDateTime = "N/A"

 

                                    $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

                                }

 

                            }

                               

                                Write-Progress -Completed -Activity "Closing..."

                                Write-Host "Output destination path" $FilePath -ForegroundColor Green -BackgroundColor Black

                        }

                    }

                    else{

                        Write-Host "File not found please create file input.txt under path" $DefaultPath -ForegroundColor Yellow -BackgroundColor Black

                    }

 

                    }

               

                }

 

            }

        }

 

    '2'{

 

        $Select = $null

        Write-Host "You selected to fetch data using Beta commands" -ForegroundColor Cyan -BackgroundColor Black

       

        while($Select -notmatch 'Q'){

           

            Show-BetaSubMenu

 

            $Select = Read-Host "Please select an option"

 

            switch($Select){

                   

                '1'{

                    $FilePath = $null

                    $List = $null

                    $u = $null

                    $c = 0

 

                    $FilePath = $DefaultPath + "B_All_Users_"+$DateTime+".csv"

 

                    Clear-Host

 

                    Write-Host "You selected to fetch last login for all users using beta commands" -ForegroundColor Cyan -BackgroundColor Black

 

                    #Fetching data from Microsoft Graph

                    Write-Host "Fetching data from Microsoft Graph API..." -ForegroundColor Yellow

                    $List = Get-MgBetaUser -Filter "onPremisesSyncEnabled eq true and AccountEnabled eq true" -Property "UserPrincipalName,signInActivity" | select UserPrincipalName,signInActivity -ErrorAction SilentlyContinue

                    Write-Host "Finished fetching data from Microsoft Graph API." -ForegroundColor Green

 

                    #Saving data to destination folder

                    Write-Host "Saving data to destination folder..." -ForegroundColor Yellow

                    foreach($u in $List){

   

                        $C++

                        Write-Progress -Activity "Saving.." -Status "Querying $($C) OF $($List.count) - User: $($u.UserPrincipalName)" -PercentComplete (($C/$List.Count) * 100)

 

                        #Exclude users from *.onmicrosoft.com domain from list

                        if(!(($u.UserPrincipalName).Contains("onmicrosoft.com"))){

 

                            $Table = $null

                            $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime","LastSuccessfulSignInDateTime"

 

                            $Table.UserPrincipalName = $u.UserPrincipalName

                            $Table.lastSignInDateTime = $u.SignInActivity.LastSignInDateTime

                            $Table.lastNonInteractiveSignInDateTime = $u.SignInActivity.LastNonInteractiveSignInDateTime

                            $Table.LastSuccessfulSignInDateTime = $u.SignInActivity.LastSuccessfulSignInDateTime

 

                            $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

               

                            }

                        }

 

                        Write-Progress -Completed -Activity "Closing..."

                        Write-Host "Output destination path" $FilePath -ForegroundColor Green -BackgroundColor Black

                    }

           

                '2'{

 

                    $FilePath = $null

                    $List = $null

                    $User = $null

                    $c = 0

 

                    $FilePath = $DefaultPath + "B_Specific_Users_"+$DateTime+".csv"

                   

                    Clear-Host

                   

                    Write-Host "You selected to fetch last login for specific users using beta commands" -ForegroundColor Cyan -BackgroundColor Black

 

                    Write-Host "Trying to get specific user list from file" $FetchPath -ForegroundColor Yellow

 

                    if(Test-Path -Path $FetchPath){

 

                        $List = Get-Content -Path $FetchPath

 

                        if(($List).count -gt 0){

                           

                            foreach($user in $List){

                               

                                $u = $null

 

                                $C++

                                Write-Progress -Activity "Fetching data.." -Status "Querying $($C) OF $($list.count) - User: $($user)" -PercentComplete (($C/$list.Count) * 100)

                               

                                try{

                                    $u = Get-MgBetaUser -UserId (Get-MgBetaUser -UserId $user -Property "Id" -ErrorAction Stop).Id -Property "UserPrincipalName,signInActivity" | select UserPrincipalName,signInActivity -ErrorAction Stop

                                   

                                    $Table = $null

                                    $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime","LastSuccessfulSignInDateTime"

 

                                    $Table.UserPrincipalName = $user

                                    $Table.lastSignInDateTime = $u.SignInActivity.LastSignInDateTime

                                    $Table.lastNonInteractiveSignInDateTime = $u.SignInActivity.LastNonInteractiveSignInDateTime

                                    $Table.LastSuccessfulSignInDateTime = $u.SignInActivity.LastSuccessfulSignInDateTime

 

                                    $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

                                }

                                catch{

                                    Write-Host "Some issue occur when fetching data for user:" $user -ForegroundColor Red -BackgroundColor Black

 

                                    $Table = $null

                                    $Table = "" | select "UserPrincipalName","lastSignInDateTime","lastNonInteractiveSignInDateTime","LastSuccessfulSignInDateTime"

 

                                    $Table.UserPrincipalName = $user

                                    $Table.lastSignInDateTime = "N/A"

                                    $Table.lastNonInteractiveSignInDateTime = "N/A"

                                    $Table.LastSuccessfulSignInDateTime = "N/A"

 

                                    $Table | Export-Csv -Path $FilePath -Append -NoTypeInformation

                                }

 

                            }

                               

                                Write-Progress -Completed -Activity "Closing..."

                                Write-Host "Output destination path" $FilePath -ForegroundColor Green -BackgroundColor Black

                        }

                    }

                    else{

                        Write-Host "File not found please create file input.txt under path" $DefaultPath -ForegroundColor Yellow -BackgroundColor Black

                    }

 

                    }

                }

            }

         }

    }

 

}

 

if($check){

Disconnect-MgGraph

}