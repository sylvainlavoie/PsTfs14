#requires -Version 2
Set-StrictMode -Version 'Latest'

<#
        .SYNOPSIS
        Retrieve the Builds in the queue.

        .DESCRIPTION
        List all the running builds and the builds in queue for the matching TeamProject and the matching Definition.
        By default list all the Definition of all the TeamProject.

        .PARAMETER  BuildQueueSpec 
        The Build Queue Spec to use to Query the Build Queue.

        .PARAMETER  TFSCollection
        The TFSCollection project collection Object.

        .EXAMPLE
        PS C:\> Get-TFSCollectionQueuedBuilds -TFSCollection $TFSCollection -BuildQueueSpec $spec

        .EXAMPLE
        PS C:\> $spec | Get-TFSBuildQueue -TFSCollection $TFSCollection

        .OUTPUTS
        Microsoft.TeamFoundation.Build.Client.IQueuedBuild
#>
function Get-TFSBuildQueue 
{
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IQueuedBuild])]
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [Alias('TFS')]
        [Microsoft.TeamFoundation.Client.TFSTeamProjectCollection]
        $TFSCollection,
        [Microsoft.TeamFoundation.Build.Client.IQueuedBuildSpec]
        [Parameter(ValueFromPipeline = $true)]
        [Alias('Spec')]
        [ValidateNotNullOrEmpty()]
        
        $BuildQueueSpec
    )
    Begin
    {
        function Add-QueuedBuildType
        {
            [cmdletbinding()]
            param(
                [Parameter(ValueFromPipeline)]
                $build
                )
            begin
            {
                $add = @(
                    @{
                        n = 'DefinitionId'
                        e = {
                            if ($_.BuildDefinitionUri) {$_.BuildDefinitionUri.Segments[3]}
                        }
                    }, 
                    @{
                        n = 'DefinitionName'
                        e = {
                            if ($_.BuildDefinition) {$_.BuildDefinition.Name}
                        }
                    },
                    @{
                        n = 'BuildId'
                        e = {
                            if ($_.Builds -and $_.Builds.Count -gt 0)
                            {
                                $_.Builds[0].Uri.Segments[3]
                            }
                        }
                    },
                    @{
                        n = 'BuildNumber'
                        e = {
                            if ($_.Builds -and $_.Builds.Count -gt 0)
                            {
                                $_.Builds[0].BuildNumber
                            }
                        }
                    }
                    
                )
                $default = @('Id','BuildNumber', 'Status', 'QueueTime')
            }
            process
            {
                $build | Add-ObjectTypeDetails -TypeName 'TFS.XAML.BuildQueue' -PropertyToAdd $add -DefaultProperties $default
            
            }
        }
        
    }
    Process {
        $TFSCollection.BS.QueryQueuedBuilds($BuildQueueSpec).QueuedBuilds | Add-QueuedBuildType
        
    }
    End{}
}

