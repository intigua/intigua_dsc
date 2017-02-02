# intigua_dsc

DSC Resources published  by [Intigua.Inc.](http://www.intigua.com)

The **Intigua** module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources.

## Installation

You can retrieve Resource through [PoweShellGet](https://www.powershellgallery.com/packages/Intigua).

## Resources

- **Agent**: Install an Managed Agent.

### Agent
- **`[String]` AgentName** _(Key)_: Agent name.
- **`[String]` AgentPath** _(Write)_: Agent path.
- **`[MSFT_KeyValuePair]` AgentParameters** _(Write)_: Agent parameters.
- **`[Boolean]` EnableMemoryAndCPUControl** _(Write)_: Enable memory and CPU control.
- **`[Uint32]` KeepManagedAgentCPUUtilizationUnder** _(Write)_: Keep managed agent CPU utilization under.
- **`[Uint32]` LimitManagedAgentMemoryConsumptionTo** _(Write)_: Limit managed agent memory consumption to.
- **`[Boolean]` AutomaticallyStartAgentUponFailure** _(Write)_: Automatically start agent upon failure.
- **`[Uint32]` MaximumNumberOfAutoStartsInADay** _(Write)_: Maximum number of auto starts in a day.
- **`[String]` IntiguaLogLevel** _(Write)_: Intigua log level. {Trace | Debug | info | Warning | Error | Fatal}.
- **`[String]` Ensure** _(Write)_: Determines whether the Agent should exist or not. { Present | Absent }. Defaults to Present.


## Directory tree

DirectoryName | Description
----|----
DSCResource | Contains DSC Resource source code.
Example | Contains examples of usage for the DSC resources.
