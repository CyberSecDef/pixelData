Begin{
	clear;
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript"){ 
		$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition 
	}else{ 
		$ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
		if (!$ScriptPath){ 
			$ScriptPath = "." 
		} 
	}
	
	if (!("cyberToolSuite.pixelDataObj" -as [type])) {
		Add-Type -path "$( $ScriptPath )\pixelData.dll"
	}
	
	Class UI{
		static [UI]$UI = $null;	
		$form = $null;

		[UI] static Get(){
			if( [UI]::UI -eq $null){
				[UI]::UI = [UI]::new( );	
			}

			return [UI]::UI
		}
		
		UI(){
			$this.form = (iex "New-Object System.Windows.Forms.Form");
			$this.form.Text = 'Pixel Color Data'
			$this.form.Size = New-Object System.Drawing.Size(200,125)
			$this.form.StartPosition = 'CenterScreen'
			$this.form.FormBorderStyle = 'FixedToolWindow'
			$this.form.backcolor = '#ffffff';
			
			$btnShowColor = New-Object System.Windows.Forms.Button
			$btnShowColor.Location = New-Object System.Drawing.Point(5,5)
			$btnShowColor.Size = New-Object System.Drawing.Size(50,75)
			$btnShowColor.Text = ''
			$btnShowColor.name = 'btnShowColor'
			
			$btnShowColor.add_keyDown( { 				
				if($_.Alt -eq $true -and $_.Control -eq $true){
					switch($_.KeyCode){
						'H' { iex "[System.Windows.Forms.Clipboard]::SetText(([UI]::Get().form.controls['lblHtml'].text -split '#'  )[1] )" }
						'X' { iex "[System.Windows.Forms.Clipboard]::SetText(([UI]::Get().form.controls['lblHex'].text  -split ' '  )[1] )" }
						'R' { iex "[System.Windows.Forms.Clipboard]::SetText(([UI]::Get().form.controls['lblRGB'].text  -split ': ' )[1] )" }
						'C' { iex "[System.Windows.Forms.Clipboard]::SetText(([UI]::Get().form.controls['lblCMYK'].text -split ': ' )[1] )" }
						'S' { iex "[System.Windows.Forms.Clipboard]::SetText(([UI]::Get().form.controls['lblHSV'].text  -split ': ' )[1] )" }
					}
				}
			} )
			
		
			$this.form.controls.add($btnShowColor)
			
			$label = New-Object System.Windows.Forms.Label
			$label.name = 'lblHex'
			$label.Location = New-Object System.Drawing.Point(60,5)
			$label.Size = New-Object System.Drawing.Size(150,15)
			$label.Text = 'heX: #FFFFFF'
			$this.form.Controls.Add($label)
			
			$label = New-Object System.Windows.Forms.Label
			$label.name = 'lblHtml'
			$label.Location = New-Object System.Drawing.Point(60,20)
			$label.Size = New-Object System.Drawing.Size(150,15)
			$label.Text = 'Html: #FFFFFF'
			$this.form.Controls.Add($label)
			
			$label = New-Object System.Windows.Forms.Label
			$label.name = 'lblRgb'
			$label.Location = New-Object System.Drawing.Point(60,35)
			$label.Size = New-Object System.Drawing.Size(150,15)
			$label.Text = 'Rgb: (255,255,255)'
			$this.form.Controls.Add($label)
			
			$label = New-Object System.Windows.Forms.Label
			$label.name = 'lblCmyk'
			$label.Location = New-Object System.Drawing.Point(60,50)
			$label.Size = New-Object System.Drawing.Size(150,15)
			$label.Text = 'Cymk: (0, 0, 0, 0)'
			$this.form.Controls.Add($label)
			
			$label = New-Object System.Windows.Forms.Label
			$label.name = 'lblHsv'
			$label.Location = New-Object System.Drawing.Point(60,65)
			$label.Size = New-Object System.Drawing.Size(150,15)
			$label.Text = 'hSv: (0, 0, 100)'
			$this.form.Controls.Add($label)

			$this.form.Topmost = $true

		}
	}
	
	class pixelData{
		$grabber = (iex "new-object cyberToolSuite.pixelDataObj");
		
		execute(){
			while([UI]::Get().form.Visible){
				$colors = $this.grabber.Get()
				[UI]::Get().form.Controls['btnShowColor'].BackColor = "#$('{0:x2}' -f $colors.R)$('{0:x2}' -f $colors.G)$('{0:x2}' -f $colors.B)".toUpper()
				
				
				[UI]::Get().form.Controls['lblHex'].Text = "heX: 0x" + "$('{0:x2}' -f $colors.B)$('{0:x2}' -f $colors.G)$('{0:x2}' -f $colors.R)".toUpper()
				[UI]::Get().form.Controls['lblHtml'].Text = "Html: #" + "$('{0:x2}' -f $colors.R)$('{0:x2}' -f $colors.G)$('{0:x2}' -f $colors.B)".toUpper()
				[UI]::Get().form.Controls['lblRGB'].Text = "Rgb: " + "($($colors.R), $($colors.G), $($colors.B))"
			
				$black  = @(
					( 1 - ( $colors.R / 255 ) ),
					( 1 - ( $colors.G / 255 ) ),
					( 1 - ( $colors.B / 255 ) )
				) | sort | select -first 1
				
				if($black -eq 1){
					$black = .999
				}
				
				$cyan    = "{0:N0}" -f ( ( (1 - $( $colors.R / 255 ) - $black) / (1-$black) ) * 100 )
				$magenta = "{0:N0}" -f ( ( (1 - $( $colors.G / 255 ) - $black) / (1-$black) ) * 100 )
				$yellow  = "{0:N0}" -f ( ( (1 - $( $colors.B / 255 ) - $black) / (1-$black) ) * 100 )
				$newBlack = "{0:N0}" -f ($black * 100)
				
				[UI]::Get().form.Controls['lblCMYK'].Text = "Cymk: " + "($($cyan),$($magenta),$($yellow),$($newBlack))"
			
				$max = @($colors.R, $colors.G, $colors.B) | sort -descending | select -first 1
				$min = @($colors.R, $colors.G, $colors.B) | sort | select -first 1
				$h = (iex "[System.Drawing.Color]::FromArgb( $($colors.R), $($colors.G), $($colors.B))").GetHue()
				if($max -eq 0){
					$s = 0
				}else{
					$s = 1 - (1 * $min / $max);	
				}
				$s = $s *100
				$v = $max / 255 * 100;

				[UI]::Get().form.Controls['lblHSV'].Text = "hSv: ($('{0:N0}' -f $h), $('{0:N0}' -f $s), $('{0:N0}' -f $v))"
				
				iex "[System.Windows.Forms.Application]::DoEvents()"   | out-null
			}
		}
	}
}
Process{
	[UI]::Get().form.Show()
	$pixelData = [pixelData]::new();
	$pixelData.execute();
}
End{
	$pixelData = $null
	[UI]::UI = $null
}
