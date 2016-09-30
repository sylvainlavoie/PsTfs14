#requires -Version 2
Set-StrictMode -Version 'Latest'
<#
        .SYNOPSIS
        Create a TFSCollection Build Queue Spec to retrieve Build in Queue.

        .DESCRIPTION
        Create the Build Queue Spec object used to retrieve Build in Queue.

        .PARAMETER  TFSCollection
        The TFSCollection Team Project Collection Object.

        .PARAMETER  TeamProject
        Team Project to search for.
			
        .PARAMETER	DefinitionName
        The Definition Name to search.
			
        .PARAMETER	DefinitionUris
        Array of Uri to search
			
        .PARAMETER	QueryOptions
        Allow to control the Options to Query.
        All					:	Query all.
        Agents				:	Query agents.
        BatchedRequests		:	The list of requests batched into this build should be returned.
        Controllers			:	Query controllers.
        Definitions			:	Query definitions.
        HistoricalBuilds	:	The list of builds associated with each request should be returned.
        None				:	Query nothing.
        Process				:	Query processes.
        Workspaces			:	Query workspaces.
				
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        ([Microsoft.TeamFoundation.Build.Client.QueryOptions] "Definitions","HistoricalBuilds")
			
        .PARAMETER	QueueStatus
        Describes the status of the queue item. 
        All:		All flags on.
        Canceled:	Item is canceled.
        Completed:	Item is completed.
        InProgress:	Item in progress.
        None:		Status unknown.
        Postponed:	Item is postponed.
        Queued:		Item is queued.
        Retry:		The build has been requeued for a retry most likely because of failure.
			
        [Microsoft.TeamFoundation.Build.Client.QueueStatus]
        ([Microsoft.TeamFoundation.Build.Client.QueueStatus] "Canceled","Completed")

        .PARAMETER	CompletedWindow
        The completed-by time window that is used to query for completed builds.
        Queued builds that have been completed for a greater duration than the window that is specified will not be included in the query results.
        [System.TimeSpan]
	
        .EXAMPLE
        PS C:\> Get-TFSCollectionBuildQueueSpec -TFSCollection $TFSCollection 

        .EXAMPLE
        PS C:\> Get-TFSCollectionBuildQueueSpec $TFSCollection "TeamProject" "Definition"
		
        .EXAMPLE
        PS C:\> Get-TFSCollectionBuildQueueSpec -TFSCollection $TFSCollection -QueryOptions ([Microsoft.TeamFoundation.Build.Client.QueryOptions] "Controllers", "Agents") 

#>
function Get-TFSBuildQueueSpec 
{
    [CmdletBinding(DefaultParameterSetName = 'TeamProject')]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('TFS')]
        [Microsoft.TeamFoundation.Client.TFSTeamProjectCollection]
        $TFSCollection,
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [System.string]
        [Parameter(ParameterSetName = 'TeamProject')]
        [Parameter(ParameterSetName = 'Definition')]
        [ValidateNotNullOrEmpty()]
        $TeamProject = '*',
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [System.string]
        [Parameter(ParameterSetName = 'Definition')]
        [ValidateNotNullOrEmpty()]
        $DefinitionName = '*',
        [Parameter(ParameterSetName = 'DefinitionUris')]
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $DefinitionUris,
        [Microsoft.TeamFoundation.Build.Client.QueryOptions]
        $QueryOptions,
        [Microsoft.TeamFoundation.Build.Client.QueueStatus]
        $QueueStatus,
        [System.TimeSpan]
        $CompletedWindow
		
    )
    Begin {}
    Process{
        if ($PsCmdlet.ParameterSetName -eq 'DefinitionUris') 
        {
            Write-Verbose -Message 'Create a Build Queue Spec from a list of Build DefinitionUri'
            $spec = $TFSCollection.BS.CreateBuildQueueSpec([System.Array]$DefinitionUris)
        }
        else 
        {
            Write-Verbose -Message "Create a Build Queue Spec for TeamProject [$TeamProject] and DefinitionName [$DefinitionName]"
            $spec = $TFSCollection.BS.CreateBuildQueueSpec($TeamProject,$DefinitionName)
        }

        if ($QueryOptions)
        {
            $spec.QueryOptions = $QueryOptions
        }
        if ($QueueStatus)
        {
            $spec.Status = $QueueStatus
        }
        if ($CompletedWindow)
        {
            $spec.CompletedWindow = $CompletedWindow
        }
        $spec
    }
    End {}
}


