module ApplicationHelper
  # Pagy 43+ has bootstrap_series_nav as an instance method on the Pagy object
  # This helper wraps it for convenience in views
  def pagy_bootstrap_nav(pagy)
    return '' if pagy.pages <= 1

    # Use Pagy 43+'s built-in bootstrap helper
    pagy.bootstrap_series_nav(classes: 'pagination mb-0').html_safe
  end

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

  def status_icon(status)
    case status
    when :valid
      content_tag(:i, "", class: "fas fa-check text-success")
    when :expiring_soon
      content_tag(:i, "", class: "fas fa-clock text-warning")
    when :pending
      content_tag(:i, "", class: "fas fa-hourglass-half text-info")
    when :missing
      content_tag(:i, "", class: "fas fa-times text-danger")
    when :expired
      content_tag(:i, "", class: "fas fa-exclamation-triangle text-secondary")
    when :rejected
      content_tag(:i, "", class: "fas fa-ban text-danger")
    else
      content_tag(:span, "-", class: "text-muted")
    end
  end
end
