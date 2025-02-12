#!/bin/bash

# Title: Installation of Required Packages for GStreamer, FFmpeg, and Kinesis SDKs

echo "Updating package list..."
sudo apt update

echo "Installing required packages..."
sudo apt install -y \
  automake \
  build-essential \
  cmake \
  git \
  gstreamer1.0-plugins-base-apps \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-tools \
  libcurl4-openssl-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  liblog4cplus-dev \
  libssl-dev \
  pkg-config \
  ffmpeg \
  mkvtoolnix

echo "Installation of GStreamer and FFmpeg completed!"

# Install OpenJDK for JNI support
echo "Installing OpenJDK for JNI support..."
sudo apt install -y openjdk-11-jdk

# Set Java environment variables
echo "Setting JAVA_HOME and updating PATH..."
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Clone and build Kinesis Video Streams Producer SDK for C++
echo "Cloning and building Amazon Kinesis Video Streams Producer SDK for C++..."
cd
git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp.git
cd amazon-kinesis-video-streams-producer-sdk-cpp
mkdir -p build
cd build
cmake -DBUILD_GSTREAMER_PLUGIN=ON -DBUILD_JNI=TRUE ..
make

# Set environment variables for GStreamer plugin
echo "Setting GStreamer plugin paths..."
export GST_PLUGIN_PATH=`pwd`
export LD_LIBRARY_PATH=`pwd`/../open-source/local/lib

# Persist environment variables (optional)
echo "export GST_PLUGIN_PATH=$GST_PLUGIN_PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

cd

# Clone and build Amazon Kinesis Video Streams WebRTC SDK for C
echo "Cloning and building Amazon Kinesis Video Streams WebRTC SDK for C..."
git clone --recursive https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-c.git
mkdir -p ~/amazon-kinesis-video-streams-webrtc-sdk-c/build
cd ~/amazon-kinesis-video-streams-webrtc-sdk-c/build
cmake ..
make

# Check if kvssink plugin is installed and recognized
echo "Verifying kvssink GStreamer plugin..."
if gst-inspect-1.0 kvssink > /dev/null 2>&1; then
    echo "✅ Kinesis Video Streams GStreamer plugin (kvssink) is successfully installed!"
else
    echo "❌ Error: kvssink plugin not found. Check your GST_PLUGIN_PATH and build logs."
fi

echo "All installations and builds completed successfully!"
