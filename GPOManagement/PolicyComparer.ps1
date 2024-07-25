# Requires MS policy analyzer tool
Import-Module ActiveDirectory
$gpoTargetOU = "TargetOU"
# Check if paths exists
$pathToPolicyAnalyzer = "PathTo\GPO2PolicyRules.exe"
$pathToExportBackups = "PathToDumpGPOBackups"
$pathToExportPolicyRuleSets = "PathToDumpConvertedPolicyFiles"
$arr = @($pathToPolicyAnalyzer,
         $pathToExportBackups,
         $pathToExportPolicyRuleSets   
         )

foreach($s in $arr){
    if(Test-Path -Path $s)
    {continue}
    else {
        $s = Read-Host "Enter Path to to $s"; New-Item $s
    }
}

# Only for remoting, not really working, should be done on DSA.MSC enabled machine that are GPO admin
#$gpos = @(Get-GPInheritance -Target $using:gpoTargetOU | Select-Object -ExpandProperty gpolinks)

foreach($gpo in $gpos)

    {
        $name = $gpo.DisplayName
        $pathToExportBackups # + "\" + $name + ".policyrules"
        $hah = (Backup-GPO -Guid $gpo.GpoId -Path $pathToExportBackups).id
        $ren = $pathToExportBackups + "\" + "{" + $hah + "}"
        Rename-item -Path $ren -NewName $gpo.DisplayName

    }

$BUs = Get-ChildItem -Path $pathToExportBackups
foreach($BU in $BUs)
    {
        
        $pathToPolicyAnalyzer + " " + $bu.FullName + " " + $pathToExportPolicyRuleSets + ".policyrules"
        [string]$target = $pathToExportPolicyRuleSets + $bu.Name + ".policyrules"
        $target = "`"$target`""
        [string]$source = $bu.FullName
        $source = "`"$source`""
        Start-Process -FilePath $pathToPolicyAnalyzer -ArgumentList $source,$target
    }
