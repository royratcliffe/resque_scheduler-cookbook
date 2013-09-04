#
# Cookbook Name:: resque_scheduler
# Recipe:: default
#
# Copyright 2013, Pioneering Software, United Kingdom
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
# EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
# EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#

# Install Git, the default recipe of the Git cookbook.
include_recipe 'git::default'

# Use the `application` cookbook for deployment. The application checks out from
# GitHub and appears on the server at `/app/resque_scheduler`.
application 'resque_scheduler' do
  path '/app/resque_scheduler'
  repository 'https://github.com/royratcliffe/resque_scheduler_app.git'
end

execute 'bundle install --path=vendor/bundle' do
  cwd '/app/resque_scheduler/current'
end

# Use Bluepill to launch the application. It launches the scheduler in the
# background. Note that it does not relaunch on reboot. Instead, the Bluepill
# will load and start it when the server next synchronises with the Chef
# server. This assumes that the server is a Chef client, naturally.
include_recipe 'bluepill::default'

# Set up the `REDIS_URL` environment variable if the Chef environment has a node
# matching the `redis` role. Assume that the `redis` node deploys Redis using
# the `redisio` cookbook. Pick up its IP adress and the Redis port.
redis = search(:node, "role:redis AND chef_environment:#{node.chef_environment}")[0]
template '/etc/bluepill/resque_scheduler.pill' do
  source 'resque_scheduler.pill.erb'
  variables :redis_url => "http://#{redis['ipaddress']}:#{redis['redisio']['servers'][0]['port']}" if redis
end

bluepill_service 'resque_scheduler' do
  action [:enable, :load, :start]
end
