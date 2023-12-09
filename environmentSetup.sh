#!/usr/bin/env bash

# Install necessary packages
echo "Installing required packages..."
sudo yum install -y gcc make glibc-static bzip2 gnupg2
echo "Required packages installed."

# Set up virtual environment
pip3 install virtualenv
virtualenv python_env
source python_env/bin/activate
pip3 install python-gnupg
deactivate

# Copy GnuPG binary and Python packages to a directory for the Lambda layer
mkdir -p lambda_layer/python
cp -r python_env/lib/python3.9/site-packages/* lambda_layer/python/
cp /usr/bin/gpg lambda_layer/python/

# Package for AWS Lambda Layer
cd lambda_layer
zip -r ../lambdaLayer.zip python/
cd ..
aws lambda publish-layer-version --layer-name python-gnupg --description "Python-GNUPG Module and GPG Binary" --zip-file fileb://lambdaLayer.zip --compatible-runtimes python3.9
echo "Lambda layer created successfully."
