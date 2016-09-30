#requires -Version 2
Set-StrictMode -Version 'Latest'

<#
        .SYNOPSIS
        Get the TFS User recordd from the User Display Name or Account Name
	
        .DESCRIPTION
        Get the TFS User records from the Display Name or the Account Name. 
        The Default TFS Service Account are replaced by CM default.
	
        .PARAMETER  TFS	
        The TFS project collection Object.
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
		
        .PARAMETER  Users
        Optionally use the Hashtable from a previous call to add user to it.
        If not supplyed a new one is created.
	
        .PARAMETER  UserId
        The User Display Name or Account Name
			
        .Parameter RequestedFor
        The user Requested for, from Build Detail.
			
        .Parameter RequestedBy
        The user Requested By, from Build Detail.

        .Parameter Requests
        The user Requests information array, from Build Detail.
	
        .EXAMPLE
        PS C:\> Get-TFSUsers -TFSCollection $TFSCollection -UserId 'userId','User, Display'
	
        .EXAMPLE
        PS C:\> $builds | Get-TFSUsers -TFSCollection $TFSCollection -Users $PreviouslyRequestedUsers
	

#>
function Get-TFSUsers 
{
    [CmdletBinding()]
    Param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [Alias('TFS')]
        $TFSCollection,
        [Hashtable]
        $Users,
        [string[]]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        #[ValidateNotNullOrEmpty()]
        [Alias('OwnerName','CheckedInBy','AssignedTo','Owner')]
        $UserId,
        [string[]]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        #[ValidateNotNullOrEmpty()]
        [Alias('CommiterDisplayName')]
        $RequestedFor,
        [string[]]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        #[ValidateNotNullOrEmpty()]
        [Alias('OwnerDisplayName')]
        $RequestedBy,
        [System.Array]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $Requests,
        [pscustomobject]
        $ServiceAccountDefault = ([pscustomobject]@{
                DisplayName = 'Service Account'
                UniqueName  = 'Service Account'
                IsService   = $true
                IsActive    = $true
        } | Add-ObjectTypeDetails -TypeName 'TFS.User' -DefaultProperties 'IsActive', 'DisplayName', 'UniqueName' ),
        [string]
        $ServiceAccountMatch #= 'service\saccount'
    )

    BEGIN
    {
        if (!$Users)
        {
            Write-Verbose 'Create a new User Hastable'
            $Users = @{}
        }
        if ($ServiceAccountDefault)   
        {
            Write-Verbose 'Assign the default Service User'
            $Users['Service'] = $ServiceAccountDefault
        }
        $newid = @()
        function AssignUser
        {
            param([hashtable]$Users, [string[]] $Ids, $Identities)
            for ($i = 0; $i -lt $Ids.Count; $i++) 
            {
                $id = $Ids[$i]
                $rec = $Identities[$i][0]
                if ($null -eq $rec)
                {
                    Write-Verbose "User has not been found: [$id]"
                    $rec = [pscustomobject]@{
                        DisplayName = "Deleted User [$id]"
                        UniqueName  = "$id"
                        IsActive    = $false
                    }
                }
                $Users["$id"] = $rec | Add-ObjectTypeDetails -TypeName 'TFS.User' -DefaultProperties 'IsActive', 'DisplayName', 'UniqueName' 
            }
        }
    }
    PROCESS 
    {
            
        $newid += $UserId
        $newid += $RequestedBy
        $newid += $RequestedFor
        if ($null -ne $Requests)
        {
            $newid += $Requests.RequestedBy
            $newid += $Requests.RequestedFor
        }
        
    }
    END {
        $newid = $newid |
        Select-Object -Unique |
        Where-Object -FilterScript {
            ![string]::IsNullOrEmpty($_) -and !$Users.ContainsKey($_)
        }

        if ("$ServiceAccountMatch" -ne '' -and $ServiceAccountDefault)
        {
            $newid |
            Where-Object -FilterScript {
                $_ -match $ServiceAccountMatch
            } |
            ForEach-Object -Process {
                $Users[$_] = $ServiceAccountDefault
            }
        }
        # get the User Account ID (not display name including , )
        $uid = [Array]($newid | Where-Object -FilterScript {
                !$Users.ContainsKey($_) -and $_ -notmatch ',\s'
        })
        if ($uid -is [system.Array] -and $uid.Count -gt 0) 
        {
            Write-Verbose "Read TFS Identities for AccountName: [$uid]"
            $found = $TFSCollection.IMS.ReadIdentities(
                [Microsoft.TeamFoundation.Framework.Common.IdentitySearchFactor]::AccountName,
                $uid,
                [Microsoft.TeamFoundation.Framework.Common.MembershipQuery]::None,
            [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::IncludeReadFromSource) 
            AssignUser -Users $Users -Ids $uid -Identities $found
        }
        $uid = [Array]($newid | Where-Object -FilterScript {
                !$Users.ContainsKey($_) -and $_ -match ',\s'
        })
        # get the user by Account name (no ', ')
        if ($uid -is [system.Array] -and $uid.Count -gt 0) 
        {
            Write-Verbose "Read TFS Identities for DisplayName: [$uid]"
            $found = $TFSCollection.IMS.ReadIdentities(
                [Microsoft.TeamFoundation.Framework.Common.IdentitySearchFactor]::DisplayName,
                $uid,
                [Microsoft.TeamFoundation.Framework.Common.MembershipQuery]::None,
            [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::IncludeReadFromSource) 
            AssignUser -Users $Users -Ids $uid -Identities $found
        }
        
		
        $Users
    }
}


