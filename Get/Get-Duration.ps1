function Get-Duration {
	param( 
		[DateTime]
		$Start, 
		[DateTime]
		$Finish
	)
	
	if ($start -and $Start -ne [datetime]::MinValue)
	{
		if (!$Finish) {
			$Finish = Get-Date
		}
		$duration= ($Finish - $Start)
	}
	if (!$duration -or $duration.Ticks -lt 0)
	{
		$duration = ((Get-Date ) - $Start)
		if ($duration.Ticks -lt 0)
		{
			return New-TimeSpan
		}
	}
	$duration
}
