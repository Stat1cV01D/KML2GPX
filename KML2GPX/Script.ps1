$templateGpx = [xml]@'
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<gpx>
<trk>
<trkseg>
<trkpt lat="NN.NNNNNNNNNNNNN" lon="EE.EEEEEEEEEEEEE">
</trkpt>
</trkseg>
</trk>
</gpx>
'@

#<trkpt lat="NN.NNNNNNNNNNNNN" lon="EE.EEEEEEEEEEEEE"></trkpt>
#<trkpt lat="SS.SSSSSSSSSSSSS" lon="WW.WWWWWWWW"></trkpt>
#<trkpt lat="SS.SSSSSSSSSSSSS" lon="EE.EEEEEEEEEEEEE"></trkpt>
#<trkpt lat="NN.NNNNNNNNNNNNN" lon="WW.WWWWWWWW"></trkpt>

$coordinates = @(
	('north', 'east'),
	('south', 'west'),
	('south', 'east'),
	('north', 'west')
)

Get-ChildItem -Filter '*.kml' |
Foreach-Object{
    $file = $_
	$content = [xml](Get-Content $file.FullName)
	$resultGpx = $templateGpx.Clone()
		
	Try
	{
		for ($i = 0; $i -lt 4; $i++)
		{
			$originalNode = $content.kml.GroundOverlay.LatLonBox;
			$coordItem = $coordinates[$i]
			$ptNode = $resultGpx.CreateElement('trkpt')
			$ptNode.SetAttribute('lat', $originalNode.SelectSingleNode($coordItem[0]).InnerText)
			$ptNode.SetAttribute('lon', $originalNode.SelectSingleNode($coordItem[1]).InnerText)
			$resultGpx.gpx.trk.trkseg.AppendChild($ptNode)
		}
		
		# So that "trkseg" node is not converted to String
		# I will have to add a child node and then delete it
		$resultGpx.gpx.trk.trkseg.RemoveChild($resultGpx.gpx.trk.trkseg.FirstChild)

		$iso8859_1 = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
		$fileName = $file.DirectoryName + "\" + $file.BaseName + ".gpx"
		$sw = New-Object System.IO.StreamWriter($fileName, $false, $iso8859_1)
		$resultGpx.Save($sw)
		$sw.Close()
	}
	Catch
	{
		Write-Output "Unable to convert $file : $_", $_.ScriptStackTrace
	}
}