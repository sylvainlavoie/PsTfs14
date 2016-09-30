#requires -Version 3

function Set-TFSDefault
{
    [cmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $ConfigurationServerUrl,
        [parameter(Mandatory)]
        [string]
        $CollectionUrl

    )
    begin
    {
        Remove-Variable -Name TFSDefault -Scope script -ErrorAction SilentlyContinue
    }
    process
    { 
        $file = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent) -ChildPath 'TFSDefault.json'
        

        [PSCustomObject]@{
            TfsConfigurationServerUrl = $ConfigurationServerUrl
            TfsCollectionUrl          = $CollectionUrl
        } | 
        ConvertTo-Json | 
        Out-File -FilePath $file -Force
    }
}
