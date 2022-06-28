$stringInput = Read-Host "Please enter a number between 1 and 10"
$numInput = [int]$stringInput
if (($numInput -ge 1) -and ($numInput -le 10))
{
    Write-Host "$input is between 1 and 10"
}
else
{
    Write-Host "$input is not between 1 and 10"
}