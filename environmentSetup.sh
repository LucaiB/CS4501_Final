#!/usr/bin/env bash

# Check if gnupg2 is already installed; if not, install it
if ! command -v gpg > /dev/null 2>&1; then
    echo "Installing GnuPG..."
    sudo yum install -y gnupg2
else
    echo "GnuPG is already installed."
fi

echo "Installing other required packages..."
sudo yum install -y gcc make glibc-static bzip2
echo "Required packages installed."

# Set up virtual environment
pip3 install virtualenv
virtualenv python_env
source python_env/bin/activate
pip3 install python-gnupg
deactivate

# Prepare directory for the Lambda layer
mkdir -p lambda_layer/python
cp -r python_env/lib/python3.9/site-packages/* lambda_layer/python/
# Check if GnuPG binary is available and copy it
if [ -f "/usr/bin/gpg" ]; then
    cp /usr/bin/gpg lambda_layer/python/
fi

# Package for AWS Lambda Layer
cd lambda_layer
zip -r ../lambdaLayer.zip python/
cd ..
aws lambda publish-layer-version --layer-name python-gnupg --description "Python-GNUPG Module and GPG Binary" --zip-file fileb://lambdaLayer.zip --compatible-runtimes python3.9
echo "Lambda layer created successfully."
