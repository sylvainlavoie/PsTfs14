#requires -Version 2
Set-StrictMode -Version 'Latest'
<#
        .SYNOPSIS
        Create a Build Details Spec to query Builds.

        .DESCRIPTION
        Creates a new build detail specification that can be used to query builds for the specified definitions.

        .PARAMETER  TFSCollection	
        The TFS project collection Object.

        .PARAMETER 	TeamProject
        The team project for which builds can be queried.
	
        .PARAMETER	DefinitionName
        The build definition for which builds can be queried. Wildcard characters are supported.
			
        .PARAMETER	BuildDefinition
        The build definition for which builds can be queried.
		
        .PARAMETER  BuildDefinitionSpec
        A build definition specification that includes the team project and definition for which builds can be queried.
		
        .PARAMETER	DefinitionUris
        The build definitions Uris for which builds can be queried.

        .PARAMETER	BuildNumber
        Gets or sets the number of the desired builds. 
        Wildcard characters are supported.
		
        .PARAMETER  BuildStatus
        The statuses of the desired builds.
        All					:	All status applies.
        Failed				:	Build failed.
        InProgress			:	Build is in progress.
        None				:	No status available.
        NotStarted			:	Build is not started.
        PartiallySucceeded	:	Build is partially succeeded.
        Stopped				:	Build is stopped.
        Succeeded			:	Build succeeded.
        To Combine use the syntax below 
        ([Microsoft.TeamFoundation.Build.Client.BuildStatus] 'Failed', 'PartlySucceeded')	

        .PARAMETER	BuildReason
        Sets the reason for the desired builds.
        All					Build was started for any of the prevous reasons.
        BatchedCI			Build was started due to batched check-in.
        CheckInShelveset	Build was started to check shelveset.
        IndividualCI		Build started due to individual check-in.
        Manual				Build started manually.
        None				No reason given.
        Schedule			Build was started due to scheduled time, only if changes were made.
        ScheduleForced		Build was started due to scheduled time, even if no changes were made.
        Triggered			Build was triggered by an event.
        UserCreated			Build was started due to user defined reason.
        ValidateShelveset	Build was started to validate shelveset.		 
        ([Microsoft.TeamFoundation.Build.Client.BuildReason] 'Manual','Schedule')
		 
        .PARAMETER	QueryOptions
        Sets the additional data that will be returned from the queries.
        Agents				Query agents.
        All					Query all.
        BatchedRequests		The list of requests batched into this build should be returned.
        Controllers			Query controllers.
        Definitions			Query definitions.
        HistoricalBuilds	The list of builds associated with each request should be returned.
        None				Query nothing.
        Process				Query processes.
        Workspaces			Query workspaces.		 
        ([Microsoft.TeamFoundation.Build.Client.QueryOptions]'Definitions','Workspaces')
        .PARAMETER	QueryOrder
        Sets the ordering scheme to use when the user sets a maximum number of builds.
        FinishTimeAscending		Order by finish time, ascending.
        FinishTimeDescending	Order by finish time, descending.
        StartTimeAscending		Order by start time, ascending.
        StartTimeDescending		Order by start time, descending.
        [Microsoft.TeamFoundation.Build.Client.BuildQueryOrder]
		
        .PARAMETER	QueryDeleteOption
        Sets options to query deleted builds.
        ExcludeDeleted		Exclude deleted items from the query.
        IncludeDeleted		Include deleted items in the query.
        OnlyDeleted			Query only deleted items.		
        [Microsoft.TeamFoundation.Build.Client.QueryDeletedOption]

        .PARAMETER	MaxFinishTime	
        Sets the end of the finish time range of the specified builds.
        .PARAMETER	MinFinishTime	
        Sets the start value of the finish time range of the specified builds.
        .PARAMETER	MaxBuildPerDefinition
        Sets the maximum number of builds to return per definition.
		
        .PARAMETER	AllInformationtypes
        Set to True to get all the information type. Longer Get operation may result.
        If not set, each information type required need to be set individually.
		
        .PARAMETER	IncludeAgentName
        If the Build Agent Name is required for the build, this Information type need to be set.
		
        .PARAMETER	AgentScopeActivityTracking
        .PARAMETER	AssociatedChangeset
        .PARAMETER	AssociatedWorkItem
        .PARAMETER	BuildError
        .PARAMETER	BuildMessage
        .PARAMETER	BuildProject
        .PARAMETER	BuildStep
        .PARAMETER	BuildWarning
        .PARAMETER	DeploymentInformation
		
		
		
        .EXAMPLE
        PS C:\> Get-TFSBuildDetailSpec -TFS $TFSCollection

	


#>

