# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

MAINTAINER Dockerfiles

# Use aliyun mirror as apt and pypi source
COPY sources.list /etc/apt/sources.list
COPY pip.conf /root/.pip/pip.conf

# Install required packages and remove the apt packages cache when done.
RUN apt-get update && \
    apt-get install -y \
        nginx \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        sqlite3 \
        supervisor && \
    rm -rf /var/lib/apt/lists/*

# Install uwsgi
RUN pip3 install --no-cache-dir --disable-pip-version-check uwsgi

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

# Copy requirements and install app dependencies
COPY requirements.txt /home/docker/code/
RUN pip3 install \
    --no-cache-dir \
    --disable-pip-version-check \
    --requirement /home/docker/code/requirements.txt

# Add (the rest of) our code
COPY . /home/docker/code/

EXPOSE 80
CMD ["supervisord", "-n"]
