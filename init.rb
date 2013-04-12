Redmine::Plugin.register :redmine_flowdock do
  name 'Flowdock'
  author 'Flowdock Ltd'
  description 'Notify your Flowdock flow about Redmine events'
  version '1.0.0'
  url 'https://github.com/flowdock/redmine_flowdock'

  Rails.configuration.to_prepare do
    require_dependency 'flowdock_listener'
    require_dependency 'flowdock_renderer'
  end

  settings :partial => 'settings/redmine_flowdock',
    :default => {
      :api_token => {}
    }
end
