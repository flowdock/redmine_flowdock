class FlowdockRenderer
  include Redmine::I18n
  include IssuesHelper

  def notes_to_html(journal)
    if journal && journal.notes
      "<p>#{journal.notes}</p>"
    else
      ""
    end
  end

  def details_to_html(journal)
    if journal && journal.details && journal.details.size > 0
      html_list = journal_details(journal.details).map { |detail| "<li>#{detail}</li>" }
      "<ul>#{html_list.join}</ul>"
    else
      ""
    end
  end

  protected

  def journal_details(details)
    details_to_strings(details, true)
  end
end
