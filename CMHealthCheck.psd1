﻿# Module manifest for module 'CMHealthCheck'
# Generated by: David Stein
# Generated on: 10/03/2019
# Last updated: 10/01/2021

@{
RootModule    = '.\CMHealthCheck.psm1'
ModuleVersion = '1.0.28'
GUID          = 'e61ecfc4-1895-4e5d-a91e-10fb4311b09a'
Author        = 'David Stein'
CompanyName   = 'skatterbrainz'
Copyright     = '(c) 2017-2021 David Stein. All rights reserved.'
Description   = 'ConfigMgr healthcheck reporting'
PowerShellVersion = '4.0'
PowerShellHostVersion = '4.0'
RequiredModules = @('dbatools')

FunctionsToExport = @(
	'Get-CMHealthCheck',
	'Get-CMHealthCheckSummary',
	'Export-CMHealthReport',
	'Invoke-CMHealthCheck'
)

CmdletsToExport   = @()
VariablesToExport = '*'
AliasesToExport   = @()

FileList = @(
	'.\Assets\cmhealthcheck.xml',
	'.\Assets\messages.xml',
	'.\Assets\default.css',
	'.\Assets\ocean.css',
	'.\Assets\monochrome.css',
	'.\Assets\emerald.css',
	'.\Assets\buildnumbers.txt',
	".\Assets\windows_update_errorcodes.csv",
	'.\Assets\cmhclogo-275x237.png',
	'.\Docs\Export-CMHealthReport.md',
	'.\Docs\Get-CMHealthCheck.md'
)

PrivateData = @{
	PSData = @{
		# Tags applied to this module. These help with module discovery in online galleries.
		Tags       = @('cmhealthcheck','healthcheck','Get-CMHealthCheck','Export-CMHealthReport','sccm','configmgr','systemcenter','sql','audit','report','skatterbrainz','mecm','endpoint','microsoft')
		LicenseUri = 'https://opensource.org/licenses/MIT'
		ProjectUri = 'https://github.com/Skatterbrainz/CMHealthCheck'
		IconUri    = 'https://user-images.githubusercontent.com/11505001/32978293-2be8336e-cc0d-11e7-9606-0c3412aaa7cc.png'
		ReleaseNotes = @'
* Thanks to Rafael Perez for inventing this - http://www.rflsystems.co.uk
* Thanks to Carl Webster for the basis of Word functions - http://www.carlwebster.com
* Thanks to David O'Brien for additional Word functions - http://www.david-obrien.net/2013/06/20/huge-powershell-inventory-script-for-configmgr-2012/
* Thanks to Starbucks for empowering me to survive hours of clicking through the Office Word API reference
'@
	} # End of PSData hashtable
} # End of PrivateData hashtable
}
