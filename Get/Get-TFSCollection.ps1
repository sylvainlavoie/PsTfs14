#requires -Version 2


Set-StrictMode -Version 'Latest'


function Get-TFSCollection 
{
    <#
            .SYNOPSIS
            Get the TeamFoundationServer object from the Factory to access the selected collection.

            .DESCRIPTION
            Use the TFS Server Factory to get the TFS server access.
            Some other helper class are added in the same time.
            VCS => Version Control Server.
            WIT => WorkItemStore.
            BS  => Build Server.
            CSS => Common structures Areas and Iterations
            GSS => Group Security Service

            .PARAMETER  CollectionURL
            The URL of the TFS Server collection to connect.
	
            .EXAMPLE
            - Will use the default CollectionUrl set with Set-TFSDefaut
            PS C:\> Get-TFS 

            .EXAMPLE
            PS C:\> TFS -CollectionURL 'http://tfsServer:8080/collection'


    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([Microsoft.TeamFoundation.Client.TfsTeamProjectCollection])]
    param
    (
        [System.String]
        [Alias('Name')]
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $CollectionURL = ((Get-TFSDefault).TFSCollectionUrl),
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias('BS')]
        $BuilsServer,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias('VCS')]
        $VersionControlServer,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        $WorkItemStore,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        $CommonStructureService,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias('GSS')]
        $GroupSecurityService,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        $ClientHyperlinkService,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        $TestManagementService,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        [Parameter(ParameterSetName = 'Default')]
        [Alias('IMS')]
        $IdentityManagementService,
        [Switch]
        [Parameter(ParameterSetName = 'Services')]
        $EventService,
        [switch]
        [Parameter(ParameterSetName = 'All')]
        $All
		
    )
    begin
    {
        function Add-CollectionType
        {
            [cmdletbinding()]
            param (
                [Parameter(ValueFromPipeline)]
                $colObj
            )
            begin
            {
                $add = @()
                if ($BuilsServer -or $PsCmdlet.ParameterSetName -match 'All|Default')
                {
                    $add += @{
                        n = 'BS'
                        e = {
                            Write-Verbose -Message 'Add Build Server Service as property BS: [Microsoft.TeamFoundation.Build.Client.IBuildServer]'
                            $_.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
                        }
                    }
                }
                if ($VersionControlServer -or $PsCmdlet.ParameterSetName -match 'All|Default')
                {
                    $add += @{
                        n = 'VCS'
                        e = {
                            Write-Verbose -Message 'Add Version Control Server Service as property VCS: [Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer]'
                            $_.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])
                        }
                    }
                }
                if ($WorkItemStore -or $PsCmdlet.ParameterSetName -eq 'All')
                {
                    $add += @{
                        n = 'WIT'
                        e = {
                            Write-Verbose -Message 'Add Work Item Store Service as property WIT: [Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore]'
                            $_.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])
                        }
                    }
                }
                if ($CommonStructureService -or $PsCmdlet.ParameterSetName -eq 'All')
                {
                    $add += @{
                        n = 'CSS'
                        e = {
                            Write-Verbose -Message 'Add Common Structure Service as property CSS: [Microsoft.TeamFoundation.Server.ICommonStructureService]'
                            $_.GetService([Microsoft.TeamFoundation.Server.ICommonStructureService])
                        }
                    }
                }
                if($GroupSecurityService -or $PsCmdlet.ParameterSetName -match 'All|Default')
                {
                    $add += @{
                        n = 'GSS'
                        e = {
                            Write-Verbose -Message 'Add Groupe Security Service as property GSS: [Microsoft.TeamFoundation.Server.IGroupSecurityService]'
                            $_.GetService([Microsoft.TeamFoundation.Server.IGroupSecurityService])
                        }
                    }
                }
                if ($ClientHyperlinkService -or $PsCmdlet.ParameterSetName -eq 'All')
                {
                    $add += @{
                        n = 'WEB'
                        e = {
                            Write-Verbose -Message 'Add Client Hyperlink Service as property WEB: [Microsoft.TeamFoundation.Client.TswaClientHyperlinkService]'
                            $_.GetService([Microsoft.TeamFoundation.Client.TswaClientHyperlinkService])
                        }
                    }
                }
                if($TestManagementService -or $PsCmdlet.ParameterSetName -eq 'All')
                {
                    $add += @{
                        n = 'TMS'
                        e = {
                            Write-Verbose -Message 'Add Test Management Service as property TMS: [Microsoft.TeamFoundation.TestManagement.Client.ITestManagementService]'
                            $_.GetService([Microsoft.TeamFoundation.TestManagement.Client.ITestManagementService])
                        }
                    }
                }
                if ($IdentityManagementService -or $PsCmdlet.ParameterSetName -match 'All|Default')
                {
                    $add += @{
                        n = 'IMS'
                        e = {
                            Write-Verbose -Message 'Add Identity Management Service as property IMS: [Microsoft.TeamFoundation.Framework.Client.IIdentityManagementService]'
                            $_.GetService([Microsoft.TeamFoundation.Framework.Client.IIdentityManagementService])
                        }
                    }
                }
                if ($EventService -or $PsCmdlet.ParameterSetName -eq 'All')
                {
                    $add += @{
                        n = 'ES'
                        e = {
                            Write-Verbose -Message 'Add Event Service as property ES: [Microsoft.TeamFoundation.Framework.Client.IEventService]'
                            $_.GetService([Microsoft.TeamFoundation.Framework.Client.IEventService])
                        }
                    }
                }
        
                $default = @('DisplayName', 'Uri', 'HasAuthenticated', 'IsHostedServer')
              
            }
            process
            {
                $colObj |  Add-ObjectTypeDetails -TypeName 'TFS.Collection' -PropertyToAdd $add -DefaultProperties $default
            }
        }
    }
    process
    { 
        if ([String]::IsNullOrEmpty($CollectionURL))
        {
            Throw "$_ is not a Valid TFS Server Collection URL!"
        }
        $collection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection([Uri]$CollectionURL)
        
        if (-not (Test-Path Variable:script:collectionInstance) -or $Script:collectionInstance.CachedInstanceId -ne $collection.CachedInstanceId)
        {
            $Script:collectionInstance = $collection | Add-CollectionType
        }
        else
        {
            $Script:collectionInstance = $collection
        }
        
        

        $Script:collectionInstance
        
    }
}



