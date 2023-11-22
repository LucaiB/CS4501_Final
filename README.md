# CS4501_Final
Final Project for CS4501


**CloudShell - Deploying setupEnvironment bash script and CloudFormation stacks.**
Open CloudShell within your AWS account.

Run the following command to clone this Git repository to access the required files for this project:

git clone https://github.com/aws-samples/pgp-decryption-for-transfer-family.git

Change into the new pgp-decryption-for-transfer-family directory:

cd pgp-decryption-for-transfer-family/

Run this command to give the setupEnvironment.sh script executable permissions:

chmod +x setupEnvironment.sh

Run this command to create the required IAM roles and Lambda layer:

./setupEnvironment.sh

Now, deploy the CloudFormation stack that will build IAM roles and Lambda function:

sam deploy --guided --capabilities CAPABILITY_NAMED_IAM

Respond to the following prompts:
Enter in a stack name:
Select a region: Press enter to leave as default
Enter in a name for the S3 bucket:
Confirm changes before deploy[y/N]: n
Allow SAM CLI IAM role creation[Y/n]: y
Disable rollback [y/N]: n
Save arguments to configuration file [Y/n]: y
SAM configuration file [samconfig.toml]: Press enter to leave as default
SAM configuration environment [default]: Press enter to leave as default
