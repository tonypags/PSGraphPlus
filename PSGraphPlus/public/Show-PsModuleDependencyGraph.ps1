function Show-PsModuleDependencyGraph
{
    <#
    .SYNOPSIS
    Show the module dependency graph

    .DESCRIPTION
    Loads given module and maps out the dependencies

    .EXAMPLE
    start '"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"' (Show-PsModuleDependencyGraph -Name PsGraphPlus).fullname
    #>
    [CmdletBinding()]
    param(
        # Module Name
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    process
    {

        $module = Get-Module $Name -ListAvailable

        if ( $null -eq $module ) { return }

        $graph = graph modules  @{rankdir = 'LR'; pack = 'true'} {
            Node @{shape = 'box'}

            Node $module -NodeScript {$_.name} @{
                label = {'{0}' -f $_.Name}
            }

            $EdgeParam = @{
                Node       = $module | Where-Object {$_.RequiredModules}
                FromScript = {$_.Name}
                ToScript   = {$_.RequiredModules.Name}
            }
            Edge @EdgeParam

        }

        $graph | Export-PSGraph

    }
}
