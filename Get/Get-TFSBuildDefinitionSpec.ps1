#requires -Version 2
Set-StrictMode -Version 'Latest'
<#
        .SYNOPSIS
        Creates a new build definition specification.

        .DESCRIPTION
        Creates a new build definition specification that can be used to query build definitions.

        .PARAMETER  TFS	
        The TFS project collection Object.

        .PARAMETER 	TeamProject
        The team project for which definitions can be queried.
		
        .PARAMETER	DefinitionName
        The definition name to query - supports wildcard characters.
			
        .PARAMETER  BuildDefinition
        Creates a new build definition specification that can be used to query build definitions.

        .PARAMETER	Options
        Query options that are used to determine whether supporting objects are returned from the query.
        All				:	Query all.
        Agents			:	Query agents.
        BatchedRequests	:	The list of requests batched into this build should be returned.
        Controllers		:	Query controllers.
        Definitions		:	Query definitions.
        HistoricalBuilds:	The list of builds associated with each request should be returned.
        None			:	Query nothing.
        Process			:	Query processes.
        Workspaces		:	Query workspaces.	
				
        .PARAMETER	TriggerType
        An optional filter to control the type of build definitions returned from the query.
        All								:	All types.
        BatchedContinuousIntegration	:	A build should be started for multiple changesets at a time at a specified interval.
        BatchedGatedCheckIn				:	A validation build should be started for each batch of check-ins.
        ContinuousIntegration			:	A build should be started for each changeset.
        GatedCheckIn					:	A validation build should be started for each check-in.
        None							:	Manual builds only.
        Schedule						:	A build should be started on a specified schedule if changesets exist.
        ScheduleForced					:	A build should be started on a specified schedule whether or not changesets exist.
			
        .EXAMPLE
        PS C:\> Get-TFSBuildDefinitionSpec -TFS $TFS 

        .EXAMPLE
        PS C:\> Get-TFSBuildDefinitionSpec -TFS $TFS -Options ([Microsoft.TeamFoundation.Build.Client.QueryOptions] "Agents","Controllers")
			
        .EXAMPLE
        PS C:\> $BuildDefinitions | Get-TFSBuildDefinitionSpec -TFS $TFS
#>
function Get-TFSBuildDefinitionSpec 
{
    [CmdletBinding(DefaultParameterSetName = 'TeamProject')]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDefinitionSpec])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [System.string]
        [parameter(ValueFromPipelineByPropertyName = $true,ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'TeamProject')]
        [Parameter(ParameterSetName = 'DefinitionName')]
        [ValidateNotNullOrEmpty()]
        $TeamProject = '*',
        [System.string]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'DefinitionName')]
        [ValidateNotNullOrEmpty()]
        $DefinitionName = '*',
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition]
        [Parameter(	ValueFromPipeline = $true,
        ParameterSetName = 'BuildDefinition')]
        [ValidateNotNullOrEmpty()]
        $BuildDefinition,
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        $Options,
        [Microsoft.TeamFoundation.Build.Client.DefinitionTriggerType]
        $TriggerType
    )
    Begin{}
    Process{
        switch ($PsCmdlet.ParameterSetName) {
            'DefinitionName' 
            {
                $spec = $TFSCollection.BS.CreateBuildDefinitionSpec($TeamProject,$DefinitionName)
                break
            }
            'Definition' 
            {
                $spec = $TFSCollection.BS.CreateBuildDefinitionSpec($BuildDefinition)
                break
            }
            default 
            {
                $spec = $TFSCollection.BS.CreateBuildDefinitionSpec($TeamProject)
                break
            }
        }	
        if ($Options) 
        {
            $spec.Options = $Options
        }
        if ($TriggerType) 
        {
            $spec.TriggerType = $TriggerType
        }
        $spec
    }
    End{}
}


