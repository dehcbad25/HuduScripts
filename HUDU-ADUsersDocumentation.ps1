# Based on the original script by Kelvin Tegelaar https://github.com/KelvinTegelaar/AutomaticDocumentation
## From https://github.com/lwhitelock/HuduAutomation/blob/main/CyberdrainRewrite/Hudu-ADGroups-Documentation.ps1

## Created by David Hay-Currie on 2023-07-31. Added fields and other relationships
## The goal of this is to collect enough information that might be required for SoC and CMMC Level 2, and change control. There are a lot of fields, but your specific use might not need them.
## There is also a need to update back. It is not added at the moment, meaning if there was a field filled in AD, but it is not filled anymore, the HUDU API will not clear it. We might need to create conditions to fill entries with $null
#####################################################################
# Get a Hudu API Key from https://yourhududomain.com/admin/api_keys
$HuduAPIKey = "abcdefght1234567890"
# Set the base domain of your Hudu instance without a trailing /
$HuduBaseDomain = "https://your.hudu.domain"
#Company Name as it appears in Hudu
$CompanyName = "Company Name"
$HuduAssetLayoutName = "People"
# Enter the name of the Asset Layout you use for storing Groups
$HuduGroupLayout = "Active Directory Groups - AutoDoc"
## Enter the name of the Asset layout for the computers
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
$Company = Get-HuduCompanies -name $CompanyName
if ($company) {	
    $ComputerLayout = Get-HuduAssetLayouts -name $HuduComputerLayout
    if ($ComputerLayout) {
        $Grouplayout = Get-HuduAssetLayouts -name $HuduGroupLayout
        if ($Grouplayout) {
		
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
                        label        = 'Status'
                        field_type   = 'Dropdown'
                        show_in_list = 'false'
                        position     = 2
                    },
                    @{
                        label        = 'Email Address'
                        field_type   = 'Text'
                        show_in_list = 'true'
                        position     = 3
                    },
                    @{
                        label        = 'Pronound'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 4
                    },
                    @{
                        label        = 'Title'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 5
                    },
                    @{
                        label        = 'Department'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 6
                    },
                    @{
                        label        = 'Accept Text?'
                        field_type   = 'Dropdown'
                        show_in_list = 'false'
                        position     = 7
                    },
                    @{
                        label        = 'Workstation used'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 8
                    },
                    @{
                        label        = 'Notes'
                        field_type   = 'RichText'
                        show_in_list = 'false'
                        position     = 9
                    },
                    @{
                        label        = 'AD Automatic fields'
                        field_type   = 'Heading'
                        show_in_list = 'false'
                        position     = 10
                    },
                    @{
                        label        = 'Given Name'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 11
                    },
                    @{
                        label        = 'sn'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 11
                    },
                    @{
                        label        = 'Distinguished Name'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 12
                    },
                    @{
                        label        = 'User Principal Name'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 13
                    },
                    @{
                        label        = 'SAM Account Name'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 14
                    },
                    @{
                        label        = 'Employee ID'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 15
                    },
                    @{
                        label        = 'Manager'
                        field_type   = 'AssetTag'
                        show_in_list = 'false'
                        linkable_id  = $Layout.id
                        position     = 16
                    },
                    @{
                        label        = 'Direct Reports'
                        field_type   = 'AssetTag'
                        show_in_list = 'false'
                        linkable_id  = $Layout.id
                        position     = 17
                    },
                    @{
                        label        = 'Description'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 18
                    },
                    @{
                        label        = 'Address and Contact Information'
                        field_type   = 'Heading'
                        show_in_list = 'false'
                        position     = 19
                    },
                    @{
                        label        = 'Office Phone Number'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 20
                    },
                    @{
                        label        = 'Cell Phone Number'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 21
                    },
                    @{
                        label        = 'Address'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 22
                    },
                    @{
                        label        = 'City'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 23
                    },
                    @{
                        label        = 'State'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 24
                    },
                    @{
                        label        = 'ZipCode'
                        field_type   = 'RichText'
                        show_in_list = 'false'
                        position     = 25
                    },
                    @{
                        label        = 'Office'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 26
                    },
                    @{
                        label        = 'Company'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 27
                    },
                    @{
                        label        = 'Account Information'
                        field_type   = 'Heading'
                        show_in_list = 'false'
                        position     = 28
                    },
                    @{
                        label        = 'SID'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 29
                    },
                    @{
                        label        = 'Member of'
                        field_type   = 'AssetTag'
                        show_in_list = 'false'
                        linkable_id  = $Grouplayout.id
                        position     = 30
                    },
                    @{
                        label        = 'Account Expires'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 31
                    },
                    @{
                        label        = 'Last Logon Date'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 32
                    },
                    @{
                        label        = 'Created'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 33
                    },
                    @{
                        label        = 'Deleted'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 34
                    },
                    @{
                        label        = 'Primary Group'
                        field_type   = 'AssetTag'
                        show_in_list = 'false'
                        linkable_id  = $Grouplayout.id
                        position     = 35
                    },
                    @{
                        label        = 'Protected from Accidental deletion'
                        field_type   = 'Checkbox'
                        show_in_list = 'false'
                        position     = 36
                    },
                    @{
                        label        = 'Modified in AD'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 37
                    },
                    @{
                        label        = 'Restricted logon to Workstations'
                        field_type   = 'AssetTag'
                        show_in_list = 'false'
                        linkable_id  = $ComputerLayout.id
                        position     = 38
                    },
                    @{
                        label        = 'Password information'
                        field_type   = 'Heading'
                        show_in_list = 'false'
                        position     = 39
                    },
                    @{
                        label        = 'Last Bad Password Attemp'
                        field_type   = 'Date'
                        show_in_list = 'false'
                        position     = 40
                    },
                    @{
                        label        = 'Bad Password Count'
                        field_type   = 'Number'
                        show_in_list = 'false'
                        position     = 41
                    },
                    @{
                        label        = 'Cannot Change Password?'
                        field_type   = 'CheckBox'
                        show_in_list = 'false'
                        position     = 42
                    },
                    @{
                        label        = 'Password Never Expires?'
                        field_type   = 'CheckBox'
                        show_in_list = 'false'
                        position     = 43
                    },
                    @{
                        label        = 'Password Last Set'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 44
                    },
                    @{
                        label        = 'Password Expired'
                        field_type   = 'Text'
                        show_in_list = 'false'
                        position     = 45
                    },
                    @{
                        label        = 'Locked Out?'
                        field_type   = 'CheckBox'
                        show_in_list = 'false'
                        position     = 46
                    }
                )
			
                Write-Host "Creating New Asset Layout"
                $NewLayout = New-HuduAssetLayout -name $HuduAssetLayoutName -icon "fas fa-user-tie" -color "#A74Af1" -icon_color "#000000" -include_passwords $false -include_photos $false -include_comments $false -include_files $false -fields $AssetLayoutFields
                $Layout = Get-HuduAssetLayouts -name $HuduAssetLayoutName
			
            }
			
            #Collect Data
            ## You might need to also specify a server, depending on your AD enviroment. If you get authentication problems, just add a server at the end.
            $AllUsers = get-aduser -filter * -Properties *
            foreach ($User in $AllUsers) {
                $TaggedGroup = $null
                Write-Host "User: $($User.name)"
                $Membership = $User.MemberOf
                foreach ($Member in $Membership) {
                    #Tagging Groups
                    if ($Member) {
                        write-host "Searching for $Member"
                        $Group = (Get-HuduAssets -companyid $company.id -AssetLayoutId $Grouplayout.id) | Where-Object { $_.fields.label -eq 'Distinguished Name' -and $_.fields.value -eq $($Member) } | Select-Object id, slug, name
                        if ($Group) {
                            write-host "Found $Member"
                            IF ($null -eq $TaggedGroup) { $TaggedGroup = '{"id":' + $Group.id + ',"url":"/a/' + $Group.slug + '","name":"' + $Group.name + '"}' } else {
                                ## Each entry is enclosed by curly brackets and separated by comma
                                $TaggedGroup = $TaggedGroup + ',{"id":' + $Group.id + ',"url":"/a/' + $Group.slug + '","name":"' + $Group.name + '"}'
                            }
                        }
                    }
                }
                $TaggedGroup = '[' + $TaggedGroup + ']'
                ## Setting the primary group tag
                $TaggedPrimaryGroup = $null
                $PrimaryGroup = (Get-HuduAssets -companyid $company.id -AssetLayoutId $Grouplayout.id) | Where-Object { $_.fields.label -eq 'Distinguished Name' -and $_.fields.value -eq $($User.PrimaryGroup) } | Select-Object id, slug, name
                $TaggedPrimaryGroup = '[{"id":' + $PrimaryGroup.id + ',"url":"/a/' + $PrimaryGroup.slug + '","name":"' + $PrimaryGroup.name + '"}]'
                $TaggedReports = $null
                foreach ($Reports in $User.directReports) {
                    #tagging direct reports
                    if ($Reports) {
                        Write-Host "Searching for $Reports"
                        $ReportstoLink = (Get-HuduAssets -companyid $company.id -AssetLayoutId $Layout.id) | Where-Object { $_.Name -eq $((get-aduser $reports).Name) } | Select-Object id, slug, name
                        if ($ReportstoLink) {
                            Write-Host "Found $Reports"
                            IF ($null -eq $TaggedReports) { $TaggedReports = '{"id":' + $ReportstoLink.id + ',"url":"/a/' + $ReportstoLink.slug + '","name":"' + $ReportstoLink.name + '"}' } else {
                                ## Each entry is enclosed by curly brackets and separated by comma
                                $TaggedReports = $TaggedReports + ',{"id":' + $ReportstoLink.id + ',"url":"/a/' + $ReportstoLink.slug + '","name":"' + $ReportstoLink.name + '"}'
                            }                
                        }
                    }
                }
                $TaggedReports = '[' + $TaggedReports + ']'
                ## Tagging manager
                if ($User.Manager) {
                    $TaggedManager = $null
                    $manager = (Get-HuduAssets -companyid $company.id -AssetLayoutId $Layout.id) | Where-Object { $_.Name -eq $((get-aduser $User.Manager).Name) } | Select-Object id, slug, name
                    $TaggedManager = '[{"id":' + $manager.id + ',"url":"/a/' + $manager.slug + '","name":"' + $manager.name + '"}]'
                } else { Write-Host "there is no manager to set" }
                ## Tagging workstations if set
                $workstationtotag = $null
                if ($null -ne $User.LogonWorkstations) {
                    foreach ($Workstation in $user.LogonWorkstations) {
                        $workstationtotag = (Get-HuduAssets -companyid $company.id -AssetLayoutId $ComputerLayout.Id) | Where-Object { $_.Name -eq $($Workstation) } | Select-Object id, slug, name
                        IF ($null -eq $TaggedWorkstation) { $TaggedWorkstation = '{"id":' + $workstationtotag.id + ',"url":"/a/' + $workstationtotag.slug + '","name":"' + $workstationtotag.name + '"}' } else {
                            ## Each entry is enclosed by curly brackets and separated by comma
                            $TaggedWorkstation = $TaggedWorkstation + ',{"id":' + $workstationtotag.id + ',"url":"/a/' + $workstationtotag.slug + '","name":"' + $workstationtotag.name + '"}'
                        }                
                        $TaggedWorkstation = '{"id":' + $workstationtotag.id + ',"url":"/a/' + $workstationtotag.slug + '","name":"' + $workstationtotag.name + '"}'
                    }
                    $TaggedWorkstation = '[' + $TaggedWorkstation + ']'
                } else { Write-Host "The user $user.name is not restricted to specific workstations" }
                # Set the group's asset fields
                $AssetFields = @{
                    'person_name'                        = $User.name
                    'email_address'                      = $User.mail
                    'title'                              = $User.Title
                    'department'                         = $User.department
                    'given_name'                         = $User.GivenName
                    'sn'                                 = $User.sn
                    'DisplayName'                        = $User.displayname
                    'canonical_name'                     = $User.CanonicalName
                    'cn'                                 = $User.cn
                    'distinguished_name'                 = $User.distinguishedName
                    'user_principal_name'                = $User.UserPrincipalName
                    'sam_account_name'                   = $User.SamAccountName
                    'employee_id'                        = $User.EmployeeID
                    'manager'                            = $TaggedManager
                    'direct_reports'                     = $TaggedReports
                    'description'                        = $User.Description
                    'office_phone_number'                = $User.OfficePhone
                    'cell_phone_number'                  = $User.mobile
                    'address'                            = $User.StreetAddress
                    'city'                               = $User.city
                    'state'                              = $User.state
                    'zipcode'                            = $User.PostalCode
                    'office'                             = $User.Office
                    'company'                            = $User.Company
                    'guid'                               = [string]$User.SID
                    'member_of'                          = $TaggedGroup
                    'account_expires'                    = $User.AccountExpirationDate
                    'Last Logon Date'                    = $User.LastLogonDate
                    'created'                            = $User.Created
                    'deleted'                            = $User.Deleted
                    'primary_group'                      = $TaggedPrimaryGroup
                    'protected_from_accidental_deletion' = $User.ProtectedFromAccidentalDeletion
                    'modified_in_ad'                     = $User.Modified
                    'restricted_logon_to_workstations'   = $TaggedWorkstation
                    'last_bad_password_attempt'          = $User.LastBadPasswordAttempt
                    'bad_password_count'                 = $User.badPwdCount
                    'cannot_change_password?'            = $User.CannotChangePassword
                    'password_never_expires?'            = $User.PasswordNeverExpires
                    'locked_out?'                        = $User.LockedOut
                }
                #Upload data to Huhu. We try to match the users with an existing user.	
                $Asset = Get-HuduAssets -name $($User.name) -companyid $company.id -assetlayoutid $layout.id
                #If the Asset does not exist, we edit the body to be in the form of a new asset, if not, we just upload.
                if (!$Asset) {
                    Write-Host "Creating new Asset"
                    $Asset = New-HuduAsset -name $($User.name) -company_id $company.id -asset_layout_id $Layout.id -fields $AssetFields	
                } else {
                    Write-Host "Updating Asset"
                    $Asset = Set-HuduAsset -asset_id $Asset.id -name $($User.name) -company_id $company.id -asset_layout_id $layout.id -fields $AssetFields	
                }
            }
        } else { Write-Host "$HuduGroupLayout was not found in Hudu" } 
    } else { Write-Host "$ComputerLayout was not found in Hudu" }
} else { Write-Host "$CompanyName was not found in Hudu" }