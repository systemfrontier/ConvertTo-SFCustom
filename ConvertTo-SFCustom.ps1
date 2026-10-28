
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
Version:	1.0
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
		[ValidateSet('HTML','CSV','TSV','JSON','XML')]
		[string]$Format,
		[string[]]$Property
	)

	$result = ''

	if ($null -eq $Data) {
		return $null
	}

	if ($null -ne $Property -and $Property.Count -gt 0) {
		$Data = $Data | Select-Object -Property $Property
	}

	# Unique id for this instance
	$id = (New-Guid).ToString().Split('-')[0]

	switch ($Format) {
		'HTML'
		{
			$table = $Data | ConvertTo-Html -Fragment

			$style = @"
<style>
    #ctctable-$id table { border-collapse: collapse; width: 100%; }
    #ctctable-$id th,
    #ctctable-$id td {
        border: 1px solid #ccc;
        padding: 4px 6px;
        text-align: left;
	}
    #ctctable-$id th { background-color: #244a64; color: white; }
    #ctctable-$id tr:nth-child(even) { background-color: #eef4f7; }
</style>
"@

			$result = @"
$style
<div style="text-align:right; margin-bottom:3px"><input id="q-$id" placeholder="Search..."></div>
<div id="ctctable-$id" style="overflow-x:auto">
	$table
	<script>
	document.getElementById('q-$id').oninput = e => {
	const q = e.target.value.toLowerCase();
	for (const row of document.querySelectorAll('#ctctable-$id tr:not(:first-child)'))
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

		default # Console output
		{
			$result = $Data | Format-Table -AutoSize | Out-String -Width 4096
		}
	}

	return $result
}


