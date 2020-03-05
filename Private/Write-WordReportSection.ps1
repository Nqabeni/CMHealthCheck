Function Write-WordReportSection {
	param (
		[parameter()] $HealthCheckXML,
		[parameter()] $Section,
		[parameter()] $Detailed = $false,
		[parameter()] $Doc,
		[parameter()] $Selection,
		[parameter()] $LogFile
	)
	Write-Log -Message "function...... Write-WordReportSection ****" -LogFile $logfile
	Write-Log -Message "section....... $section" -LogFile $logfile
	Write-Log -Message "detail........ $($detailed.ToString())" -LogFile $logfile
	
	foreach ($healthCheck in $HealthCheckXML.dtsHealthCheck.HealthCheck) {
		if ($healthCheck.Section.ToLower() -ne $Section) { continue }
		$Description = $healthCheck.Description -replace("@@NumberOfDays@@", $NumberOfDays)
		if ($healthCheck.IsActive.ToLower() -ne 'true') { continue }
		if ($healthCheck.IsTextOnly.ToLower() -eq 'true') {
			if ($Section -eq 5) {
				if ($detailed -eq $false) { 
					$Description += " - Overview" 
				} 
				else { 
					$Description += " - Detailed"
				}            
			}
			Write-WordText -WordSelection $selection -Text $Description -Style $healthCheck.WordStyle -NewLine $true
			Continue;
		}
		Write-Log -Message "description... $Description" -LogFile $logfile
		Write-WordText -WordSelection $selection -Text $Description -Style $healthCheck.WordStyle -NewLine $true
		$bFound = $false
		$tableName = $healthCheck.XMLFile
		if ($Section -eq 5) {
			if (!($detailed)) { 
				$tablename += "summary" 
			} 
			else { 
				$tablename += "detail"
			}            
		}
		foreach ($rp in $ReportTable) {
			if ($rp.TableName -eq $tableName) {
				$bFound = $true
				$filename = $rp.XMLFile
				Write-Log -Message "xmlfile....... $filename" -LogFile $logfile
				if ($filename.IndexOf("_") -gt 0) {
					$xmltitle = $filename.Substring(0,$filename.IndexOf("_"))
					$xmltile = ($rp.TableName.Substring(0,$rp.TableName.IndexOf("_")).Replace("@","")).Tolower()
					switch ($xmltile) {
						"sitecode"   { $xmltile = "Site Code: " }
						"servername" { $xmltile = "Server Name: " }
					}
					switch ($healthCheck.WordStyle) {
						"Heading 1" { $newstyle = "Heading 2" }
						"Heading 2" { $newstyle = "Heading 3" }
						"Heading 3" { $newstyle = "Heading 4" }
						default { $newstyle = $healthCheck.WordStyle }
					}
					$xmltile += $filename.Substring(0,$filename.IndexOf("_"))
					Write-WordText -WordSelection $selection -Text $xmltile -Style $newstyle -NewLine $true
				}
				if (!(Test-Path ($reportFolder + $filename))) {
					Write-WordText -WordSelection $selection -Text $healthCheck.EmptyText -NewLine $true
					Write-Log -Message "Table does not exist" -LogFile $logfile -Severity 2
					$selection.TypeParagraph()
				}
				else {
					#Write-Log -Message "importing XML file: $filename" -LogFile $logfile
					$datatable = Import-CliXml -Path ($reportFolder + $filename)
					$count = 0
					$datatable | Where-Object { $count++ }
					if ($count -eq 0) {
						Write-WordText -WordSelection $selection -Text $healthCheck.EmptyText -NewLine $true
						Write-Log -Message "Table......... 0 rows" -LogFile $logfile -Severity 2
						$selection.TypeParagraph()
						continue
					}
					switch ($healthCheck.PrintType.ToLower()) {
						"table" {
							Write-Log -Message "table type.... table" -LogFile $logfile
							$Table = $Null
							$TableRange = $Null
							$TableRange = $doc.Application.Selection.Range
							$Columns = 0
							foreach ($field in $HealthCheck.Fields.Field) {
								if ($section -eq 5) {
									if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
									elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
								}
								$Columns++
							} # foreach
							$Table = $doc.Tables.Add($TableRange, $count+1, $Columns)
							Write-Log -Message "table style... $TableStyle" -LogFile $logfile
							$table.Style = $TableStyle
							# added to force table width consistency in 1.0.4 (Issue 13)
							$table.PreferredWidthType = 2
							$table.PreferredWidth = 100
							$i = 1;
							Write-Log -Message "structure..... $count rows and $Columns columns" -LogFile $logfile
							Write-Log -Message "writing table column headings..." -LogFile $logfile
							foreach ($field in $HealthCheck.Fields.Field) {
								if ($section -eq 5) {
									if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
									elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
								}
								$Table.Cell(1, $i).Range.Font.Bold = $True
								$Table.Cell(1, $i).Range.Text = $field.Description
								#Write-Log -Message "--column: $($field.Description)" -LogFile $logfile
								$i++
							} # foreach
							$xRow = 2
							$records = 1
							$y=0
							Write-Log -Message "writing data rows for table body..." -LogFile $logfile
							foreach ($row in $datatable) {
								if ($records -ge 500) {
									Write-Log -Message ("Exported..... $(500*($y+1)) records") -LogFile $logfile
									$records = 1
									$y++
								}
								$i = 1;
								foreach ($field in $HealthCheck.Fields.Field) {
									if ($section -eq 5) {
										if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
										elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
									}
									$Table.Cell($xRow, $i).Range.Font.Bold = $false
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($row.$($field.FieldName))
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($row.$($field.FieldName))
										}										
										default {
											$TextToWord = $row.$($field.FieldName);
										}
									}
									#Write-Log -Message "--value: $($TextToWord.ToString())" -LogFile $logfile
									if ([string]::IsNullOrEmpty($TextToWord)) { 
										$TextToWord = " " 
										$val = " "
									}
									elseif (Test-Numeric $TextToWord) {
										#Write-Log -Message "rounding numeric value precision" -LogFile $logfile
										$val = ([math]::Round($TextToWord,2)).ToString()
									}
									else {
										$val = $TextToWord.ToString()
									}
									$Table.Cell($xRow, $i).Range.Text = $val
									$i++
								} # foreach
								$xRow++
								$records++
							} # foreach
							$selection.EndOf(15) | Out-Null
							$selection.MoveDown() | Out-Null
							$doc.ActiveWindow.ActivePane.view.SeekView = 0
							$selection.EndKey(6, 0) | Out-Null
							if ($count -gt 2) {
								Write-Verbose "SORT OPERATION - SORTING TABLE"
								$Tables.Sort
								Write-Log -Message "NEW: appending row count label below table" -LogFile $logfile
								Write-WordText -WordSelection $selection -Text "$count items found" -Style "Normal" -NewLine $true
								$selection.TypeParagraph()
							}
							$selection.TypeParagraph()
						}
						"simpletable" {
							Write-Log -Message "table type.... simpletable" -LogFile $logfile
							$Table = $Null
							$TableRange = $Null
							$TableRange = $doc.Application.Selection.Range
							$Columns = 0
							foreach ($field in $HealthCheck.Fields.Field) {
								if ($section -eq 5) {
									if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
									elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
								}
								$Columns++
							} # foreach
							$Table = $doc.Tables.Add($TableRange, $Columns, 2)
							$table.Style = $TableSimpleStyle
							# added to force table width consistency in 1.0.4 (Issue 13)
							$table.PreferredWidthType = 2
							$table.PreferredWidth = 100
							$i = 1;
							Write-Log -Message "structure..... $Columns rows and 2 columns" -LogFile $logfile
							$records = 1
							$y=0
							foreach ($field in $HealthCheck.Fields.Field) {
								if ($section -eq 5) {
									if (($detailed) -and ($field.groupby -notin ('1','2'))) { continue }
									elseif ((!($detailed)) -and ($field.groupby -notin ('2','3'))) { continue }
								}
								if ($records -ge 500) {
									Write-Log -Message ("Exported..... $(500*($y+1)) records") -LogFile $logfile
									$records = 1
									$y++
								}
								$Table.Cell($i, 1).Range.Font.Bold = $true
								$Table.Cell($i, 1).Range.Text = $field.Description
								$Table.Cell($i, 2).Range.Font.Bold = $false
								if ($poshversion -ne 3) { 
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($datatable.Rows[0].$($field.FieldName))
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($datatable.Rows[0].$($field.FieldName))
										}											
										default {
											$TextToWord = $datatable.Rows[0].$($field.FieldName)
										}
									} # switch
									if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									$Table.Cell($i, 2).Range.Text = $TextToWord.ToString()
								}
								else {
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = Get-MessageInformation -MessageID ($datatable.$($field.FieldName))
										}
										"messagesolution" {
											$TextToWord = Get-MessageSolution -MessageID ($datatable.$($field.FieldName))
										}											
										default {
											$TextToWord = $datatable.$($field.FieldName) 
										}
									} # switch
									if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									$Table.Cell($i, 2).Range.Text = $TextToWord.ToString()
								}
								$i++
								$records++
							} # foreach
							$selection.EndOf(15) | Out-Null
							$selection.MoveDown() | Out-Null
							$doc.ActiveWindow.ActivePane.View.SeekView = 0
							$selection.EndKey(6, 0) | Out-Null
							$selection.TypeParagraph()
						}
						default {
							Write-Log -Message "table type.... default" -LogFile $logfile
							$records = 1
							$y=0
							foreach ($row in $datatable) {
								if ($records -ge 500) {
									Write-Log -Message ("Exported...... $(500*($y+1)) records") -LogFile $logfile
									$records = 1
									$y++
								}
								foreach ($field in $HealthCheck.Fields.Field) {
									$TextToWord = "";
									switch ($field.Format.ToLower()) {
										"message" {
											$TextToWord = ($field.Description + " : " + (Get-MessageInformation -MessageID ($row.$($field.FieldName))))
										}
										"messagesolution" {
											$TextToWord = ($field.Description + " : " + (Get-MessageSolution -MessageID ($row.$($field.FieldName))))
										}												
										default {
											$TextToWord = ($field.Description + " : " + $row.$($field.FieldName))
										}
									} # switch
									if ([string]::IsNullOrEmpty($TextToWord)) { $TextToWord = " " }
									Write-WordText -WordSelection $selection -Text ($TextToWord.ToString()) -NewLine $true
								} # foreach
								$selection.TypeParagraph()
								$records++
							} # foreach
						} # end of default switch case
					} # switch
					Write-WordTableGrid -Caption "Review Comments" -Rows 3 -ColumnHeadings $ReviewTableCols -StyleName $ReviewTableStyle
				}
			}
		} # foreach
		if ($bFound -eq $false) {
			Write-WordText -WordSelection $selection -Text $healthCheck.EmptyText -NewLine $true
			Write-Log -Message ("Table does not exist") -LogFile $logfile -Severity 2
			$selection.TypeParagraph()
		}
	} # foreach
}
