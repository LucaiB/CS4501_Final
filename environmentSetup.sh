#!/usr/bin/env bash

# Install necessary python packages
echo "Installing required packages..."
sudo yum install gcc make glibc-static bzip2 -y  # Python 3.8 and pip should already be available in CloudShell
echo "Required packages installed."

# Set up virtual environment
pip3 install virtualenv  # Use pip3 as Python 3.8 is default in CloudShell
virtualenv python_env
source python_env/bin/activate
pip3 install python-gnupg
deactivate
rm -rf ./python_env/bin
mkdir ./python_env/lib_package
mv python_env/lib64/python3.8/site-packages/* ./python_env/lib_package/

# Download and build GPG binary from source
wget https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-1.4.23.tar.bz2
tar xjf gnupg-1.4.23.tar.bz2
cd gnupg-1.4.23
./configure
make CFLAGS='-static'
cp g10/gpg ../python_env/lib_package
cd ../python_env
chmod o+x lib_package/gpg

# Package for AWS Lambda Layer
zip -r lambdaLayer.zip lib_package/
aws lambda publish-layer-version --layer-name python-gnupg --description "Python-GNUPG Module and GPG Binary" --zip-file fileb://lambdaLayer.zip --compatible-runtimes python3.8
echo "Lambda layer created successfully."
