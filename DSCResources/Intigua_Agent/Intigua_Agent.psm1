function Initialize
{
    # hosts location
    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue; 
}

. Initialize;



Data VerboseMessages {
    ConvertFrom-StringData -StringData @"

        GetAgentDetails = Agent details are: Agent Name - '{0}, Agent Path -'{1}', Agent Parameters '{2}'.        
        FoundIntiguaExe = Found Intigua.exe.
        FoundAgent = Agent '{0}' has been found.
        RemovingAgent = Going to remove agent - '{0}'
        DeployingAgent = Going to deploy agent - '{0}', using command '{1}'
        DownloadingAgent = Going to download agent from '{0}' to '{1}'
        AbsentMessage = Ensure parameter is Absent.
        PresentMessage = Ensure parameter is Present.
        DeleteFile = Going to delete File '{0}'
        
"@
}


Data ErrorMessages {
    ConvertFrom-StringData -StringData @"
        DidNotFindIntiguaExe = ERROR: Could not found Intigua.exe.
        MissingAgent = ERROR: Agent '{0}' does not exist in Intigua.
"@
}


function DownloadFile
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [string] $src,
        [string] $dst
    )
    Write-Verbose ($VerboseMessages.DownloadingAgent -f $src, $dst);
    (New-Object System.Net.WebClient).DownloadFile($src, $dst)
}


function GetPathInTemp
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [string] $p
    )
    $f = Split-Path $p -leaf;
    $fullPath = Join-Path $env:TEMP $f;
    return $fullPath;
}


function DeleteFile
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [string] $fullPath
    )	
    if (Test-Path $fullPath)
    {
        Write-Verbose ($VerboseMessages.DeleteFile -f $fullPath);
        Remove-Item -Path $fullPath -Force
    }
}


function GetConnectorExe
{
    [OutputType([string])]
    [CmdletBinding()]

    $IntiguaRootDir = (Get-ItemProperty "hklm:\VMI\setup\").IntiguaRootDir;
    
    # Get Intigua.exe path
    $IntiguaRootDir = (Get-ItemProperty "hklm:\VMI\setup\").IntiguaRootDir;
    $intiguaPath = Join-Path $IntiguaRootDir "..\Intigua-Utils\Intigua.exe" -Resolve -ErrorAction SilentlyContinue;

    # Check that Intigua.exe is exist
    if (-Not $intiguaPath)
    {
        Write-Verbose $ErrorMessages.DidNotFindIntiguaExe;
        throw New-Object System.IO.FileNotFoundException ($ErrorMessages.DidNotFindIntiguaExe);
    }
    return $intiguaPath;
}


function IsAgentExist
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [string] $AgentName,
        [string] $intiguaPath
    )
    # Check if agent exist as Intigua Agent
    $output = & $intiguaPath val	
    if ($output -like '*'+$AgentName+'*')
    {
        # Found agent in Intigua
		Write-Verbose ($VerboseMessages.FoundAgent -f $AgentName);	
        $AgentExist = $true
    }
	else
	{		
		# Didn't found agent in Intigua
		Write-Verbose ($ErrorMessages.MissingAgent -f $AgentName);
		$AgentExist = $false
	}
    return $AgentExist;
}


function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [System.String] $AgentPath,

        [parameter(Mandatory)]
        [System.String] $AgentName,

        [parameter(Mandatory)]
        [System.Collections.Hashtable] $AgentParameters,
		
        [System.String] $EnableMemoryAndCPUControl = "True",
		
        [uint32] $KeepManagedAgentCPUUtilizationUnder = 30,
		
        [uint32] $LimitManagedAgentMemoryConsumptionTo = 512,
		
        [System.String] $AutomaticallyStartAgentUponFailure = "True",
		
        [uint32] $MaximumNumberOfAutoStartsInADay = 10,
		
        [System.String] $IntiguaLogLevel = "Error",

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure
    )

    Write-Verbose ($VerboseMessages.GetAgentDetails -f $AgentName, $AgentPath, ($AgentParameters | Out-String));

    $returnValue = @{
        AgentPath = $AgentPath
        AgentName = $AgentName
        AgentParameters = $AgentParameters
        EnableMemoryAndCPUControl = $EnableMemoryAndCPUControl
        KeepManagedAgentCPUUtilizationUnder = $KeepManagedAgentCPUUtilizationUnder
        LimitManagedAgentMemoryConsumptionTo = $LimitManagedAgentMemoryConsumptionTo
        AutomaticallyStartAgentUponFailure = $AutomaticallyStartAgentUponFailure
        MaximumNumberOfAutoStartsInADay = $MaximumNumberOfAutoStartsInADay
        IntiguaLogLevel = $IntiguaLogLevel
        Ensure = $Ensure
    }
    $returnValue
} # Get-TargetResource


