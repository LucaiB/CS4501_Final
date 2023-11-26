import boto3


def create_transfer_family_server():
    transfer_client = boto3.client('transfer')
    response = transfer_client.create_server(EndpointType='PUBLIC', Protocols=['SFTP'])
    return response['ServerId']


def add_pgp_key_to_secrets_manager(pgp_private_key):
    secrets_client = boto3.client('secretsmanager')
    response = secrets_client.create_secret(Name='MyPGPPrivateKey', SecretString=pgp_private_key)
    return response['ARN']


def attach_workflow_to_server(server_id, workflow_id):
    transfer_client = boto3.client('transfer')
    transfer_client.associate_workflow(ServerId=server_id, WorkflowId=workflow_id)


def main():
    # Create Transfer Family Server
    server_id = create_transfer_family_server()
    print("Created Transfer Family server with ID:", server_id)

    # Add PGP Private Key to Secrets Manager
    pgp_private_key = ""  # TODO
    secret_arn = add_pgp_key_to_secrets_manager(pgp_private_key)
    print("Completed: ", secret_arn)

    # Attach Transfer Family Managed Workflow to the Server
    your_server_id = ''  # TODO
    workflow_id = ''  # TODO
    attach_workflow_to_server(your_server_id, workflow_id)
    print("Workflow attached successfully to the server.")


if __name__ == "__main__":
    main()
