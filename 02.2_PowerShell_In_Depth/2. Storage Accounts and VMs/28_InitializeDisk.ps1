# Retrieve disk information where the partition style is RAW (uninitialized disk)
$disk = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

# Initialize the selected disk with Master Boot Record (MBR) partition style
$initializeDisk = Initialize-Disk -Number $disk.Number -PartitionStyle MBR -PassThru

# Create a new partition on the initialized disk using the maximum available size and assign drive letter F
$partition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter F

# Format the newly created volume/partition with NTFS file system, set the label to "Data," and force the formatting without confirmation
Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel "Data" -Force -Confirm:$false
