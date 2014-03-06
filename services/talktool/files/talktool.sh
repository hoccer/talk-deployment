#!/bin/bash

echo "starting hoccer command-line-client..."

#cat commands.conf | java -XX:-MaxFDLimit -Xmx12880m -jar jar/talktool.jar
java -XX:-MaxFDLimit -Xmx38640m -jar jar/talktool.jar $*

