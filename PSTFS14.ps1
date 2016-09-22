#requires -Version 3

Write-Verbose -Message 'Init PsTFS14 Module'

$Script:moduleRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
#where to put TFS Client OM files
$Script:omBinFolder = Join-Path -Path $ModuleRoot -ChildPath 'TfsLib'

# TFS Object Model Assembly Names

$Script:tfsNuget = @(
    'Microsoft.TeamFoundationServer.Client', 
    'Microsoft.TeamFoundationServer.ExtendedClient', 
    'Microsoft.VisualStudio.Services.Client', 
    'Microsoft.VisualStudio.Services.InteractiveClient'
)
function New-Folder 
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [string]
        $Path
    )
    begin
    {
    }
    process
    {
        if (!(Test-Path -Path $Path))
        {
            New-Item -ItemType Directory -Path $Path
        }
        else 
        {
            Get-Item -Path $Path
        }
    }
}

function Get-Nuget
{
    [cmdletBinding()]
    param()
    
    begin
    {
        #where to get Nuget.exe from
        $sourceNugetExe = 'http://nuget.org/nuget.exe'

        #where to save Nuget.exe too
        $targetNugetFolder = New-Folder -Path (Join-Path -Path $ModuleRoot -ChildPath 'Nuget')
        $targetNugetExe = Join-Path -Path $targetNugetFolder -ChildPath 'nuget.exe'

    }
    process
    {
        try
        {
            # check if we have gotten nuget before
            if (-not (Test-Path -Path $targetNugetExe))  
            {
                Invoke-WebRequest -Uri $sourceNugetExe -OutFile $targetNugetExe
            }
        }
        catch 
        {
            Write-Host -Object 'Caught an exception:' -ForegroundColor Red
            Write-Host -Object "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            Write-Host -Object "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        }

        #set an alias so we can use nuget syntactically the way we normally would
        Set-Alias -Name nugetEXE -Value $targetNugetExe -Scope Global -Verbose
    }
}

function Get-TfsNuget
{
    [cmdletbinding()]
    param()
    Begin
    {
        #clear out bin folder
        $targetOMbinFolder = New-Folder -Path $omBinFolder
        Remove-Item $targetOMbinFolder -Force -Recurse
        $targetOMbbinFolder = New-Folder -Path $omBinFolder
        $targetOMFolder = New-Folder -Path (Join-Path -Path $ModuleRoot -ChildPath 'TFSOM')

    }
    process
    {
    
        #get all of the TFS 2015 Object Model packages from nuget
        $Script:tfsNuget | 
        ForEach-Object -Process {
            nugetEXE install $_ -OutputDirectory $targetOMFolder -ExcludeVersion -NonInteractive
        }
        

        #Copy all of the required .dlls out of the nuget folder structure 
        #to a bin folder so we can reference them easily and they are co-located
        #so that they can find each other as necessary when loading
        $filesOrders = @('net45', 'net4*', 'native')
        Get-ChildItem -Path $targetOMFolder -Directory |
        ForEach-Object -Process {
            Write-Verbose -Message "Searching files to deploy: $_"
            $_ |
            Get-ChildItem -Filter 'lib' -Directory | 
            ForEach-Object -Process {
                $found = @()
                foreach ($platform in $filesOrders) 
                {
                    if ($found.Count -eq 0)
                    {
                        $found += $_ |
                        Get-ChildItem -Filter $platform -Directory |
                        Get-ChildItem -File -Filter '*.dll*' |
                        Copy-Item -Destination $targetOMbinFolder -PassThru
                        if ($found.Count -gt 0)
                        {
                            $found
                            break
                        }
                    }
                } 
                if ($found.Count -eq 0)
                {
                    Write-Warning -Message "No files deployed for folder: $_.RFullname"
                }
            }
        }
        
    }
}

function Import-TFSAssemblies
{
    [cmdletbinding()]
    param()
    begin
    {
        $tfsDll = @(
            'Microsoft.VisualStudio.Services.Common', 
            'Microsoft.TeamFoundation.Common', 
            'Microsoft.TeamFoundation.Client', 
            'Microsoft.TeamFoundation.VersionControl.Client', 
            'Microsoft.TeamFoundation.WorkItemTracking.Client', 
            'Microsoft.TeamFoundation.Build.Client', 
            'Microsoft.TeamFoundation.Build.Common'
        )
        $Script:TfsOM = @()
    }
    process
    {
        try 
        {
            $Script:TfsOM += Get-ChildItem -Path $omBinFolder -Filter '*.dll' |
            Where-Object -FilterScript {
                $tfsDll -contains $_.BaseName
            } |
            ForEach-Object -Process {
                Write-Host "Loading Assembly: $_.Fullname"
                Add-Type -LiteralPath $_.FullName
                $_.FullName
            }
        }
        catch 
        {
            Write-Host -Object 'Caught an exception:' -ForegroundColor Red
            Write-Host -Object "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            Write-Host -Object "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        }
       
    }
}

if ($true -or (!(Test-Path -Path $Script:omBinFolder) -or $PSBoundParameters.ContainsKey('Force')))
{
    Get-Nuget 
    if (!$Script:TfsOM) 
    {    
        Get-TfsNuget -Verbose
    }
    else
    {
        Write-Warning 'TFS OM Assemblies are in use and cannot be replaced.'
    }
    Import-TFSAssemblies
}
