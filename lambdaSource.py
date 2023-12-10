import boto3
from botocore.exceptions import ClientError
import os
import gnupg
import json
import logging
import pathlib

# Initialize AWS services
def initialize_aws_services():
    session = boto3.session.Session()
    aws_services = {
        'secrets_manager': session.client('secretsmanager'),
        's3_client': boto3.client('s3'),
        's3_resource': boto3.resource('s3'),
        'aws_transfer': boto3.client('transfer')
    }
    return aws_services

aws_services = initialize_aws_services()

# Constants
PRIVATE_KEY_NAME = 'PGP_PrivateKey'
TMP_DIR = '/tmp/'

# Retrieve secret from AWS Secrets Manager
def fetch_secret(secret_name):
    try:
        secret_value = aws_services['secrets_manager'].get_secret_value(SecretId=secret_name)
        return secret_value.get('SecretString')
    except ClientError as error:
        raise Exception(f"Error in fetch_secret: {error}")
    except Exception as e:
        raise Exception(f"Unexpected error in fetch_secret: {e}")

# Remove file extension
def strip_extension(file_path):
    return os.path.splitext(os.path.basename(file_path))[0]

# Create a temporary file
def create_temp_file(file_name='tempfile.txt'):
    temp_file_path = os.path.join(TMP_DIR, file_name)
    open(temp_file_path, 'w').close()
    return temp_file_path

# Download file from S3
def download_from_s3(bucket, key):
    file_path = os.path.join(TMP_DIR, os.path.basename(key))
    try:
        aws_services['s3_client'].download_file(bucket, key, file_path)
        return file_path if os.path.exists(file_path) else None
    except ClientError as error:
        logging.error(f"Error downloading from S3: {error}")
        return None

# Check if file is encrypted
def is_encrypted(file_path):
    file_ext = pathlib.Path(file_path).suffix.lower()
    if file_ext in ['.asc', '.gpg', '.pgp']:
        return True
    return False

# Send workflow status
def send_workflow_status(workflow_details, status):
    response = aws_services['aws_transfer'].send_workflow_step_state(
        WorkflowId=workflow_details['workflowId'],
        ExecutionId=workflow_details['executionId'],
        Token=workflow_details['token'],
        Status=status
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }

# Main Lambda handler function
def lambda_handler(event, context):
    file_key = event['fileLocation']['key']
    bucket_name = event['fileLocation']['bucket']
    username = event['serviceMetadata']['transferDetails']['userName']

    file_path = download_from_s3(bucket_name, file_key)
    if file_path:
        if is_encrypted(file_path):
            temp_file_path = create_temp_file()
            private_key = fetch_secret(PRIVATE_KEY_NAME)
            gpg = gnupg.GPG(gnupghome=TMP_DIR, gpgbinary='/opt/python/gpg', options=['--trust-model', 'always'])
            gpg.import_keys(private_key)
            with open(file_path, 'rb') as encrypted_file:
                decrypt_status = gpg.decrypt_file(encrypted_file, output=temp_file_path)
                if decrypt_status.ok:
                    new_file_name = strip_extension(os.path.basename(file_key))
                    new_file_path = f"DecryptedFiles/{username}/{new_file_name}"
                    aws_services['s3_client'].upload_file(temp_file_path, bucket_name, new_file_path)
                    send_workflow_status(event['serviceMetadata']['executionDetails'], 'SUCCESS')
                else:
                    send_workflow_status(event['serviceMetadata']['executionDetails'], 'FAILURE')
        else:
            new_file_path = f"DecryptedFiles/{username}/{os.path.basename(file_key)}"
            aws_services['s3_client'].upload_file(file_path, bucket_name, new_file_path)
            send_workflow_status(event['serviceMetadata']['executionDetails'], 'SUCCESS')
    else:
        send_workflow_status(event['serviceMetadata']['executionDetails'], 'FAILURE')
