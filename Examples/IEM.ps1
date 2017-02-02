configuration IEM
 {
    Import-DscResource -ModuleName Intigua

    Node IEMAbsent
    {                
        Agent IEM
        {
            AgentPath = "https://intiguadsc.blob.core.windows.net/agents/iem_lw_Windows_x64_9.1_2.9.0.378.vai"
            AgentName = "iem"
            AgentParameters = @{ACTIVE_SITE_PATH="c:\ActionSite.afxm"}
            EnableMemoryAndCPUControl = $true
            KeepManagedAgentCPUUtilizationUnder = 30
            LimitManagedAgentMemoryConsumptionTo = 512
            AutomaticallyStartAgentUponFailure = $true
            MaximumNumberOfAutoStartsInADay = 10
            IntiguaLogLevel = "Error"
            Ensure = "Absent"
        }
    }
    Node IEMPresent
    {                
        Agent IEM
        {
            AgentPath = "https://intiguadsc.blob.core.windows.net/agents/iem_lw_Windows_x64_9.1_2.9.0.378.vai"
            AgentName = "iem"
            AgentParameters = @{ACTIVE_SITE_PATH="c:\ActionSite.afxm"}
            EnableMemoryAndCPUControl = $true
            KeepManagedAgentCPUUtilizationUnder = 30
            LimitManagedAgentMemoryConsumptionTo = 512
            AutomaticallyStartAgentUponFailure = $true
            MaximumNumberOfAutoStartsInADay = 10
            IntiguaLogLevel = "Error"
            Ensure = "Present"
        }
    }
}

IEM
