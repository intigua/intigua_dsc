
configuration Sample_IntiguaCustomParameters
 {
    Import-DscResource -ModuleName Intigua
    Node localhost
    {
        Connector InstallConnector
        {
            ConnectorVersion = "3.4.0.24"
            CoreServerUrl = "http://172.16.1.1/vmanage-server/"
			FallbackCoreServerUrl = "http://172.16.1.2/vmanage-server/"
			ThrottlingEnabled = $true
			MaxCpuPercent = 90
			MaxMemoryKB = 2000000
			InstallLocation = "%ProgramFiles%\Intigua_test"
            Ensure = "Present"
        }
    }
}

Sample_IntiguaCustomParameters
Start-DscConfiguration -Path Sample_IntiguaCustomParameters-Wait -Force -Verbose