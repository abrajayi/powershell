$userInput = Read-Host "Pick a number between 1 and 10"
$num = [int]$userInput
$userInput2 = 'N'
while ($userInput2 -eq 'N')
{
$guess = Get-Random -Minimum 1 -Maximum 10
$userInput2 = Read-Host "Is your number $guess ? Enter Y or N"
    if ($userInput2 -eq 'Y')
    {
       Write-Host "I got it right, your number is $num !"
       break 
    }

    else
    {
    Write-Host "I couldn't get the answer, please play again"
    }
}

    Write-Host 'Thank you for playing!'