#requires -Version 2



function Get-TFSQueryWorkspaces
{
    [CmdletBinding()] 
    [OutputType([Microsoft.TeamFoundation.VersionControl.Client.Workspace])]
    param (
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Position = 0,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [string]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $WorkspaceName = [System.Management.Automation.Language.NullString]::Value,
        [string]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $WorkspaceOwner = [System.Management.Automation.Language.NullString]::Value,
        [string]
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $WorkspaceComputer = [System.Management.Automation.Language.NullString]::Value
    )
    begin 
    {
        
    }
    process {
        $name = [System.Management.Automation.Language.NullString]::Value
        $owner = [System.Management.Automation.Language.NullString]::Value
        $computer = [System.Management.Automation.Language.NullString]::Value
        if ($WorkspaceName -and $WorkspaceName -ne '')
        {
            $name = $WorkspaceName
        }
        if ($WorkspaceComputer -and $WorkspaceComputer -ne '')
        {
            $computer = $WorkspaceComputer
        }
        if ($WorkspaceOwner -and $WorkspaceOwner -ne '')
        {
            $owner = $WorkspaceOwner
        }
        Write-Verbose -Message "Query TFS Workspaces for Owner: [$owner] Workspace: [$name] Computer: [$computer]"	
        $TFSCollection.VCS.QueryWorkspaces($name,$owner,$computer) | 
            Add-ObjectTypeDetails -TypeName 'TFS.Workspace' -DefaultProperties 'OwnerDisplayName', 'Computer', 'Name', 'LastAccessDate'
				
        
    }
    end
    {}
}


