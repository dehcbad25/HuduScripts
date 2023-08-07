# Based on the original script by Kelvin Tegelaar https://github.com/KelvinTegelaar/AutomaticDocumentation
## From https://github.com/lwhitelock/HuduAutomation/blob/main/CyberdrainRewrite/Hudu-ADGroups-Documentation.ps1

## Created by David Hay-Currie on 2023-07-31. Added fields and other relationships
## Modified for user documentation
#####################################################################
# Get a Hudu API Key from https://yourhududomain.com/admin/api_keys
$HuduAPIKey = "abcdefght1234567890"
# Set the base domain of your Hudu instance without a trailing /
$HuduBaseDomain = "https://your.hudu.domain"
#Company Name as it appears in Hudu
$CompanyName = "Company Name"
$HuduAssetLayoutName = "Active Directory Groups - AutoDoc"
# Enter the name of the Asset Layout you use for storing contacts
$HuduContactLayout = "People"
$HuduComputerLayout = "Computer Assets"
#####################################################################

#Get the Hudu API Module if not installed
if (Get-Module -ListAvailable -Name HuduAPI) {
	Import-Module HuduAPI 
} else {
	Install-Module HuduAPI -Force
	Import-Module HuduAPI
}
#Set Hudu logon information
New-HuduAPIKey $HuduAPIKey
New-HuduBaseUrl $HuduBaseDomain


