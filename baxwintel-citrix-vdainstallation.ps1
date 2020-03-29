# =============================================================================
# Title              :baxwintel_VdaInstallation.ps1
# Description        :This script is used for Citrix VDA installation.

# Change history     :v1.0: Initial Version

# Author             :Jose Atayde
# Date               :2019-11-19
# Version            :1.0
# PS_version         :5.1
# VDA_version        :7.15 CU4
# =============================================================================
Import-Module ServerManager

$__PATH__ = Get-Location
$VcRedist = "$($__PATH__)\Support\VcRedist_2013_RTM\vcredist_x86.exe" 
$VcRedist_2015 = "$($__PATH__)\Support\VcRedist_2015\vc_redist.x86.exe"
$SourceVDA  = "$($__PATH__)\x64\XenDesktop Setup\XenDesktopVDASetup.exe"

function Install-PreRequisites{
        $VcRedist
        $VcRedist_2015

        Add-WindowsFeature -Name Remote-Assistance,Remote-Desktop-Services,RDS-RD-Server #-Restart
}

function Get-CitrixDDC{
    $CitrixDDC = ""
    $FQDN = (Get-WmiObject win32_computersystem).Domain
    $ServerName = (Get-WmiObject win32_computersystem).DNSHostName

    if($FQDN -eq "global.baxter.com"){
        $CitrixDDC = "usbdctxddc001.global.baxter.com, usbdctxddc002.global.baxter.com"
    }elseif($FQDN -eq "aws.baxter.com") {
        $region = $ServerName.Substring(0, 4)
        if($region -eq "USOH"){
            $CitrixDDC = "usohctxddc001.aws.baxter.com, usohctxddc002.aws.baxter.com"
        }elseif($region -eq "DEFR"){
            $CitrixDDC = "defrctxddc001.aws.baxter.com, defrctxddc002.aws.baxter.com"
        }elseif($region -eq "APSG"){
            $CitrixDDC = "apsgctxddc001.aws.baxter.com, apsgctxddc002.aws.baxter.com"
        }else{
            $CitrixDDC = "unknown DDC"
        }
    }else{
        $CitrixDDC = "unknown DDC"
    }

    return $CitrixDDC
}

function Install-VDA($Broker){
    $VDA =  "VDA"
    $Options = @("/NOREBOOT /QUIET /ENABLE_HDX_PORTS /ENABLE_REAL_TIME_TRANSPORT /ENABLE_FRAMEHAWK_PORT /ENABLE_HDX_UDP_PORTS /ENABLE_REMOTE_ASSISTANCE /OPTIMIZE")
    $Param = @("/COMPONENTS $VDA /CONTROLLERS $Broker $Options")
    $ParamS = $Param.Split(" ")
    & "$SourceVDA" $ParamS
}

Install-PreRequisites
$Broker = Get-CitrixDDC
Install-VDA($Broker)

Restart-Computer –delay 15