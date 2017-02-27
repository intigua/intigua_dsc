configuration Sample_RemoveIntigua
 {
    Import-DscResource -ModuleName Intigua
    Node localhost
    {                
        Connector InstallConnector
        {
            ConnectorVersion = "3.4.0.24"
            CoreServerUrl = "http://172.16.1.88:8080/vmanage-server/"
            Ensure = "Absent"
        }
    }
}
Sample_RemoveIntigua
Start-DscConfiguration -Path Sample_RemoveIntigua -Wait -Force -Verbose