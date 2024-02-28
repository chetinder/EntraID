# EntraID
Find inactive accounts in Entra ID for synced users in a managed domain.
This script uses Microsoft Graph to extract attributes lastSignInDateTime,lastNonInteractiveSignInDateTime and LastSuccessfulSignInDateTime.
The exraction can be of all on-prem synced enabled users or specific user list containing UPN.
Functions in this script are mainly used to display menu to help with exporting of data.

REQUIRED
Entra ID P1 or P2 ;
Powershell Modules:
    Microsoft.Graph.Users
    Microsoft.Graph.Beta.Users

Recommended
    Powershell Modules:
    Microsoft.Graph.Authentication
    
Microsoft Garph application needs AuditLog.Read.All and Directory.Read.All permissions on Entra ID tenant

User executing the script needs atleast one of these Entra ID roles: Global reader, Security Reader or Report Reader
  
Useful links:
https://learn.microsoft.com/en-us/graph/api/resources/signinactivity?view=graph-rest-beta
