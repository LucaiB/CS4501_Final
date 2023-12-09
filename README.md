# CS4501_Final
Final Project for CS4501

## Step-by-Step Instructions

### CloudShell - Deploying setupEnvironment bash script and CloudFormation stacks.

- Open CloudShell within your AWS account. 
- Run the following command to clone this Git repository to access the required files for this project: 
  
  `git clone https://github.com/LucaiB/CS4501_Final`
  
- Change into the new pgp-decryption-for-transfer-family directory: 
  
  `cd CS4501_Final/`

- Run this command to give the setupEnvironment.sh script executable permissions: 
  
  `chmod +x environmentSetup.sh`
  
- Run this command to create the required IAM roles and Lambda layer:
  
  `./environmentSetup.sh`
  
- Now, deploy the CloudFormation stack that will build IAM roles and Lambda function: 
  
  `sam deploy --guided --capabilities CAPABILITY_NAMED_IAM`
  
    - Respond to the following prompts: 
        - Enter in a stack name: 
        - Select a region: **Press enter to leave as default**
        - Enter in a name for the S3 bucket: 
        - Confirm changes before deploy[y/N]: **n**
        - Allow SAM CLI IAM role creation[Y/n]: **y**
        - Disable rollback [y/N]: **n**
        - Save arguments to configuration file [Y/n]: **y**
        - SAM configuration file [samconfig.toml]: **Press enter to leave as default**
        - SAM configuration environment [default]: **Press enter to leave as default**
     
---

**Creating Transfer Family Server by deploying a Transfer Family Server with a custom Secrets Manager based identity provider via CloudFormation stack.**

  - In CloudShell, run the following: 
    
    - Create a new directory for this CloudFormation stack and change into the new directory: 
        
        `mkdir tmp`  
        
        `cd tmp`
    
    - Download the CloudFormation stack using the link mentioned on the blog post linked above, at the time of creating this, the command is as follows: 
    
        `wget https://s3.amazonaws.com/aws-transfer-resources/custom-idp-templates/aws-transfer-custom-idp-secrets-manager-sourceip-protocol-support-apig.zip`

    - After downloading the zip, unzip it: 
  
        `unzip aws-transfer-custom-idp-secrets-manager-sourceip-protocol-support-apig.zip`
    
    - Run the following command:
  
        `sam deploy --guided`
    
    - Respond to the following prompts:
        - Enter in a stack name: 
        - Select a region: **Press enter to leave as default**
        - Parameter CreateServer [true]: **Press enter to leave as default**
        - Parameter SecretsManagerRegion []: **Press enter to leave as default**
        - Parameter TransferEndpointType [PUBLIC]: **Press enter to leave as default**
        - Parameter TransferSubnetIDs []: **Press enter to leave as default**
        - Parameter TransferVPCID []: **Press enter to leave as default**
        - Confirm changes before deploy[y/N]: **n**
        - Allow SAM CLI IAM role creation[Y/n]: **y**
        - Disable rollback [y/N]: **n**
        - Save arguments to configuration file [Y/n]: **y**
        - SAM configuration file [samconfig.toml]: **Press enter to leave as default**
        - SAM configuration environment [default]: **Press enter to leave as default**
     
---

### Deploy a Transfer Family server with a custom Secrets Manager based identity provider via CloudFormation stack
Navigate to the AWS Secrets Manager console (https://console.aws.amazon.com/secretsmanager)
Create a new secret by choosing Store a new secret.
Choose Other type of secret.
Create the following key-value pairs. The key names are case-sensitive.
<div align="center">
    
|         Secret Key                                                               |     Secret Value                                                                 |
|:--------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------:|
|       Password                                                                   |        TestPassword1234!                                                         |
|       Role                                                                       |      INSERT-TRANSER-FAMILY-USER-ROLE-ARN (Can be found in CloudFormation stack output) |
|       HomeDirectoryDetails                                                       |      [{"Entry": "/", "Target": "/**INSERT-S3-BUCKET-NAME/INSERT-USER-NAME**"}]   |
|       HomeDirectoryType                                                          |        LOGICAL                                                                   |

</div>       

#### Getting Required Values from CloudFormation Console
- To get the specific role ARN and S3 bucket name, go to the CloudFormation console and select:
    
    -  Stacks -> Stack 1 Name (Ex. pgpdecryptionstack) -> Outputs 


#### Finish Creating the Secret
 - Click "Next"
 - Name the secret in the format: **aws/transfer/server-id/username**
    - If you deployed Transfer Family CloudFormation stack: 
        - Go to CloudFormation console and select: Stacks -> Stack 1 Name (Ex. transferFamilyServer) -> Outputs
            - Select "ServerId"    
    - If you did not deploy Transfer Family CloudFormation stack: 
        - Go to the Transfer Family console, select "Servers", and then select the appropriate serverId. 
 
 - Select "Next" -> "Next" -> "Store"

---

### Adding Private Key to Secrets Manager
- Navigate to the AWS Secrets Manager console: https://console.aws.amazon.com/secretsmanager 
- Select "Secrets"
- Select the secret named: "PGP_PrivateKey"
- Select "Retrieve secret value"
- Select "Edit"
- Remove the text: "Within the Secrets Manager console, paste your PGP private key here"
- Paste in your PGP Private key
- Select "Save"

---

### Attach Managed Workflow to Transfer Family Server
- On the Transfer Family console, select "Servers"
- Select your desired Transfer Family server
- Under "Additional details", select "Edit"
- Select the Workflow with the description: "Transfer Family Workflow for PGP decryption process"
- Select the Managed workflow execution role with the name: "PGPDecryptionManagedWorkflowRole"
- Select "Save"
