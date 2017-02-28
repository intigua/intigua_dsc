# intigua_dsc

DSC Resources published  by [Intigua.Inc.](http://www.intigua.com)

The **Intigua** module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources.

## Installation

You can retrieve Resource through [PoweShellGallery](https://www.powershellgallery.com/packages/Intigua).

## Resources

- **Agent**: Install an Managed Agent.
- **Connector**: Install Intigua Connector.

### Agent
- **`[String]` AgentName** _(Key)_: Agent name.
- **`[String]` AgentPath** _(Write)_: Agent path.
- **`[MSFT_KeyValuePair]` AgentParameters** _(Write)_: Agent parameters.
- **`[Boolean]` EnableMemoryAndCPUControl** _(Write)_: Enable memory and CPU control. _(optional)_
- **`[Uint32]` KeepManagedAgentCPUUtilizationUnder** _(Write)_: Keep managed agent CPU utilization under. _(optional)_
- **`[Uint32]` LimitManagedAgentMemoryConsumptionTo** _(Write)_: Limit managed agent memory consumption to. _(optional)_
- **`[Boolean]` AutomaticallyStartAgentUponFailure** _(Write)_: Automatically start agent upon failure. _(optional)_
- **`[Uint32]` MaximumNumberOfAutoStartsInADay** _(Write)_: Maximum number of auto starts in a day. _(optional)_
- **`[String]` IntiguaLogLevel** _(Write)_: Intigua log level. {Trace | Debug | info | Warning | Error | Fatal}. _(optional)_
- **`[String]` Ensure** _(Write)_: Determines whether the Agent should exist or not. {Present | Absent}. Defaults to Present.

### Connector
- **`[String]` ConnectorVersion** _(Key)_: Full Connector Version.
- **`[String]` CoreServerUrl** _(Write)_: Core Server URL.
- **`[String]` FallbackCoreServerUrl** _(Write)_: Fallback Core Server URL. _(optional)_
- **`[Boolean]` ThrottlingEnabled** _(Write)_: Enable Throttling. _(optional)_
- **`[Uint32]` MaxCpuPercent** _(Write)_: Total allowed CPU utilization by all managed agent containers. _(optional)_
- **`[Uint32]` MaxMemoryKB** _(Write)_: Total allowed memory consumption by all managed agent containers. _(optional)_
- **`[String]` InstallLocation** _(Write)_: "Connector install location. _(optional)_
- **`[String]` Ensure** _(Write)_: Determines whether the Agent should exist or not. {Present | Absent}. Defaults to Present.

## Directory tree
DirectoryName | Description
----|----
DSCResource | Contains DSC Resource source code.
Example | Contains examples of usage for the DSC resources.

## Notes
1. The Connector DSC Resoruce does not support re-configuration if Connector is already installed on the machine.
