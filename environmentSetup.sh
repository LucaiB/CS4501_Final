#!/usr/bin/env bash

# Define constants for paths and versions
USER_HOME="/home/cloudshell-user"
PYTHON_DIR="${USER_HOME}/python"
GNUPG_VERSION="gnupg-1.4.23"
LAYER_NAME="python-gnupg"
PYTHON_VERSION="python3.8"

# Install system packages
echo "Installing required system packages..."
sudo amazon-linux-extras enable ${PYTHON_VERSION}
sudo yum install ${PYTHON_VERSION} gcc make glibc-static bzip2 -y

# Install Python packages
echo "Installing Python packages..."
sudo pip3.8 install virtualenv
virtualenv ${PYTHON_DIR}
source ${PYTHON_DIR}/bin/activate
pip install python-gnupg
deactivate

# Prepare the directory structure
echo "Preparing directory structure..."
rm -rf ${PYTHON_DIR}/bin
mkdir -p ${PYTHON_DIR}/${PYTHON_VERSION}
mv ${PYTHON_DIR}/lib ${PYTHON_DIR}/${PYTHON_VERSION}/

# Download and build GPG from source
echo "Downloading and building GPG from source..."
wget "https://www.gnupg.org/ftp/gcrypt/gnupg/${GNUPG_VERSION}.tar.bz2" -O "${USER_HOME}/${GNUPG_VERSION}.tar.bz2"
tar xjf "${USER_HOME}/${GNUPG_VERSION}.tar.bz2" -C "${USER_HOME}"
cd "${USER_HOME}/${GNUPG_VERSION}"
./configure
make CFLAGS='-static'
cp g10/gpg ${PYTHON_DIR}/${PYTHON_VERSION}/
chmod o+x ${PYTHON_DIR}/${PYTHON_VERSION}/gpg

# Create the Lambda layer zip
echo "Creating Lambda layer zip..."
cd ${PYTHON_DIR}
zip -r "${USER_HOME}/lambdaLayer.zip" ${PYTHON_VERSION}/

# Publish the Lambda layer
echo "Publishing the Lambda layer..."
aws lambda publish-layer-version --layer-name ${LAYER_NAME} \
  --description "Python-GNUPG Module and GPG Binary" \
  --zip-file fileb://"${USER_HOME}/lambdaLayer.zip" \
  --compatible-runtimes ${PYTHON_VERSION}

echo "Lambda layer created successfully."
