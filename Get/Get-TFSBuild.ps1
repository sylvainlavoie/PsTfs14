#requires -Version 2

Set-StrictMode -Version 'Latest'
<#
        .SYNOPSIS
        Get Build from TFS.

        .DESCRIPTION
        Query Build from TFS using the specified parameters.
        .PARAMETER  TFSCollection	
        The TFS project collection Object.
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]

        .PARAMETER 	TeamProject
        The team project for which builds can be queried.
        NOTE: All the BuildInformation are retrieved, give slower query.
		
        .PARAMETER	DefinitionName
        The build definition for which builds can be queried. Wildcard characters are supported.
        NOTE: All the BuildInformation are retrieved, give slower query.
		
        .PARAMETER	BuildDefinition
        The build definition for which builds can be queried.
        NOTE: All the BuildInformation are retrieved, give slower query.
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition]
        .PARAMETER  BuildDefinitionSpec
        A build definition specification that includes the team project and definition for which builds can be queried.
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinitionSpec]
			
        .PARAMETER	BuildDetailSpec	
        Gets the builds result for the specified build specification.
        [Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec]
			
        .PARAMETER	BuildDetailSpecs
        Query the Builds for the specified list of build specifications.
        [Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec[]]
		
        .PARAMETER	BuildUris
        Gets the builds that match the specified URIs.
        .PARAMETER	InformationTypes
        The information types which should be retrieved. 
        Valid types include the members of Microsoft.TeamFoundation.Build.Common.InformationTypes. 
        Wildcards supported.
        '*' includes all Information types
        .PARAMETER	QueryOptions
        The query options.
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        .PARAMETER	QueryDeletedOption
        Specify whether to include deleted builds in the query.
        [Microsoft.TeamFoundation.Build.Client.QueryDeletedOption]
		
        .EXAMPLE
        PS C:\> Get-TfsBuild -TFSCollection $TFSCollection -TeamProject cm -DefinitionName 'Antivirus*'

        .EXAMPLE
        PS C:\> Get-TFSBuildDetailSpec -TFSCollection $TFSCollection -TeamProject cm -DefinitionName 'Antivirus*' | Get-TfsBuild -TFSCollection $TFSCollection
#>
function Get-TFSBuild 
{
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDetail])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [System.string]
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        $TeamProject,
        [System.string]
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        $DefinitionName,
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition]
        [Parameter(	ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $BuildDefinition,
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinitionSpec]
        [Parameter(	ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $BuildDefinitionSpec,
        [Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec]
        [Parameter(	ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $BuildDetailSpec,
        [Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec[]]
        [Parameter(	ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        $BuildDetailSpecs,
        [System.Uri[]]
        [Parameter(ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'BuildUris')]
        [ValidateNotNullOrEmpty()]
        [Alias('Uri')]
        $BuildUris,
        [System.String[]]
        [Parameter(ParameterSetName = 'BuildUris')]
        $InformationTypes,
        [Parameter(ParameterSetName = 'BuildUris')]
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        $QueryOptions,
        [Microsoft.TeamFoundation.Build.Client.QueryDeletedOption]
        [Parameter(ParameterSetName = 'BuildUris')]
        $QueryDeletedOption
    )
    Begin
    {
        function Add-BuildType
        {
            [CmdletBinding()]
            param(
                [Parameter(ValueFromPipeline)]
                $build
            )
            begin
            {
                $add = @(
                    @{
                        n = 'Id'
                        e = {
                            $_.Uri.Segments[3]
                        }
                    }, 
                    @{
                        n = 'DefinitionName'
                        e = {
                            $_.BuildDefinition.Name
                        }
                    }, 
                    @{
                        n = 'Duration'
                        e = { Get-Duration -Start $_.StartTime -Finish $_.FinishTime }
                    }
                )
                $default = @('BuildNumber', 'Status', 'StartTime', 'Id') # 'TeamProject', 'DefinitionName', 'StartTime', 'FinishTime', 'Duration', 'RequestedBy', 'Id')
            }
            process
            {
                $build | Add-ObjectTypeDetails -TypeName 'TFS.XAML.Build' -PropertyToAdd $add -DefaultProperties $default
                    
            }
        }
    }
    Process{
        if ($BuildDefinition) 
        {
            $TFSCollection.BS.QueryBuilds($BuildDefinition) | Add-BuildType 
        }
        elseif ($BuildDefinitionSpec) 
        {
            $TFSCollection.BS.QueryBuilds($BuildDefinitionSpec) | Add-BuildType
        }
        elseif ($BuildDetailSpec) 
        {
            $bqresult = $TFSCollection.BS.QueryBuilds($BuildDetailSpec)
            if($bqresult)
            {
                $bqresult.Builds | Add-BuildType
            }
        }
        elseif ($BuildDetailSpecs) 
        {
            $bqresult = $TFSCollection.BS.QueryBuilds([Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec[]]$BuildDetailSpecs)
            if($bqresult)
            {
                $bqresult.Builds | Add-BuildType
            }
        }
        elseif ($BuildUris -and $BuildUris -is [System.Array]) 
        {
            if (!$InformationTypes)
            {
                $InformationTypes = ''
            }
            if (!$QueryOptions)
            {
                $QueryOptions = 'All'
            }
            if ($QueryDeletedOption)
            {
                $TFSCollection.BS.QueryBuildsByUri($BuildUris,$InformationTypes,$QueryOptions,$QueryDeletedOption) | Add-BuildType
            }
            else
            {
                $TFSCollection.BS.QueryBuildsByUri($BuildUris,$InformationTypes,$QueryOptions) | Add-BuildType
            }
        }
        elseif ($TeamProject) 
        {
            if (!$DefinitionName)
            {
                $DefinitionName = '*'
            }
            $TFSCollection.BS.QueryBuilds($TeamProject,$DefinitionName) | Add-BuildType
        }
        else 
        {
            Write-Error -Message 'No Parameters found to match QueryBuilds, Specify at least TeamProject' -Category InvalidArgument
        }
        
    }
    End
    {
    }
}



