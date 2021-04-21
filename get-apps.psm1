
Function Get-ListofApplications{
<# 

    .DESCRIPTION
        Get-ListofApplications is an advanced function which can be used to get installed applications on a local or remote computer.

    .PARAMETER    ComputerFilePath
        Specifies the path to the txt file. This file should contain one or more computers.


    .EXAMPLE
        C:\PS> Get-ListofApplications -CNPath C:\Users\taylor\ComputerList.txt

        This command specifies the path to an item  that contains several computers. Then 'Get-ListofApplications' cmdlet will list installed applications on those computers.
#>
    
    [CmdletBinding(DefaultParameterSetName="First")]
    Param(
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="First")]
    [Alias('CName')][String[]]$ComputerName,
    [Parameter(Mandatory=$true, Position=1, ParameterSetName="Second")]
    [Alias('CNPath')][String]$ComputerFilePath
    )

Function FindInstalledApplicationInfo($ComputerName){
    
    $Objs = @()
    $RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

    $InstalledAppsInfos = Get-ItemProperty -Path $RegKey
    
    Foreach($item in $InstalledAppsInfos){
        $Obj = [pscustomobject]@{Computer = $ComputerName;
                                 DisplayName = $item.DisplayName;
                                 DisplayVersion = $item.DisplayVersion;
                                 Publisher = $item.Publisher
                                }
        $Objs += $Obj
    }
    $Objs
}

    If($ComputerName){
        Foreach($CN in $ComputerName){
            #Test computer connectivity.
            $PingResult = Test-Connection -ComputerName $CN -Count 1 -Quiet

            If($PingResult){
                FindInstalledApplicationInfo -ComputerName $CN
            }
            Else{
                Write-Warning "Failed to connect to computer $CN"
            }
        }    
    }

    If($ComputerFilePath){
        #Set ComputerName variable.
        $ComputerName = Get-Content $ComputerFilePath

        Foreach($CN in $ComputerName){
            $PingResult = Test-Connection -ComputerName $CN -Count 1 - Quiet

            If($PingResult){
                FindInstalledApplicationInfo - ComputerName -$CN
            }
            Else{
                Write-Warning "Failed to connect to computer $CN"
            }
        }
    }
}