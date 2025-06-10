# Resource Group Tags Implementation

## Overview
The Module09 launch-exercises.ps1 script has been updated to include mandatory tags for all Azure resource groups created during the exercises.

## Tags Applied
The following tags are automatically applied to all resource groups:

- `enablon:contact` - Set to `{STUDENT_ID}@example.com` (using the student's ID)
- `enablon:owner` - Set to `Environmental`
- `enablon:client` - Set to `Enablon Internal`
- `enablon:cost_center` - Set to `Environmental`

## Implementation Details

### Updated Commands
Two resource group creation commands were updated:

1. **Line 454** - Exercise 01 deployment script:
   ```powershell
   az group create --name $RESOURCE_GROUP --location $LOCATION --tags "enablon:contact=$STUDENT_ID@example.com" "enablon:owner=Environmental" "enablon:client=Enablon Internal" "enablon:cost_center=Environmental"
   ```

2. **Line 731** - Exercise 02 deployment script:
   ```powershell
   az group create --name $ResourceGroupName --location $Location --tags "enablon:contact=$STUDENT_ID@example.com" "enablon:owner=Environmental" "enablon:client=Enablon Internal" "enablon:cost_center=Environmental"
   ```

## Testing
A test script `test-resource-group-tags.ps1` has been created to verify the tags are applied correctly. Run it with:

```powershell
.\test-resource-group-tags.ps1
```

## Notes
- The student ID is used in the contact email tag to identify who created the resources
- These tags will help with resource tracking, cost allocation, and compliance requirements
- All resources created within these resource groups will inherit these tags by default (depending on Azure policies)