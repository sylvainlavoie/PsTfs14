#requires -Version 2
<#
        .SYNOPSIS
        Get a Team Foundation Server (TFS) Configuration Server object
        .DESCRIPTION
        The TFS Configuration Server is used for basic authentication and represents
        a connection to the server that is running Team Foundation Server.
        .EXAMPLE
        Get-TfsConfigServer "&lt;Url to TFS&gt;"
        .EXAMPLE
        Get-TfsConfigServer "http://localhost:8080/tfs"
        .EXAMPLE
        gtfs "http://localhost:8080/tfs"
        .PARAMETER url
        The Url of the TFS server that you'd like to access
#>
function Get-TFSConfigServer() 
{
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({

        })]
        [string]$url = ((Get-TFSDefault).TfsConfigurationServerUrl)
        
    )
    begin 
    {
        
    }
    process {
        If ([String]::IsNullOrEmpty($_)) 
        {
            Throw "$_ is not a Valid TFS Configuration Server URL!"
        }
    
        $retVal = [Microsoft.TeamFoundation.Client.TfsConfigurationServerFactory]::GetConfigurationServer($url)
        
        [void]$retVal.Authenticate()
        if(!$retVal.HasAuthenticated)
        {
            Write-Verbose -Message "TFS Configuration Server Not Authenticated. [$($retVal.Uri)]"
        }
        else 
        {
            Write-Verbose -Message "TFS Configuration Server Authenticated. [$($retVal.Uri)]"
        }
        $retVal
    }
    end {
        Write-Verbose -Message 'ConfigurationServer object created.'
    }
} #end Function Get-TfsConfigServer