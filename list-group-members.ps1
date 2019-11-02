$Token = "_token_"
 
$Headers = @{
 "Authorization" = "Bearer "+$Token
}
 
$GroupCycle = 1
DO {
    $GetMoreGroupsUri = "https://www.yammer.com/api/v1/groups.json?page=$GroupCycle"
    write-host ("WEB REQUEST : $GetMoreGroupsUri")
    $MoreYammerGroups = (Invoke-WebRequest -Uri $GetMoreGroupsUri -Method Get -Headers $Headers).content | ConvertFrom-Json
    $YammerGroups += $MoreYammerGroups
    $GroupCycle ++
    $GroupCount += $YammerGroups.Count
    write-host ($GroupCount)
} 
While ($MoreYammerGroups.Count -gt 0)

foreach ($Group in $YammerGroups) {
    $MemberCycle = 1
    $GroupId = $($Group.id)
    $GroupName = $($Group.full_name)
    $MemberCount = 0
    DO {
	$GetMoreMembersUri = "https://www.yammer.com/api/v1/users/in_group/$GroupId.xml?page=$MemberCycle"
	write-host ("REST API CALL : $GetMoreMembersUri")
        [xml]$Xml = ((Invoke-WebRequest -Uri $GetMoreMembersUri -Method Get -Headers $Headers).content)
        if ($Xml.response.users.user.count -gt 0) {
            $Xml.response.users.SelectNodes("user") | % { 
                $groupnode = $xml.CreateNode("element","group","")
                $groupnode.InnerText = $GroupName
                $_.AppendChild($groupnode)
                $n = $_.Item('type')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('id')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('network-id')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('mugshot-url')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('mugshot-url-template')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('url')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('web-url')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('auto-activated')
                if ($n) {
                    $_.RemoveChild($n)
                }
                $n = $_.Item('stats')
                if ($n) {
                    $_.RemoveChild($n)
                }
            }
            $YammerMembers += $Xml.response.users.user
            $MemberCycle ++
            $MemberCount += $Xml.response.users.user.count
	    write-host ("GROUPMEMBER COUNT : $MemberCount")
        }
    }
    While ($Xml.response.users.user.count -gt 0)
}
$YammerMembers | Where {$_} | Export-Csv "all-members.csv" -Delimiter ","
