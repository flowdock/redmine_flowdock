class FlowdockListener < Redmine::Hook::Listener
  INTEGRATION_SOURCE = 'Redmine'
  FLOWDOCK_API_HOST = 'api.flowdock.com'

  def controller_issues_new_after_save(context = {})
    set_data(context[:issue])

    subject = "Added \"#{@issue.subject}\" (#{@tracker})"
    body = "<pre>#{@issue.description}</pre>"

    send_message!(subject, body)
  end

  def controller_issues_edit_after_save(context = {})
    set_data(context[:issue])

    subject = "Updated \"#{@issue.subject}\" (#{@tracker})"

    send_message!(subject)
  end

  def controller_wiki_edit_after_save(context = {})
    set_data(context[:page])

    subject = "Updated \"#{@page.pretty_title}\" (Wiki)"

    send_message!(subject)
  end

  protected

  # Can be called after set_data
  def api_token
    @project && Setting.plugin_flowdock[:api_token][@project.identifier]
  end

  def set_data(object)
    @user_name = User.current.name
    @user_email = User.current.mail
    @url = get_url(object)

    case object
      when Issue then
        @issue = object
        @project = @issue.project
        @tracker = @issue.tracker.name
      when WikiPage then
        @page = object
        @project = @page.wiki.project
      else raise "FlowdockListener#set_data called for unknown object #{object.inspect}"
    end

    @project_name = @project.name
  end

  def send_message!(subject, body = "XXX")
    token = api_token
    return unless token

    post_data = {
      :source => INTEGRATION_SOURCE,
      :from_address => @user_email,
      :from_name => @user_name,
      :subject => subject,
      :content => body,
      :project => @project_name,
      :link => @url
    }

    RAILS_DEFAULT_LOGGER.info post_data.inspect

    # Don't block while posting to Flowdock.
    Thread.new do
      send_http_request!(token, post_data)
    end
  end

  def send_http_request!(token, post_data)
    req = Net::HTTP::Post.new("/v1/messages/team_inbox/#{token}")
    req.set_form_data(post_data)

    req['Content-Type'] = 'application/x-www-form-urlencoded'

    http = Net::HTTP.new(FLOWDOCK_API_HOST, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    begin
      http.start do |conn|
        conn.request(req)
      end
    rescue => ex
      RAILS_DEFAULT_LOGGER.error "Error posting to Flowdock: #{ex.to_s}"
    end
  end

  def get_url(object)
    path = case object
      when Issue then "issues/#{object.id}"
      when WikiPage then "projects/#{object.wiki.project.identifier}/wiki/#{object.title}"
      when Project then "projects/#{object.identifier}"
      else raise "FlowdockListener#get_url called for an unknown object #{object.inspect}"
    end

    "#{Setting[:protocol]}://#{Setting[:host_name]}/#{path}"
  end
end
