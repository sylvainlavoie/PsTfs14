Set-StrictMode -Version Latest


function Get-TFSBuildDefinitions {
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDefinition])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [Alias('TFS')]
        $TfsCollection,
        [string]
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='TeamProject')]
        [ValidateNotNullOrEmpty()]
        $TeamProject,
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinitionSpec]
        [Parameter(ValueFromPipeline=$true,ParameterSetName='DefSpec')]
        [ValidateNotNullOrEmpty()]
        $DefinitionSpec,
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        [Parameter(ParameterSetName='TeamProject')]
        $Options        
    )
    begin
    {
        function Add-DefinitionType 
        {
            [cmdletbinding()]
            param(
                [Parameter(ValueFromPipeline = $true)]
                $definition
            )
            begin
            {
                $add = @(
                    @{
                        n = 'LastGoodBuildId'
                        e = {
                            $_.LastGoodBuildUri.Segments[3]
                        }
                    },
                     @{
                        n = 'LastBuildId'
                        e = {
                            $_.LastBuildUri.Segments[3]
                        }
                    }
                )
                $default = @('TeamProject', 'Name', 'Enabled', 'Id')
            }
            process
            {
                $definition | Add-ObjectTypeDetails -TypeName 'TFS.XAML.BuildDefinition' -DefaultProperties $default #-PropertyToAdd $add 
                
            }
        }
    }
    process{
       
        if ($TeamProject){
            if ($Options){
                $TfsCollection.BS.QueryBuildDefinitions($TeamProject,$Options) | 
                    Add-DefinitionType 
            }
            else{
                $TfsCollection.BS.QueryBuildDefinitions($TeamProject) | 
                    Add-DefinitionType 
            }
        }
        elseif ($DefinitionSpec){
            $qr = $TfsCollection.BS.QueryBuildDefinitions($DefinitionSpec)
            if ($qr -and $qr.Definitions -and $qr.Definitions.Count -gt 0){
                $qr.Definitions | 
                    Add-DefinitionType 
            }
        }
        
    }
    end
    {
    }
}

