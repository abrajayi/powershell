function Checkpoint-File {
    param (
        $Path, $Date, $BackupName
    )
    if (-not(Test-Path "C:\TEMP\Logs"))
    {
        New-Item -Path "C:\TEMP" -Name "Logs" -ItemType Directory
    }
    $count = (Get-ChildItem -Path "C:\TEMP\Logs\*" | Measure-Object).Count
 #   if (Test-Path "C:\TEMP\Logs\$count-log.txt")
   #    {
       $count++
        New-Item -Path "C:\TEMP\Logs\$count-log.txt" -ItemType File
       $FileName = (Get-Item -Path "$Path\$BackupName").Name
        $FileType = (Get-Item -Path "$Path").FileType
        $FileExtensions = (Get-Item -Path "$Path").Extensions
        $FileLastWriteTime = (Get-Item -Path "$Path").LastWriteTime
       # Add-Content -Path "C:\TEMP\Logs\$count-log.txt" -Value "$FileName \n$FileType \n$FileExtensions \n$FileLastWriteTime"
       $FileName | Out-File "C:\TEMP\Logs\$count-log.txt"
       $FileType | Out-File "C:\TEMP\Logs\$count-log.txt" -Append
       $FileExtensions | Out-File "C:\TEMP\Logs\$count-log.txt" -Append
       $FileLastWriteTime | Out-File "C:\TEMP\Logs\$count-log.txt" -Append

       $FileName
       Write-Host $FileName

     #   }
        
 #  else
   #  {New-Item -Path "C:\TEMP\Logs\$count-log.txt" -ItemType File}

}


function Get-BackupCount {
    param (
        $FolderName
    )
    $FolderNameCount = (Get-ChildItem -Path "C:\TEMP\Backups\$FolderName*" | Measure-Object).Count
    Return $FolderNameCount + 1
}

function Compare-Folders {
    param (
        $Source, $BackupName, $SourceName
    )
  <#  $list1 = New-Object Collections.Generic.List[string]
    $list2 = New-Object Collections.Generic.List[string]
    $names1 = New-Object Collections.Generic.List[string]
    $names2 = New-Object Collections.Generic.List[string]
   # $FilesToCopy = New-Object Collections.Generic.List[string]
    $lsPrevBackup = Get-ChildItem -Path "C:\TEMP\Backups\$BackupName\$SourceName"
    foreach ($file1 in $lsPrevBackup)
    {
        $LastModified = (Get-Item -Path "C:\TEMP\Backups\$BackupName\$SourceName\$file1").LastWriteTime
        $list1.Add("$LastModified")
        $FileName = (Get-Item -Path "C:\TEMP\Backups\$BackupName\$SourceName\$file1").Name
        $names1.Add("$FileName")
    }
    $lsSource = Get-ChildItem -Path "$Source"
    foreach ($file2 in $lsSource)
    {
        $LastModified2 = (Get-Item -Path "$Source\$file2").LastWriteTime
        $list2.Add("$LastModified2")
        $FileName2 = (Get-Item -Path "$Source\$file2").Name
        $names2.Add("$FileName2")
    }
    $FilesToCopy = @()
    for (($i = 0); $i -lt $list2.Count; $i++)
    {
        if (($list2[$i] -eq $list1[$i]) -and ($names1[$i] -match $names2[$i]))
            {
                $OmittedFiles = "$names2[$i]"
                Write-Host "This file is unchaged from the last backup. $OmittedFiles will be omitted"

            }
         # $FilesToCopy.Add("$names2[$i]")  
         else
         {
            $FilesToCopy += $names2[$i]    
          } 
    }

    Return $FilesToCopy
    #>
      $lsSource = Get-ChildItem -Path "$Source"
    $FilesToCopy = @()
    foreach ($file2 in $lsSource)
    {
        $LastModified2 = (Get-Item -Path "$Source\$file2").LastWriteTime
        $FileName2 = (Get-Item -Path "$Source\$file2").Name
        $LastModified = (Get-Item -Path "C:\TEMP\Backups\$BackupName\$SourceName\$file2").LastWriteTime
        $FileName = (Get-Item -Path "C:\TEMP\Backups\$BackupName\$SourceName\$file2").Name
        if (($LastModified -ne $LastModified2) -and ($FileName2 -ne $FileName))
        {
            $FilesToCopy += "$file2"
        }
    }
    Return $FilesToCopy 


}
function Copy-Directory {
    param (
        $Source, $Destination, $BackupRecName, $BackupName, $SourceName
    )
        if (Test-Path -Path "C:\TEMP\Backups\$BackupName")
             {$ItemsToCopy = Compare-Folders $Source $BackupName $SourceName
             Write-Host "$ItemsToCopy"
             if (-not($ItemsToCopy -eq $null))
                {foreach ($item in $ItemsToCopy)
                {Copy-Item "$Source\$item" -Destination "$Destination"
                 }
                $FilePath = "$Source"
                $CurrentDate = Get-Date
                Checkpoint-File $FilePath $CurrentDate $BackupRecName
                }
            }
        else
           { Copy-Item "$Source" -Destination "$Destination" -Recurse
            $FilePath = "$Source"
            $CurrentDate = Get-Date
            Checkpoint-File $FilePath $CurrentDate $BackupRecName
            Return "Backup was successful. Please see log files for more information"
        Return "Backup was unsuccessful, please try again"
        }
}
function Backup-Directory {
    param (
        $SourcePath
    )
if (Test-Path -Path "$SourcePath")
 {  
    # find a way to extract folder name form source path
    $BackupName = Split-Path "$SourcePath" -Leaf
    if (-not(Test-Path "C:\TEMP\Backups"))
    {
        New-Item -Path "C:\TEMP" -Name "Backups" -ItemType Directory
    }
    $count = Get-BackupCount $BackupName
    # create a new backup folder in temp\backups if it doesnt already exist
    if (Test-Path "C:\TEMP\Backups") 
        {
         New-Item -Path "C:\TEMP\Backups" -Name "$BackupName-Backup-$count" -ItemType Directory
         $DestinationPath = "C:\TEMP\Backups\$BackupName-Backup-$count"
         $PrevBackup = $count - 1
         $DestinationName = "$BackupName-Backup-$count"
         $DestinationPrevName = "$BackupName-Backup-$PrevBackup" 
        }
    $CopyResult = Copy-Directory $SourcePath $DestinationPath $DestinationName $DestinationPrevName $BackupName
    Write-Host $CopyResult
  
    # create a log folder in temp if one doesn't exist
    # create txt files based on backup folder name with 'Log' and date later
    # if override, backup anyways, if keep, omit unchanged files for backup. create a log file and put these in, include files ommited 
    # and list of files copied and their size
    # for every file copied, include details (like date) and append to current log file
    #  return true if backup works, and output success, source path has been backed up in temp\backup. See log of the operation in logs
    }
else {
    Write-Host "This path does not exist"
}
}