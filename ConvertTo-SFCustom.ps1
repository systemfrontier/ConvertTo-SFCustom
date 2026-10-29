<#
.SYNOPSIS
Converts an object or list of objects to various custom formats.

.LINK
https://github.com/systemfrontier/ConvertTo-SFCustom

.DESCRIPTION
An object or collection of objects can be converted to various output formats.

.PARAMETER Data
Object or collection of objects to be converted.

.PARAMETER Format
Optional: Output format to be returned. Defaults to normal console output.
- HTML: Searchable HTML table with alternating row colors (No dependencies)
- CSV: Comma-separated values
- TSV: Tab-separated values
- JSON: Indented JSON
- XML: XML document
- Default: When no Format switch is supplied, Format-Table is used for console output

.PARAMETER Property
Optional: Select specific properties to be used in the returned format. Defaults to all.

.EXAMPLE
ConvertTo-SFCustom -Data $processes -Format HTML

.NOTES
==============================================
Name:		ConvertTo-SFCustom
Version:	1.1
Author:     Jay Adams, Noxigen LLC
Created:	2026-10-28
Copyright:	Noxigen LLC. All rights reserved.

Create secure GUIs for PowerShell with System Frontier.
https://systemfrontier.com/
==============================================
#>
function ConvertTo-SFCustom {
	[CmdletBinding()]
	param(
		[object]$Data,
		[ValidateSet('HTML','CSV','TSV','JSON','XML','Console')]
		[string]$Format,
		[string[]]$Property,
		[hashtable]$Options = @{}
	)

	$result = ''

	if ($null -eq $Data) {
		return $null
	}

	if ($null -ne $Property -and $Property.Count -gt 0) {
		$Data = $Data | Select-Object -Property $Property
	}

	$consoleFormat = { $Data | Format-Table -AutoSize | Out-String -Width 4096 }

	$tableConfig = @{}
	$tbc = 'table-border-color'
	$thbgc = 'table-head-bgcolor'
	$thc = 'table-head-color'
	$trbgc = 'table-row-bgcolor'
	$tableConfig.Add($tbc, ($Options[$tbc] ?? '#ccc'))
	$tableConfig.Add($thbgc, ($Options[$thbgc] ?? '#244a64'))
	$tableConfig.Add($thc, ($Options[$thc] ?? '#fff'))
	$tableConfig.Add($trbgc, ($Options[$trbgc] ?? '#eef4f7'))

	# Unique id for this instance
	$id = (New-Guid).ToString().Split('-')[0]

	switch ($Format) {
		'HTML'
		{
			$table = $Data | ConvertTo-Html -Fragment

			$style = @"
<style>
    #sfqc-$id { display:flex;justify-content:flex-end; }
	#sfq-$id { border:1px solid #000;padding:2px; }
    #sftbl-$id { overflow-x:auto;margin-top:-45px; }
    #sftbl-$id table { border-collapse:collapse;width:100%; }
    #sftbl-$id th,
    #sftbl-$id td { border:1px solid $($tableConfig[$tbc]);padding:4px 6px;text-align: left; }
    #sftbl-$id th { background-color:$($tableConfig[$thbgc]);color:$($tableConfig[$thc]); }
    #sftbl-$id tr:nth-child(even) { background-color:$($tableConfig[$trbgc]); }
</style>
"@

			$result = @"
$style
<div id="sfqc-$id"><input id="sfq-$id" placeholder="Search..."></div>
<div id="sftbl-$id">
	$table
	<script>
	document.getElementById('sfq-$id').oninput = e => {
	const q = e.target.value.toLowerCase();
	for (const row of document.querySelectorAll('#sftbl-$id tr:not(:first-child)'))
		row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
	};
	</script>
</div>
"@
		}

		'CSV'
		{
			$result = $Data | ConvertTo-Csv -NoTypeInformation
		}

		'TSV'
		{
			$result = $Data | ConvertTo-Csv -NoTypeInformation -Delimiter "`t"
		}

		'JSON'
		{
			$result = $Data | ConvertTo-Json -Depth 99
		}

		'XML'
		{
			$result = ($Data | ConvertTo-Xml -As Document -Depth 99).OuterXml
		}

		'Console'
		{
			$result = & $consoleFormat
		}

		default # Console output
		{
			$result = & $consoleFormat
		}
	}

	return $result
}
