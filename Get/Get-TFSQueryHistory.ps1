#requires -Version 2
<#
        .SYNOPSIS
        Get the TFS History for the Selected Folders.
	
        .DESCRIPTION
        Query TFS Version Control Server to get the history for the folders selected.
        By default the function return all the Changeset for the Folders excluding the TFS Build Agent Build Automated Check-in.
	
        .PARAMETER  TFSCollection 
        The TFS Collection Object to use for the Query. If not set, the Default one will be use.
	
        .PARAMETER  TfsFolders
        The TFS Folders to query the History for.

        .PARAMETER  User
        The user for whom history will be queried. 
        If the User is set, the IncludeBuildAgentCheckin is set automatically.
        Specify null for any user [default].
			
        .PARAMETER  IncludeChangesDetails
        A flag that describes whether the individual item changes will be included with the changesets. Otherwise, only changeset metadata is included.
			
			
        .PARAMETER  Recursion
        A flag describing whether history will be recursively queried.

        .PARAMETER  Version
        The version of the item for which history will be queried.
        Latest by default.
			
        .PARAMETER  VersionFrom
        The earliest version for which history will be queried. 
        Specify null to begin with the first changeset [default].
			
        .PARAMETER  VersionTo
        The latest version for which history will be queried. 
        Specify null to end with the latest changeset [default].
			
        .PARAMETER  ChangesetNo
        The Changeset No of the item for which history will be queried.
			
        .PARAMETER  ChangesetFrom
        The earliest Changeset No for which history will be queried. 
        Specify null to begin with the first changeset [default].
	
        .PARAMETER  ChangesetTo
        The Latest Changeset No for which history will be queried. 
        Specify null to end with the Latest changeset [default].
	
        .PARAMETER  DateFrom
        The earliest Date for which history will be queried. 
        The Date is coverted into a DateVersionSpec.
        Specify null to begin with the first changeset [default].
	
        .PARAMETER  DateTo
        The Latest Date for which history will be queried. 
        The Date is coverted into a DateVersionSpec.
        Specify null to end with the Latest changeset [default].
	
	
        .EXAMPLE
        PS C:\> Get-TfsHistory -TFSCollection $TFSCollection -TfsFolders '$/CM' -IncludeChangesDetails
	
        .EXAMPLE
        PS C:\> Get-TfsHistory -TFSCollection $TFSCollection -TfsFolders '$/CM' -IncludeChangesDetails
	
	
#>


function Get-TFSQueryHistory 
{
    [CmdletBinding(DefaultParameterSetName = 'Version')]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Position = 0,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [Microsoft.TeamFoundation.VersionControl.Client.ItemSpec]
        [Parameter(ParameterSetName = 'ItemSpec')]
        [Parameter(ValueFromPipeline = $true)]
        #[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $ItemSpec,
        [Microsoft.TeamFoundation.VersionControl.Client.QueryHistoryParameters]
        [Parameter(ParameterSetName = 'QueryHistoryParameter')]
        [Parameter(ValueFromPipeline = $true)]
        #[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $QueryHistoryParameter,
        [string[]]
        [Parameter(ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Changeset')]
        [Parameter(ParameterSetName = 'Date')]
        [ValidateNotNullOrEmpty()]
        $TfsFolders,
        [string]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Changeset')]
        [Parameter(ParameterSetName = 'Date')]
        $User,
        [switch]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Changeset')]
        [Parameter(ParameterSetName = 'Date')]
        $IncludeChangesDetails,
        [Microsoft.TeamFoundation.VersionControl.Client.RecursionType]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Changeset')]
        [Parameter(ParameterSetName = 'Date')]
        $Recursion = [Microsoft.TeamFoundation.VersionControl.Client.RecursionType]::Full,
        [Parameter(ParameterSetName = 'Version')]
        [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]
        $Version = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest,
        [Parameter(ParameterSetName = 'Version')]
        [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]
        $VersionFrom = $null,
        [Parameter(ParameterSetName = 'Version')]
        [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]
        $VersionTo = $null,
        [Parameter(ParameterSetName = 'Changeset')]
        [int32]
        $ChangesetNo,
        [Parameter(ParameterSetName = 'Changeset')]
        [int32]
        $ChangesetFrom,
        [Parameter(ParameterSetName = 'Changeset')]
        [int]
        $ChangesetTo,
        [Parameter(ParameterSetName = 'Date')]
        [DateTime]
        $DateFrom,
        [Parameter(ParameterSetName = 'Date')]
        [DateTime]
        $DateTo,
        [int32]
        [Parameter(ParameterSetName = 'Date')]
        [Parameter(ParameterSetName = 'Version')]
        [Parameter(ParameterSetName = 'Changeset')]
        [Parameter(ParameterSetName = 'ItemSpec')]
        $MaxCount
		
    )
    begin 
    {
        
        if (!$MaxCount)
        {
            $MaxCount = [int32]::MaxValue
        }
        switch ($PSCmdlet.ParameterSetName)
        {
            'Version'
            {
                break
            }
            'ChangeSet'
            {
                if ($ChangesetNo -gt 0)
                {
                    $Version = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::ParseSingleSpec("C$ChangesetNo", $null)
                }
                else
                {
                    $Version = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest
                }
                if ($ChangesetFrom -gt 0)
                {
                    $VersionFrom = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::ParseSingleSpec("C$ChangesetFrom", $null)
                }
                else
                {
                    $VersionFrom = $null
                }
                if ($ChangesetTo -gt 0)
                {
                    $VersionTo = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::ParseSingleSpec("C$ChangesetTo", $null)
                }
                else
                {
                    $VersionTo = $null
                }
                break
            }
            'Date'
            {
                if ($DateFrom -ne $null)
                {
                    $VersionFrom = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.DateVersionSpec -ArgumentList $DateFrom
                }
                else
                {
                    $VersionFrom = $null
                }
                if ($DateTo -eq $null)
                {
                    $VersionTo = $null
                    $Version = [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest
                }
                else
                {
                    $VersionTo = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.DateVersionSpec -ArgumentList $DateTo
                    $Version = $VersionTo
                }
                break
            }
        }
        function Add-ChangesetType
        {
            [cmdletBinding()]
            param([Parameter(ValueFromPipeline)]$Changeset)
            process
            {
                $Changeset | Add-ObjectTypeDetails -TypeName 'TFS.Changeset' -DefaultProperties 'ChangesetId', 'CreationDate', 'OwnerDisplayName', 'Comment'
            }
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName)
        {
            'QueryHistoryParameter' 
            {
                Write-Verbose -Message 'Query TFS History from QueryHistoryParameter'
                $TFSCollection.VCS.QueryHistory($QueryHistoryParameter) |
                Add-ChangesetType 
                break
            }
            'ItemSpec'
            {
                Write-Verbose -Message 'Query TFS History from ItemSpec'
                $TFSCollection.VCS.QueryHistory($ItemSpec,$MaxCount) |
                Add-ChangesetType 
                     
                break
            }
            default
            {
                foreach ($folder in $TfsFolders) 
                {
                    Write-Verbose -Message "Query TFS History for folder: $folder"
                    $TFSCollection.VCS.QueryHistory( $folder,$Version,0,$Recursion,$User,$VersionFrom,$VersionTo,$MaxCount,$IncludeChangesDetails,$true) |
                    Add-ChangesetType
                }
            }
        }
    }
    end {}
}