function Get-TFSBuildDetailSpec 
{
    #[CmdletBinding(DefaultParameterSetName="TeamProject")]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDetailSpec])]
    param(
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('TFS')]
        $TFSCollection,
        [System.string]
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        #[Parameter(ParameterSetName="TeamProject")]
        #[Parameter(ParameterSetName="DefinitionName")]
        [ValidateNotNullOrEmpty()]
        $TeamProject = '*',
        [System.string]
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        #[Parameter(ParameterSetName="DefinitionName")]
        [ValidateNotNullOrEmpty()]
        $DefinitionName = '*',
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition]
        [Parameter(	ValueFromPipeline = $true)]
        #[Parameter(ParameterSetName='pipe')]
        [ValidateNotNullOrEmpty()]
        $BuildDefinition,
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinitionSpec]
        [Parameter(	ValueFromPipeline = $true)]
        #[Parameter(ParameterSetName='pipe')]
        [ValidateNotNullOrEmpty()]
        $BuildDefinitionSpec,
        [System.Uri[]]
        [Parameter(	ValueFromPipeline = $true)]
        #[Parameter(ParameterSetName='pipe')]
        [ValidateNotNullOrEmpty()]
        $DefinitionUris,
        [string]
        $BuildNumber,
        [Microsoft.TeamFoundation.Build.Client.BuildStatus]
        $BuildStatus,
        [Microsoft.TeamFoundation.Build.Client.BuildReason]
        $BuildReason,
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        $QueryOptions,
        [Microsoft.TeamFoundation.Build.Client.BuildQueryOrder]
        $QueryOrder,
        [Microsoft.TeamFoundation.Build.Client.QueryDeletedOption]
        $QueryDeleteOption,
        [int]
        $MaxBuildPerDefinition,
        [DateTime]
        $MinFinishTime,
        [DateTime]
        $MaxFinishTime,
        [switch]
        $AllInformationtypes,
		
        [switch]
        $IncludeAgentName,
        [switch]
        $AgentScopeActivityTracking,
        [switch]
        $AssociatedChangeset,
        [switch]
        $AssociatedWorkItem,
        [switch]
        $BuildError,
        [switch]
        $BuildMessage,
        [switch]
        $BuildProject,
        [switch]
        $BuildStep,
        [switch]
        $BuildWarning,
        [switch]
        $DeploymentInformation
    )
    begin{}
    process{
        if ($BuildDefinition) 
        {
            $buildspec = $TFSCollection.BS.CreateBuildDetailSpec($BuildDefinition)
        }
        elseif ($BuildDefinitionSpec) 
        {
            $buildspec = $TFSCollection.BS.CreateBuildDetailSpec($BuildDefinitionSpec)
        }
        elseif ($DefinitionUris) 
        {
            $buildspec = $TFSCollection.BS.CreateBuildDetailSpec([System.Uri[]]$DefinitionUris)
        }
        else 
        {
            $buildspec = $TFSCollection.BS.CreateBuildDetailSpec($TeamProject,$DefinitionName)
        }

        if (!$AllInformationtypes)
        {
            $buildspec.InformationTypes = @()
            if ($IncludeAgentName -or $AgentScopeActivityTracking) 
            {
                $buildspec.InformationTypes += 'AgentScopeActivityTracking'
            }
            if ($AssociatedChangeset) 
            {
                $buildspec.InformationTypes += 'AssociatedChangeset'
            }
            if ($AssociatedWorkItem) 
            {
                $buildspec.InformationTypes += 'AssociatedWorkItem'
            }
            if ($BuildError) 
            {
                $buildspec.InformationTypes += 'BuildError'
            }
            if ($BuildMessage) 
            {
                $buildspec.InformationTypes += 'BuildMessage'
            }
            if ($BuildProject) 
            {
                $buildspec.InformationTypes += 'BuildProject'
            }
            if ($BuildStep) 
            {
                $buildspec.InformationTypes += 'BuildStep'
            }
            if ($BuildWarning) 
            {
                $buildspec.InformationTypes += 'BuildWarning'
            }
            if ($DeploymentInformation) 
            {
                $buildspec.InformationTypes += '$DeploymentInformation'
            }
        }
        if($MinFinishTime) 
        {
            $buildspec.MinFinishTime = $MinFinishTime
        }
        if($MaxFinishTime) 
        {
            $buildspec.MaxFinishTime = $MaxFinishTime
        }
        if ($QueryDeleteOption)
        {
            $buildspec.QueryDeletedOption = $QueryDeleteOption
        } 
        if ($QueryOrder)
        {
            $buildspec.QueryOrder = $QueryOrder
        }
        if ($MaxBuildPerDefinition)
        {
            $buildspec.MaxBuildsPerDefinition = $MaxBuildPerDefinition
        }
        if ($QueryOptions)
        {
            $buildspec.QueryOptions = $QueryOptions
        }
        if ($BuildStatus)
        {
            $buildspec.Status = $BuildStatus
        }
        $buildspec
    }
    end{}
}	
	
	
	

