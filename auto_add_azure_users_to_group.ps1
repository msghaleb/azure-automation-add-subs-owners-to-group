$groupID = "PAST HERE THE GROUP ID"
$azureCredential = Get-AutomationPSCredential -Name "HERE THE NAME OF THE USER"

if($azureCredential -ne $null)
{
	Write-Output "Attempting to authenticate as: [$($azureCredential.UserName)]"
}
else
{
   throw "No automation credential name was specified..."
}

Connect-MsolService -Credential $azureCredential
Login-AzureRmAccount -Credential $azureCredential 
Connect-AzureAD -Credential $azureCredential

$subs = Get-AzureRmSubscription

foreach($sub in $subs)
{
    $subID = $sub.SubscriptionId
    Select-AzureRmSubscription -SubscriptionId $subID
    $substring = "/subscriptions/" + $subID
    $usersList = (Get-AzureRmRoleAssignment -IncludeClassicAdministrators -scope $substring)
    
    foreach($user in $usersList){
       # here we get all the groups the user is member of
       if(($user.ObjectType -eq "User") -and ($user.ObjectId -ne "00000000-0000-0000-0000-000000000000"))
       {
            $userGroups = Get-AzureADUserMembership -ObjectId $user.ObjectID
       }
       # here we add only users and only if they are not already members
       if(($user.ObjectType -eq "User") -and ($user.SignInName -ne "HERE THE USERNAME") -and ($userGroups.ObjectID -notcontains $groupID) -and ($user.ObjectID -ne "00000000-0000-0000-0000-000000000000"))
        {
            $userID = $user.objectID
            Add-AzureADGroupMember -ObjectId $groupID -RefObjectId $userID
       }
    }
}