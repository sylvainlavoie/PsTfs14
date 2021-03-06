#requires -Version 2

Set-StrictMode -Version 'Latest'
<#
        .SYNOPSIS
        Get the Shelve Set from TFS. 

        .DESCRIPTION
        Return a List of shelveset for the specified user. 
        If no user name specified, get all users shelves.

        .PARAMETER  TFS	
        The TFS project collection Object.
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
		
        .PARAMETER  OwnerName
        Owner Name of the shelveset to retrieve.
        If not set, retrieve the shelvesets for all users.
		
        .PARAMETER Name
        The name of the shelveset to retrieve.
        If not set, retrieve all changesets.
		
        .PARAMETER propertyNameFilters
        The list of properties to be returned on the shelvesets. 
        To get all properties pass a single filter that is simply "*"
        Default: '*'
		
        .EXAMPLE
        PS C:\> Get-TFSShelvesets -TFSCollection $TFSCollection

        .EXAMPLE
        PS C:\> Get-TFSShelvesets -TFSCollection $TFSCollection -OwnerName 'userId'

#>

function Get-TFSQueryShelvesets 
{
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.VersionControl.Client.Shelveset])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [string]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Name')]
        $ShelvesetName,
        [string]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Owner')]
        [Alias('AccountName')]
        $ShelvesetOwner,
        [string[]]
        $propertyNameFilters
    )
    begin
    {
        if (!$propertyNameFilters)
        {
            $propertyNameFilters = '*'
        }
        else
        {
            Write-Verbose -Message "Query Shelvesets with property filter: $propertyNameFilters"
        }
    }
    process{
        if ([string]::IsNullOrEmpty($ShelvesetName) )
        {
            $ShelvesetName = [System.Management.Automation.Language.NullString]::Value
            $shelve = 'Any'
        }
        else
        {
            $shelve = $ShelvesetName
        }
        if ([string]::IsNullOrEmpty($ShelvesetOwner) )
        {
            $OwnerName = [System.Management.Automation.Language.NullString]::Value
            $owner = 'All'
        }
        else
        {
            $owner = $ShelvesetOwner
        }
        
        Write-Verbose -Message "Query Shelveset for User: [$owner] with Name: [$shelve]"
        $TFSCollection.VCS.QueryShelvesets($ShelvesetName,$ShelvesetOwner,$propertyNameFilters) |
        Add-ObjectTypeDetails -TypeName 'TFS.Shelveset' -DefaultProperties 'CreationDate', 'OwnerDisplayName', 'Name' 
        
    }
    end{}
}
