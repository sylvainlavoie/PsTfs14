#requires -Version 3

<# 
        Load TFS Assemblies from nuget packages: http://www.westerndevs.com/tfs-module-in-powershell-using-nuget/

    #>
Write-Host $PSCommandPath

    $VerbosePreference = 'Continue'
Write-Verbose -Message 'Init PsTFS14 Module'


$Script:moduleRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
#where to put TFS Client OM files
$Script:omBinFolder = Join-Path -Path $ModuleRoot -ChildPath 'TfsLib'
$Script:omLoadFolder = Join-Path -Path $ModuleRoot -ChildPath 'TfsLoad'

#Add-Type -Path 'D:\Temp\Newtonsoft.Json.6.0.8\lib\net45\Newtonsoft.Json.dll'

$script:TFSAssemblyDll = @(
    [PSCustomObject]@{
        Name     = 'NewtonJson'
        Path     = ''
        Runtime  = ''
        Assembly = 'Newtonsoft.Json'
    },
    [PSCustomObject]@{
        Name     = 'IdentityModel'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.IdentityModel.Clients.ActiveDirectory'
    },
    [pscustomobject]@{
        Name     = 'VSCommon'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.VisualStudio.Services.Common'
    }, 
    [pscustomobject]@{
        Name     = 'VSCommonWebApi'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.VisualStudio.Services.WebApi'
    }, 
    #[pscustomobject]@{
    #    Name     = 'VSClient'
    #    Path     = ''
    #    Runtime  = ''
    #    Assembly = 'Microsoft.VisualStudio.Services.Client'
    #}, 
    [pscustomobject]@{
        Name     = 'TFCommon'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.Common'
    }, 
    [pscustomobject]@{
        Name     = 'TFClient'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.Client'
    }, 
    [pscustomobject]@{
        Name     = 'VCClient'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.VersionControl.Client'
    }, 
    [pscustomobject]@{
        Name     = 'WITClient'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.WorkItemTracking.Client'
    }, 
    [pscustomobject]@{
        Name     = 'BuildClient'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.Build.Client'
    }, 
    [pscustomobject]@{
        Name     = 'BuildCommon'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.Build.Common'
    },
    [PSCustomObject]@{
        Name     = 'Build2'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.Build2.WebApi'
    },
    [PSCustomObject]@{
        Name     = 'DistributedTask'
        Path     = ''
        Runtime  = ''
        Assembly = 'Microsoft.TeamFoundation.DistributedTask.WebApi'
    #},
    #[PSCustomObject]@{
    #    Name     = 'IdentityModel'
    #    Path     = ''
    #    Runtime  = ''
    #    Assembly = 'Microsoft.IdentityModel.Clients.ActiveDirectory'
    #},
    #[PSCustomObject]@{
    #    Name     = 'WebHttp'
    #    Path     = ''
    #    Runtime  = ''
    #    Assembly = 'System.Web.Http'
    }

    
    
            
)

# TFS Object Model Assembly Names

$Script:tfsNuget = @(
    #'Microsoft.TeamFoundationServer.ExtendedClient',
    #'Microsoft.TeamFoundationServer.Client',
    #'Microsoft.VisualStudio.Services.Client',
    #'Microsoft.VisualStudio.Services.InteractiveClient',
    #'Microsoft.VisualStudio.Services.DistributedTask.Client',
    #'Microsoft.VisualStudio.Services.Release.Client'

    
        #'Microsoft.TeamFoundationServer.ExtendedClient'
        #'Microsoft.TeamFoundationServer.Client', 
        #'Microsoft.TeamFoundationServer.ExtendedClient', 
        #'Microsoft.VisualStudio.Services.Client', 
        #'Microsoft.VisualStudio.Services.InteractiveClient'
  [PSCustomObject]@{id='Microsoft.AspNet.WebApi.Client'; version='5.2.2' },
  [PSCustomObject]@{id='Microsoft.AspNet.WebApi.Core'; version='5.2.2'},
  [PSCustomObject]@{id='Microsoft.IdentityModel.Clients.ActiveDirectory'; version='2.22.302111727'},
  [PSCustomObject]@{id='Microsoft.TeamFoundationServer.Client'; version='14.102.0' },
  [PSCustomObject]@{id='Microsoft.TeamFoundationServer.ExtendedClient'; version='14.102.0' },
  [PSCustomObject]@{id='Microsoft.VisualStudio.Services.Client'; version='14.102.0'},
  [PSCustomObject]@{id='Microsoft.VisualStudio.Services.InteractiveClient'; version='14.102.0' },
  [PSCustomObject]@{id='Microsoft.WindowsAzure.ConfigurationManager'; version='1.7.0.0' },
  [PSCustomObject]@{id='Newtonsoft.Json'; version='6.0.8' },
  [PSCustomObject]@{id='System.IdentityModel.Tokens.Jwt'; version='4.0.0' },
  [PSCustomObject]@{id='WindowsAzure.ServiceBus'; version='2.5.1.0' }
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
    param(
        [switch]
        $Force
        )
    
    begin
    {
        #where to get Nuget.exe from
        $sourceNugetExe = 'http://nuget.org/nuget.exe'

        #where to save Nuget.exe too
        $targetNugetFolder = New-Folder -Path (Join-Path -Path $script:ModuleRoot -ChildPath 'Nuget')
        $targetNugetExe = Join-Path -Path $targetNugetFolder -ChildPath 'nuget.exe'

    }
    process
    {
        try
        {
            # check if we have gotten nuget before
            if (-not (Test-Path -Path $targetNugetExe) -or $Force)  
            {
                Invoke-WebRequest -Uri $sourceNugetExe -OutFile $targetNugetExe
                #set an alias so we can use nuget syntactically the way we normally would
                Set-Alias -Name call_nuget -Value $targetNugetExe -Scope Global 
                Write-Verbose ((call_nuget update -self) |Out-String)
            }
            
        }
        catch 
        {
            Write-Host -Object 'Caught an exception:' -ForegroundColor Red
            Write-Host -Object "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            Write-Host -Object "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        }

        #set an alias so we can use nuget syntactically the way we normally would
        Set-Alias -Name call_nuget -Value $targetNugetExe -Scope Global 

        
    }
}



