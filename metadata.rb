name             'resque_scheduler'
maintainer       'Pioneering Software, United Kingdom'
maintainer_email 'roy@pioneeringsoftware.co.uk'
license          'All rights reserved'
description      'Installs/Configures resque_scheduler'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

# Depends on Git because the application sources live at GitHub. The
# `application` cookbook does not automatically add that dependency.
%w(application git bluepill).each do |cb|
  depends cb
end
