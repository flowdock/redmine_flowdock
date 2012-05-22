require 'redmine'
require_dependency 'flowdock_renderer'
require_dependency 'flowdock_listener'

Redmine::Plugin.register :flowdock do
  name 'Flowdock'
  author 'Flowdock Ltd'
  description 'Notify your Flowdock flow about Redmine events'
  version '1.0.0'
  url 'https://github.com/flowdock/redmine_flowdock'

  settings :default => { :api_token => {} },
           :partial => 'flowdock/settings'
end