# Get the Hudu Company we are working without
## This section is not up to date with the new layout. Will be completed at a later date DHC 2023-07-31
$Company = Get-HuduCompanies -name $CompanyName
if ($company) {	
	$ComputerLayout = Get-HuduAssetLayouts -name $HuduComputerLayout
	if ($ComputerLayout) {
		$ContactsLayout = Get-HuduAssetLayouts -name $HuduContactLayout
		if ($ContactsLayout) {
		
			$Layout = Get-HuduAssetLayouts -name $HuduAssetLayoutName
			if (!$Layout) { 
				$AssetLayoutFields = @(
					@{
						label        = 'Group Name'
						field_type   = 'Text'
						show_in_list = 'true'
						position     = 1
					},
					@{
						label        = 'Email Address'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 2
					},
					@{
						label        = 'Description'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 3
					},
					@{
						label        = 'AD Notes'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 4
					},
					@{
						label        = 'Notes'
						field_type   = 'RichText'
						show_in_list = 'false'
						position     = 5
					},
					@{
						label        = 'IP Address of Primary Computer'
						field_type   = 'Website'
						show_in_list = 'false'
						position     = 6
					},
					@{
						label        = 'Restricted to computers'
						field_type   = 'AssetTag'
						show_in_list = 'false'
						linkable_id  = $ComputerLayout.id
						position     = 7
					},
					@{
						label        = 'Group Type'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 8
					},
					@{
						label        = 'Group Scope'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 9
					},
					@{
						label        = 'Protected from Accidental Deletion?'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 10
					},
					@{
						label        = 'Member of'
						field_type   = 'AssetTag'
						show_in_list = 'false'
						linkable_id  = $Layout.id
						position     = 11
					},
					@{
						label        = 'Members'
						field_type   = 'RichText'
						show_in_list = 'false'
						position     = 12
					},
					@{
						label        = 'GUID'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 13
					},
					@{
						label        = 'SID'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 14
					},
					@{
						label        = 'Distinguished Name'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 15
					},
					@{
						label        = 'Tagged Users'
						field_type   = 'AssetTag'
						show_in_list = 'false'
						linkable_id  = $ContactsLayout.id
						position     = 16
					}, @{
						label        = 'Created'
						field_type   = 'Text'
						show_in_list = 'false'
						position     = 17
					}
				)
			
				Write-Host "Creating New Asset Layout"
				$NewLayout = New-HuduAssetLayout -name $HuduAssetLayoutName -icon "fas fa-users" -color "#7df14b" -icon_color "#000000" -include_passwords $false -include_photos $false -include_comments $false -include_files $false -fields $AssetLayoutFields
				$Layout = Get-HuduAssetLayouts -name $HuduAssetLayoutName
			
			}
		
	
			#Collect Data
			$AllGroups = get-adgroup -filter * -Properties *
			foreach ($Group in $AllGroups) {
				$TaggedContact = $null
				$TaggedGroup = $null
				Write-Host "Group: $($group.name)"
				$Members = get-adgroupmember $Group
				$MembersTable = $members | Select-Object Name, distinguishedName | ConvertTo-Html -Fragment | Out-String
				foreach ($Member in $Members) {
					If ($Member.objectClass -eq 'user') {
						$email = (get-aduser $member -Properties EmailAddress).EmailAddress
						#Tagging Users
						if ($email) {
							write-host "Searching for $email"
							$contact = (get-huduassets -assetlayoutid $ContactsLayout.id -companyid $Company.id) | Where-Object { $_.fields.value -eq $($email) } | Select-Object id, slug, name
							if ($contact) {
								write-host "Found $email"
								## The tagging uses a different format so we will clean create it one part at a time
								IF ($null -eq $TaggedContact) { $TaggedContact = '{"id":' + $contact.id + ',"url":"/a/' + $contact.slug + '","name":"' + $contact.name + '"}' } else {
									## Each entry is enclosed by curly brackets and separated by comma
									$TaggedContact = $TaggedContact + ',{"id":' + $contact.id + ',"url":"/a/' + $contact.slug + '","name":"' + $contact.name + '"}'
								}
							}
						}
					}
				}
				foreach ($Memberof in $Members) {
					If ($Memberof.objectClass -eq 'group') {
						$MemberofGroup = (get-adgroup $Memberof -Properties Name).Name
						#Tagging Users
						if ($MemberofGroup) {
							write-host "Searching for $MemberofGroup"
							$contactgroup = (get-huduassets -assetlayoutid $Layout.id -companyid $Company.id) | Where-Object { $_.name -eq $($MemberofGroup) } | Select-Object id, slug, name
							if ($contactgroup) {
								write-host "Found $MemberofGroup"
								## The tagging uses a different format so we will clean create it one part at a time
								IF ($null -eq $TaggedGroup) { $TaggedGroup = '{"id":' + $contactgroup.id + ',"url":"/a/' + $contactgroup.slug + '","name":"' + $contactgroup.name + '"}' } else {
									## Each entry is enclosed by curly brackets and separated by comma
									$TaggedGroup = $TaggedGroup + ',{"id":' + $contactgroup.id + ',"url":"/a/' + $contactgroup.slug + '","name":"' + $contactgroup.name + '"}'
								}
							}
						}
					}
				}
				## After all the contacts and groups are added we need to enclose the entry with brackets	
				$TaggedContact = '[' + $TaggedContact + ']'
				$TaggedGroup = '[' + $TaggedGroup + ']'
				## Trying to cleanup some of the data from how PS presents it to clean data for Hudu
				$DateGroupCreated = $Group.Created.ToString()
		
		
				# Set the group's asset fields
				$AssetFields = @{
					'group_name'                          = $($group.name)
					'members'                             = $MembersTable
					'guid'                                = $($group.objectguid.guid)
					'tagged_users'                        = $TaggedContact
					'member_of'                           = $TaggedGroup
					'group_type'                          = [string]$Group.GroupCategory
					'group_scope'                         = [string]$Group.GroupScope
					'sid'                                 = $Group.SID.Value
					'distinguished_name'                  = $Group.DistinguishedName
					'protected_from_accidental_deletion?' = [string]$Group.ProtectedFromAccidentalDeletion
					'description'                         = $Group.Description
					'ad_notes'                            = $Group.Notes
					'created'                             = [string]$DateGroupCreated
				}
				#Upload data to Hudu. We try to match the Group name to current group.	
				$Asset = Get-HuduAssets -name $($group.name) -companyid $company.id -assetlayoutid $layout.id
	
				#If the Asset does not exist, we edit the body to be in the form of a new asset, if not, we just upload.
				if (!$Asset) {
					Write-Host "Creating new Asset"
					$Asset = New-HuduAsset -name $($group.name) -company_id $company.id -asset_layout_id $Layout.id -fields $AssetFields	
				} else {
					Write-Host "Updating Asset"
					$Asset = Set-HuduAsset -asset_id $Asset.id -name $($group.name) -company_id $company.id -asset_layout_id $layout.id -fields $AssetFields	
				}
			}
  }	else {
			Write-Host "$HuduContactLayout Layout was not found in Hudu"
  }  
	} else {
		Write-Host "$ComputerLayout Layout was not found in Hudu"
	}

} else {
	Write-Host "$CompanyName was not found in Hudu"
}


## (Get-HuduAssets -Name $Group.Name).fields | Select-Object id, label, value
## (Get-HuduAssets -name $($group.name) -companyid $company.id -assetlayoutid $layout.id).fields | Select-Object id, label, value