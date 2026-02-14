module ApplicationHelper

  def evaluate_page_title(fallback: "CrewCert")
    lookup_key = "#{controller_name}.page_titles.#{action_name}"
    action_fallback_name =
      {
        "create" => "new",
        "update" => "edit"
      }[action_name]

    if content_for?(:page_title)
      content_for(:page_title)
    elsif I18n.exists?(lookup_key)
      t(lookup_key)
    elsif action_fallback_name.present? && I18n.exists?("#{controller_name}.page_titles.#{action_fallback_name}")
      t("#{controller_name}.page_titles.#{action_fallback_name}")
    else
      fallback
    end
  end

  def evaluate_page_subtitle(fallback: nil)
    lookup_key = "#{controller_name}.page_subtitles.#{action_name}"
    action_fallback_name =
      {
        "create" => "new",
        "update" => "edit"
      }[action_name]

    if content_for?(:page_subtitle)
      content_for(:page_subtitle)
    elsif I18n.exists?(lookup_key)
      t(lookup_key)
    elsif action_fallback_name.present? && I18n.exists?("#{controller_name}.page_subtitles.#{action_fallback_name}")
      t("#{controller_name}.page_subtitles.#{action_fallback_name}")
    else
      fallback
    end
  end
end
