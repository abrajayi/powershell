$location = @("Paris", "London", "Bristol", "Canada")
foreach ($location in $location)
 {
    if (-not($location -eq 'Paris'))
        {
            Write-Host "$location is an excellent choice"
        }
    else 
        {
            Write-Host 'Not too sure about Paris :( '
        }
  }