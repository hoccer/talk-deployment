#!/bin/bash

echo "starting hoccer command-line-client..."

#cat commands.conf | java -XX:-MaxFDLimit -Xmx12880m -jar jar/hoccer-talk-tool-0.0.1-SNAPSHOT-jar-with-dependencies_nginx.jar
java -XX:-MaxFDLimit -Xmx38640m -jar jar/hoccer-talk-tool-0.0.1-SNAPSHOT-jar-with-dependencies_nginx.jar

