Set-StrictMode -Version Latest


function Get-TFSBuildDefinitions {
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDefinition[]])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [ValidateNotNullOrEmpty()]
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
        if ([String]::IsNullOrEmpty($TfsCollection))
        {
             Throw 'TFS Collection is invalid or empty!'
        }
    }
    process{
        $result = $null
        if ($TeamProject){
            if ($Options){
                $result = $TfsCollection.BS.QueryBuildDefinitions($TeamProject,$Options)
            }
            else{
                $result = $TfsCollection.BS.QueryBuildDefinitions($TeamProject)
            }
        }
        elseif ($DefinitionSpec){
            $qr = $TfsCollection.BS.QueryBuildDefinitions($DefinitionSpec)
            if ($qr -and $qr.Definitions -and $qr.Definitions.Count -gt 0){
                $result = $qr.Definitions
            }
        }
        if ($result){
            ([Microsoft.TeamFoundation.Build.Client.IBuildDefinition[]]$result)
        }
    }
    end{}
}

