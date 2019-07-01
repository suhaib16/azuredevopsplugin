Param (
    $command
)
$result = Invoke-Expression $command
return $result