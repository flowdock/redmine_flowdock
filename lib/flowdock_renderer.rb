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
    begin
      html_list = journal_details(journal.details).map { |detail| "<li>#{detail}</li>" }
      "<ul>#{html_list.join}</ul>"
    rescue => ex
      ""
    end
  end

  def wiki_diff_to_html(page)
    if page && page.content
      new_version = page.content.version
      old_version = if new_version > 1
        new_version - 1
      else
        nil
      end

      diff = page.diff(old_version, new_version)
      if diff
        "<pre>" +
          diff.to_html.
            gsub('class="diff_in"', 'style="background-color: #dfd"').
            gsub('class="diff_out"', 'style="background-color: #fdd; color: #999"') +
        "</pre>"
      else
        ""
      end
    else
      ""
    end
  end

  protected

  def journal_details(details)
    details_to_strings(details, true)
  end
end