function Get-TfsNuget
{
    [cmdletbinding()]
    param(
        [switch]
        $Force
    )
    Begin
    {
        #clear out bin folder
        $targetOMbinFolder = New-Folder -Path $script:omBinFolder
        $targetOMFolder = New-Folder -Path (Join-Path -Path $Script:ModuleRoot -ChildPath 'TFSOM')
        if ($Force)
        { 
            Remove-Item $targetOMbinFolder -Force -Recurse
            $targetOMbbinFolder = New-Folder -Path $script:omBinFolder
        }

    }
    process
    {
    
        #get all of the TFS 2015 Object Model packages from nuget
        $isPackageMissing = $false
        if (!$Force)
        {
            $Script:tfsNuget | ForEach-Object {
                $isPackageMissing = $isPackageMissing -or -not (Test-Path -Path (Join-Path -Path $targetOMFolder -ChildPath $_.id))
            }
        }
        
        if ($Force -or $isPackageMissing) 
        { 
            $Script:tfsNuget | 
            ForEach-Object -Process {
                call_nuget install $_.Id -version $_.version -OutputDirectory $targetOMFolder -ExcludeVersion -NonInteractive |
                ForEach-Object {
                    $new = $new -or ($out -match 'installing|successfully\sinstalled')
                    Write-Verbose $_
                }
            } 
            
        }
        Copy-NewBinaries -Path $targetOMFolder -Verbose:($PSBoundParameters.Verbose -eq $true) 
        
        
                
    }
}


function Copy-NewBinaries 
{
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]
        $Path
        )
    begin
    {
        #Copy all of the required .dlls out of the nuget folder structure 
        #to a bin folder so we can reference them easily and they are co-located
        #so that they can find each other as necessary when loading
        $filesOrders = @('net45', 'net4*', 'native','net3*')
    }
    process
    {
        
        Get-ChildItem -Path $Path -Directory |
        ForEach-Object {
            $mod = $_
            Write-Host "Copy module binaries for loading $_"
            $mod | Get-ChildItem -Filter 'lib' -Directory | ForEach-Object -Process {
                $lib = $_
                foreach ($platform in $filesOrders) 
                {
                    $dir = $lib | Get-ChildItem -Filter $platform -Directory
                    if ($dir)
                    {
                        $dest = New-Folder -path $Script:omBinFolder #(Join-Path $Script:omBinFolder -ChildPath $mod.BaseName)
                        $dir | Get-ChildItem | Copy-Item  -Destination $dest -Force 
                        break
                    }
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
        try
        { 
            Write-Verbose "Deploy TFS OM assemblies for loading $($Script:omBinFolder) -> $($Script:omLoadFolder)" 
            $ErrorActionPreference = 'SilentlyContinue'
            Get-ChildItem -Path $Script:omBinFolder -file |
                Copy-Item -Destination (New-Folder $Script:omLoadFolder) -Force  -ErrorAction Ignore -ErrorVariable err
        }
        catch{}
       
    }
    process
    {
        try 
        {
             
            $load = (New-Folder $Script:omLoadFolder)
            $script:TFSAssemblyDll |
                ForEach-Object { 
                    $load | Get-ChildItem  -Filter "$($_.Assembly).dll"  |
                        ForEach-Object -Process {
                            Write-Host "Load Assembly: $($_.FullName)"
                           
                            Add-Type -Path $_.FullName
                            Write-Verbose "Assembly loaded from $($_.FullName)"
                        }

                }
                
        }
        catch 
        {
            Write-Host -Object 'Caught an exception:' -ForegroundColor Red
            Write-Host -Object "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            Write-Host -Object "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Loader Exception: $($_.Exception.LoaderExceptions)" -ForegroundColor Red
        }
       
    }
}


#Get-Nuget -verbose # -Verbose:$PSBoundParameters.ContainsKey('Verbose') -Force:$PSBoundParameters.ContainsKey('Force')
# Get-TfsNuget -Verbose #:$PSBoundParameters.ContainsKey('Verbose') -Force:$PSBoundParameters.ContainsKey('Force')

Import-TFSAssemblies -Verbose #:$PSBoundParameters.ContainsKey('Verbose')