function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [System.String] $AgentPath,

        [parameter(Mandatory)]
        [System.String] $AgentName,

        [parameter(Mandatory)]
        [System.Collections.Hashtable] $AgentParameters,
		
        [System.String] $EnableMemoryAndCPUControl = "True",
		
        [uint32] $KeepManagedAgentCPUUtilizationUnder = 30,
		
        [uint32] $LimitManagedAgentMemoryConsumptionTo = 512,
		
        [System.String] $AutomaticallyStartAgentUponFailure = "True",
		
        [uint32] $MaximumNumberOfAutoStartsInADay = 10,
		
        [System.String] $IntiguaLogLevel = "Error",

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    Write-Verbose ($VerboseMessages.GetAgentDetails -f $AgentName, $AgentPath, ($AgentParameters | Out-String));
    $intiguaPath = GetConnectorExe;
    $AgentExist = IsAgentExist -AgentName $AgentName -IntiguaPath $intiguaPath;

    if ($Ensure -eq [EnsureType]::Absent.ToString())
    {
        Write-Verbose ($VerboseMessages.AbsentMessage -f $AgentName);
        if ($AgentExist)
        {
            Write-Verbose ($VerboseMessages.RemovingAgent -f $AgentName);
            & $intiguaPath rma $AgentName -f;
        }
    }
    else
    {
        Write-Verbose ($VerboseMessages.PresentMessage -f $AgentName);
        if (-Not ($AgentExist))
        {
            $fullPath = GetPathInTemp $AgentPath;
            # DeleteFile $fullPath;
            # DownloadFile -src $AgentPath -dst $fullPath;
            
            # Build Parameters for CLI command
            $commandParameters = "-f " ;
            foreach ($key in $AgentParameters.Keys)
            {
	            $value = $AgentParameters.$key;
	            $commandParameters = $commandParameters + $key + ' ' + '"' + $value + '" ';
            }
            $intiguaPath = GetConnectorExe;            
            Write-Verbose ($VerboseMessages.DeployingAgent -f $AgentName, ($intiguaPath + ' d ' + $fullPath  + " " + $commandParameters));            
			
            # We are writing the command line into batch file because we have problem to run the following line:
			# & $intiguaPath d $fullPath $commandParameters -f
			# because the Connector see $commandParameters as 1 arg and it dow not split it as regular command line
			
			$tmpCmd = GetPathInTemp "IntiguaCommand.bat"
            DeleteFile $tmpCmd
			Write-Output '"'$intiguaPath'" ' d ' "'$fullPath'" ' $commandParameters | Out-File $tmpCmd -NoNewLine -encoding ASCII
			& $tmpCmd
			DeleteFile $tmpCmd
			
            
            
            
        }
        
    }



} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [System.String] $AgentPath,

        [parameter(Mandatory)]
        [System.String] $AgentName,

        [parameter(Mandatory)]
        [System.Collections.Hashtable] $AgentParameters,
		
        [System.String] $EnableMemoryAndCPUControl = "True",
		
        [uint32] $KeepManagedAgentCPUUtilizationUnder = 30,
		
        [uint32] $LimitManagedAgentMemoryConsumptionTo = 512,
		
        [System.String] $AutomaticallyStartAgentUponFailure = "True",
		
        [uint32] $MaximumNumberOfAutoStartsInADay = 10,
		
        [System.String] $IntiguaLogLevel = "Error",

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure
    )


    $AgentExist = False
    
    Write-Verbose ($VerboseMessages.GetAgentDetails -f $AgentName, $AgentPath, ($AgentParameters | Out-String));
    $intiguaPath = GetConnectorExe;
    $AgentExist = IsAgentExist -AgentName $AgentName -IntiguaPath $intiguaPath;

    # Check Ensure parameter is Present
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        # Because the Ensure is "Present" we need to return True if the agent exist
        return $AgentExist;
    }
    else
    {
        # Because the Ensure is "Absent" we need to return True if the agent does not exist
        return -Not $AgentExist;
    }



} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
