function Get-TFSDefault
{
    [cmdletBinding()]
    param(
        [switch]
        $Force
    )
    begin
    {
        if ($Force)
        {
            $script:TFSDefault = $null
        }
        if (-not (Get-Variable -Name 'TFSDefault' -Scope Script -ErrorAction SilentlyContinue))
        {
            $file = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent) -ChildPath 'TFSDefault.json'
            $script:TFSDefault = Get-Content -Path $file | Out-String | ConvertFrom-Json |
                Select-Object -Property TfsConfigurationServerUrl, TfsCollectionUrl
        }
    }
    process
    { 
        $script:TFSDefault
    }
}