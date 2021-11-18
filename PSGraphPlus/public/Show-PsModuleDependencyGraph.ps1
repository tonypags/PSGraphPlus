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

        $module = Get-ChildModule $Name -Recurse -IncludeParent

        if ( $null -eq $module ) { return }

        $graph = graph modules  @{pack = 'true'} {
            Node @{shape = 'box'}

            Node $module -NodeScript {$_.Guid} @{
                label = {'{0}\n{1}\n{2}' -f $_.Name,$_.Version,$_.Description}
            }

            $EdgeParam = @{
                Node       = $module | Where-Object {$_.RequiredModules}
                FromScript = {$_.RequiredModules.Guid}
                ToScript   = {$_.Guid}
            }
            Edge @EdgeParam

        }

        $graph | Export-PSGraph

    }
}

function Get-ChildModule {
    [CmdletBinding()]
    param (
        [Parameter(
            Position=0,
            ValueFromPipeline,
            ValueFromRemainingArguments,
            ValueFromPipelineByPropertyName
        )]
        [Alias('ModuleName','Name')]
        [string[]]
        $Module,

        [switch]
        $Recurse,

        # Also returns the module info for the given Module(s)
        [switch]
        $IncludeParent
    )

    begin {
        # $ColumnOrder = @(
        #     'Name'
        #     'Version'
        #     'Path'
        #     'Guid'
        #     'ModuleBase'
        #     'Tags'
        #     'ProjectUri'
        #     'Author'
        #     'RequiredModules'
        # )
    }

    process {

        foreach ($item in $Module) {

            if ($IncludeParent) {
                Get-Module $item
            }

            $Children = (
                Get-Module $item -ListAvailable
            ).RequiredModules.Name
            
            foreach ($child in $Children) {

                Get-Module $Child

                if ($Recurse) {
                    Get-ChildModule $child -Recurse
                }

            }

        }

    }

    end {

    }

}#END: function Get-ChildModule
