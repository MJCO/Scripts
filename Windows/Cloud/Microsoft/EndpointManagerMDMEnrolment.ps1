<#
    .SYNOPSIS
        Microsoft Endpoint Manager MDM Enrolment
    .DESCRIPTION
        This script creates a scheduled task to handle Endpoint Manager (formerly Intune) MDM Enrolment.
        The scheduled task runs as the SYSTEM user so this script should be run as an administrator or as SYSTEM.
    .NOTES
        +------------------------------------------------+
        |   UPDATED     : 2020.10.02                     |
        |   AUTHOR      : Mikey O'Toole <mikey@mjco.uk>  |
        |   LICENSE     : MIT                            |
        +------------------------------------------------+
#>


Begin {
    $regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\"
    $regKeyMDM = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM"
    $taskName = "MDM Enrolment"
    $taskDescription ="Automatically enroll in Microsoft Endpoint Manager MDM."
    $action = New-ScheduledTaskAction -Execute '%windir%\system32\deviceenroller.exe' -Argument '/c /AutoEnrollMDM'
    $startAt = (Get-Date).AddMinutes(5)
    $repeat = (New-TimeSpan -Minutes 5)
    $duration = (New-TimeSpan -Days 1)
    $trigger = New-ScheduledTaskTrigger -Once -At $startAt -RepetitionInterval $repeat -RepetitionDuration $duration
    $timeToComplete = (New-TimeSpan -Hours 1)
    $settings = New-ScheduledTaskSettingsSet -MultipleInstances Queue -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -ExecutionTimeLimit $timeToComplete -Priority 7    
    $principal = New-ScheduledTaskPrincipal -UserID 'S-1-5-18' -RunLevel Limited
}
Process {     
    New-Item -Path $regKey -Name MDM
    New-ItemProperty -Path $regKeyMDM -Name AutoEnrollMDM -Value 1
    (Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Settings $settings -Trigger $trigger -Principal $principal -Force) | Out-null
}