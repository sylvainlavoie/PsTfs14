function Add-ObjectTypeDetails
{
    <#
    .SYNOPSIS
        Decorate an object with
            - A TypeName
            - New properties
            - Default parameters

    .DESCRIPTION
        Helper function to decorate an object with
            - A TypeName
            - New properties
            - Default parameters 

    .PARAMETER InputObject
        Object to decorate. Accepts pipeline input.

    .PARAMETER TypeName
        Typename to insert.
        
        This will show up when you use Get-Member against the resulting object.
        
    .PARAMETER PropertyToAdd
        Add these noteproperties.
        
        Format is a hashtable with Key (Property Name) = Value (Property Value).

        Example to add a One and Date property:

            -PropertyToAdd @{
                One = 1
                Date = (Get-Date)
            }

    .PARAMETER DefaultProperties
        Change the default properties that show up

    .PARAMETER Passthru
        Whether to pass the resulting object on. Defaults to true

    .EXAMPLE
        #
        # Create an object to work with
        $Object = [PSCustomObject]@{
            First = 'Cookie'
            Last = 'Monster'
            Account = 'CMonster'
        }

        #Add a type name and a random property
        Add-ObjectDetail -InputObject $Object -TypeName 'ApplicationX.Account' -PropertyToAdd @{ AnotherProperty = 5 }

            # First  Last    Account  AnotherProperty
            # -----  ----    -------  ---------------
            # Cookie Monster CMonster               5

        #Verify that get-member shows us the right type
        $Object | Get-Member

            # TypeName: ApplicationX.Account ...

    .EXAMPLE
        #
        # Create an object to work with
        $Object = [PSCustomObject]@{
            First = 'Cookie'
            Last = 'Monster'
            Account = 'CMonster'
        }

        #Add a random property, set a default property set so we only see two props by default
        Add-ObjectDetail -InputObject $Object -PropertyToAdd @{ AnotherProperty = 5 } -DefaultProperties Account, AnotherProperty

            # Account  AnotherProperty
            # -------  ---------------
            # CMonster               5

        #Verify that the other properties are around
        $Object | Select -Property *

            # First  Last    Account  AnotherProperty
            # -----  ----    -------  ---------------
            # Cookie Monster CMonster               5

    .NOTES
        This breaks the 'do one thing' rule from certain perspectives...
        The goal is to decorate an object all in one shot
   
        This abstraction simplifies decorating an object, with a slight trade-off in performance. For example:

        10,000 objects, add a property and typename:
            Add-ObjectDetail:                        ~4.6 seconds
            Add-Member + PSObject.TypeNames.Insert:  ~3 seconds

        Initial code borrowed from Shay Levy:
        http://blogs.microsoft.co.il/scriptfanatic/2012/04/13/custom-objects-default-display-in-powershell-30/
    #>
    [CmdletBinding()] 
    param(
           [Parameter( Mandatory = $true,
                       Position=0,
                       ValueFromPipeline=$true )]
           [ValidateNotNullOrEmpty()]
           [psobject[]]$InputObject,

           [Parameter( Mandatory = $false,
                       Position=1)]
           [string]$TypeName,

           [Parameter( Mandatory = $false,
                       Position=2)]    
           [object[]]$PropertyToAdd,

           [Parameter( Mandatory = $false,
                       Position=3)]
           [ValidateNotNullOrEmpty()]
           [Alias('dp')]
           [System.String[]]$DefaultProperties,

           [boolean]$Passthru = $True
    )
    
    Begin
    {
        if($PSBoundParameters.ContainsKey('DefaultProperties'))
        {
            # define a subset of properties
            $ddps = New-Object System.Management.Automation.PSPropertySet DefaultDisplayPropertySet,$DefaultProperties
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$ddps
        }
    }
    Process
    {
        foreach($Object in $InputObject)
        {
            switch ($PSBoundParameters.Keys)
            {
                'PropertyToAdd'
                {
                    foreach($prop in $PropertyToAdd)
                    {
                        $name = $null
                        $value = $null
                        if ($prop -is [hashtable])
                        {
                            if ($prop.ContainsKey('n')) { $name = $prop['n'] }
                            if ($prop.ContainsKey('name')) { $name = $prop['name'] }
                            
                            if ($prop.ContainsKey('e')) { $value = $Object | ForEach $prop['e'] }
                            if ($prop.ContainsKey('expression')) { $value = $Object | ForEach $prop['expression'] }
                            if ($Prop.Keys.Count -eq 1) 
                            {
                                $name = $prop.Keys[0] 
                                if (($prop[$name] | Get-Member ast))
                                {
                                    $value = $Object | ForEach $prop[$name]
                                }
                                else
                                { 
                                    $value = $prop[$name]
                                }
                            }
                        } 
                        #Add some noteproperties. Slightly faster than Add-Member.
                        if ($Object.PSObject.Properties[$name])
                        {
                            $Object.PSObject.Properties.Remove($name)
                        }
                        $Object.PSObject.Properties.Add( ( New-Object PSNoteProperty($name, $value) ) )  
                    }
                }
                'TypeName'
                {
                    #Add specified type
                    [void]$Object.PSObject.TypeNames.Insert(0,$TypeName)
                }
                'DefaultProperties'
                {
                    # Attach default display property set
                    Add-Member -InputObject $Object -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -Force
                }
            }
            if($Passthru)
            {
                $Object
            }
        }
    }
}