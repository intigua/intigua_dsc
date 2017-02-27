$ErrorActionPreference = "stop"
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

        GetConnectorDetails = Connector details are: Version - '{0}'.
        FoundIntiguaExe = Found Intigua.exe version - '{0}'.
        RemovingConnector = Going to remove connector.
        AbsentMessage = Ensure parameter is Absent.
        PresentMessage = Ensure parameter is Present.
        DownloadingConnector = Going to download Connector from '{0}' to '{1}'
        DeleteFile = Going to delete File '{0}'
        
"@
}


Data ErrorMessages {
    ConvertFrom-StringData -StringData @"
        DidNotFindIntiguaExe = ERROR: Could not found Intigua.exe.        
"@
}


#############
#   UTILS   #
#############

function DownloadFile
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [string] $src,
        [string] $dst
    )
    Write-Verbose ($VerboseMessages.DownloadingConnector -f $src, $dst);
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

#################
#   CONNECTOR   #
#################

function GetConnectorExe
{
    [OutputType([string])]
    [CmdletBinding()]

    param( )
    
    # Get Intigua.exe path
    $IntiguaRootDir = (Get-ItemProperty "hklm:\VMI\setup\").IntiguaRootDir;
    try{
        $intiguaPath = Join-Path $IntiguaRootDir "..\Intigua-Utils\Intigua.exe" -Resolve -ErrorAction SilentlyContinue;
    } catch {
        throw New-Object System.IO.FileNotFoundException ($ErrorMessages.DidNotFindIntiguaExe);
    }
    

    # Check that Intigua.exe is exist
    if (-Not $intiguaPath)
    {
        Write-Verbose $ErrorMessages.DidNotFindIntiguaExe;
        throw New-Object System.IO.FileNotFoundException ($ErrorMessages.DidNotFindIntiguaExe);
    }
    return $intiguaPath;
}

function IsConnectorInstalled
{
    [OutputType([string])]
    [CmdletBinding()]
    
    # Get Intigua.exe path
    param( )
    try{
        $IntiguaRootDir = (Get-ItemProperty "hklm:\VMI\setup\").IntiguaRootDir;
        $intiguaPath = Join-Path $IntiguaRootDir "..\Intigua-Utils\Intigua.exe" -Resolve -ErrorAction SilentlyContinue;
    } catch {
        return $false
    }

    # Check that Intigua.exe is exist
    if (-Not $intiguaPath)
    {
        Write-Verbose $ErrorMessages.DidNotFindIntiguaExe;
        return $false
    }
    return $true;
}

function VersionCompare
{
    
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [string] $version1,
        [string] $version2
    )
    if ($ConnectorVersion -eq $InstalledConnectorVersion)
    {
        return $true;
    } else {
        return $false;
    }
}



function getConnectorVersion
{
    $intiguaPath = GetConnectorExe;
    $version = (Get-Item $intiguaPath).VersionInfo.FileVersion
    Write-Verbose ($VerboseMessages.FoundIntiguaExe -f $version);
    return $version
}


###########
#   DSC   #
###########

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $ConnectorVersion,

        [parameter(Mandatory = $true)]
        [System.String] $CoreServerUrl,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure
    )

    Write-Verbose ($VerboseMessages.GetConnectorDetails -f $ConnectorVersion);

    $returnValue = @{
        ConnectorVersion = $ConnectorVersion
        Ensure = $Ensure
        CoreServerUrl = $CoreServerUrl
    }
    $returnValue
} # Get-TargetResource


function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $ConnectorVersion,

        [parameter(Mandatory = $true)]
        [System.String] $CoreServerUrl,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure
    )

    Write-Verbose ($VerboseMessages.GetConnectorDetails -f $ConnectorVersion);
    $connectorInstalled = IsConnectorInstalled;

    if ($Ensure -eq [EnsureType]::Absent.ToString())
    {
        Write-Verbose ($VerboseMessages.AbsentMessage);
        if ($connectorInstalled)
        {
            Write-Verbose ($VerboseMessages.RemovingConnector);
            $intiguaPath = GetConnectorExe;            
            & $intiguaPath rmc -f;
        }
    }
    else
    {
        Write-Verbose ($VerboseMessages.PresentMessage);
        if (-Not ($connectorInstalled))
        {
            Write-Verbose "Connector does not installed! going to download and install it";
            $tempFileName = "vlink-win-win32_x64-Release-{0}.exe" -f $ConnectorVersion;
            $fullPath = GetPathInTemp $tempFileName
            DeleteFile $fullPath;
            $downloadUrl = "https://intiguadsc.blob.core.windows.net/connector/vlink-win-win32_x64-Release-{0}.exe" -f $ConnectorVersion
            DownloadFile -src $downloadUrl -dst $fullPath;
            
            $arg1 = "-coreserverurl={0}" -f $CoreServerUrl
			& $fullPath $arg1
			
            Start-Sleep -s 10
            DeleteFile $fullPath;
        }
        # Check that the connector is in the right version. If not we will upgrade/downgrade it usign VAI file
        else
        {
            Write-Verbose "Connector Installed! checking version";
            $InstalledConnectorVersion = getConnectorVersion;            
            $rightVersion = VersionCompare $ConnectorVersion $InstalledConnectorVersion
            if (-Not ($rightVersion))
            {
                Write-Verbose "Connector is not in the right version - going to download new VAI for upgrade";
                $tempFileName = "vlink_Windows_all-arch_{0}_1.0_Release.vai" -f $ConnectorVersion;
                $fullPath = GetPathInTemp $tempFileName
                DeleteFile $fullPath;
                $downloadUrl = "https://intiguadsc.blob.core.windows.net/connector/vlink_Windows_all-arch_{0}_1.0_Release.vai" -f $ConnectorVersion
                DownloadFile -src $downloadUrl -dst $fullPath;                

                $IntiguaRootDir = (Get-ItemProperty "hklm:\VMI\setup\").IntiguaRootDir;
                try{
                    $commandsFolder = Join-Path $IntiguaRootDir ".\channel\commands" -Resolve -ErrorAction SilentlyContinue;
                } catch {
                    throw New-Object System.IO.FileNotFoundException ($ErrorMessages.DidNotFindIntiguaExe);
                }

                $tempCommand = "{0}\_command" -f $commandsFolder

                Move-Item $fullPath $tempCommand
                Rename-Item $tempCommand "command"

                DeleteFile $fullPath;
            }
        }

        
    }



} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String] $ConnectorVersion,

        [parameter(Mandatory = $true)]
        [System.String] $CoreServerUrl,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure
    )


    Write-Verbose ($VerboseMessages.GetConnectorDetails -f $ConnectorVersion);

    $rightVersion = $false
    $connectorInstalled = IsConnectorInstalled;

    if ($connectorInstalled)
    {
        $InstalledConnectorVersion = getConnectorVersion;
        $rightVersion = VersionCompare $ConnectorVersion $InstalledConnectorVersion
    }

    # Check Ensure parameter is Present
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        # Because the Ensure is "Present" we need to return True if the Connector exist in the right version
        if ($connectorInstalled -and $rightVersion)
        {
            return $true;
        } else {
            return $false;
        }
    }
    else
    {
        # Because the Ensure is "Absent" we need to return True if the Connector does not exist
        if ($connectorInstalled)
        {
            return $false
        } else {
            return $true
        }
    }

} # Test-TargetResource

Export-ModuleMember -Function *-TargetResource
