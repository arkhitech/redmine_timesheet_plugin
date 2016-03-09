module TimesheetHelper
  include ProjectsHelper

  def add_day_total? time_entries, time_entry_counter
    (time_entry_counter == (time_entries.length - 1)) ||
      (time_entries[time_entry_counter + 1].spent_on != time_entries[time_entry_counter].spent_on)
  end

  def calculate_day_total time_entries, time_entry_counter
    date = time_entries[time_entry_counter].spent_on
    hours_sum = 0
    while (time_entry_counter >= 0) && (time_entries[time_entry_counter].spent_on == date)
      hours_sum += time_entries[time_entry_counter].hours
      time_entry_counter -= 1
    end
    number_with_precision(hours_sum, :precision => @precision)
  end

  def showing_users(users)
    l(:timesheet_showing_users) + users.collect(&:name).join(', ')
  end

  def permalink_to_timesheet(timesheet)
    link_to(l(:timesheet_permalink),
      :controller => 'timesheet',
      :action => 'report',
      :timesheet => timesheet.to_param)
  end

  def link_to_csv_export(timesheet)
    link_to('CSV',
      {
        :controller => 'timesheet',
        :action => 'report',
        :format => 'csv',
        :timesheet => timesheet.to_param
      },
      :method => 'post',
      :class => 'icon icon-timesheet')
  end

  def form_for_to_timesheet(timesheet)
    params_like_decode_url = CGI.unescape({:timesheet => timesheet.to_param}.to_query)
    inputs = ""
    form = form_tag :controller => 'timesheet', :action => 'report' do
      params_like_decode_url.split("&").each do |param|
        param_arr = param.split("=")
        inputs << hidden_field_tag(param_arr.first, param_arr.last, :id => "")
      end
      inputs << submit_tag(l(:timesheet_permalink))
      inputs.html_safe
    end
    form.html_safe
  end

  def link_to_csv_export(timesheet)
    link_to('CSV',
            {
              :controller => 'timesheet',
              :action => 'report',
              :format => 'csv',
              :timesheet => timesheet.to_param
            },
            :method => 'post',
            :class => 'icon icon-timesheet')
  end

  def toggle_arrows(element, js_function)
    js = "#{js_function}('#{element}');"

    return toggle_arrow(element, 'toggle-arrow-closed.gif', js, false) +
        toggle_arrow(element, 'toggle-arrow-open.gif', js, true)
  end

  def toggle_arrow(element, image, js, hide=false)
    style = 'display:none;' if hide
    style ||= ''

    content_tag(:span,
                link_to_function(image_tag(image, :plugin => "redmine_timesheet_plugin"), js),
                :class => "toggle-" + element.to_s,
                :style => style
    )
  end

  def toggle_issue_arrows(issue_id)
    return toggle_arrows(issue_id, 'toggleTimeEntriesIssue')
  end
  
  def toggle_issue_arrows_date(spent_on)
    return toggle_arrows(spent_on, 'toggleTimeEntriesDate')
  end

  def displayed_time_entries_for_issue(time_entries)
    time_entries.collect(&:hours).sum
  end

  def project_options(timesheet)
    available_projects = timesheet.allowed_projects
    selected_projects = timesheet.projects
    selected_projects = available_projects if selected_projects.blank?
    project_tree_options_for_select(available_projects, :selected => selected_projects)
  end

  def activity_options(timesheet, activities)
    options_from_collection_for_select(activities, :id, :name, timesheet.activities)
  end
  
  def group_options(timesheet)
    available_groups = Group.all
    if timesheet.groups.first.class == Group
      selected_groups = timesheet.groups.collect{|g| g.id}
    else
      selected_groups = timesheet.groups
    end
    selected_groups = available_groups.collect{|g| g.id} if selected_groups.blank?
    options_from_collection_for_select(available_groups, :id, :name, :selected =>timesheet.groups)
  end

  def user_options(timesheet)
    available_users = Timesheet.viewable_users.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
    selected_users = timesheet.users

    options_from_collection_for_select(available_users,
      :id,
      :name,
      selected_users)

  end
  
  def options_for_period_select(value)
    options_for_select([[l(:label_all_time), 'all'],
                        [l(:label_today), 'today'],
                        [l(:label_yesterday), 'yesterday'],
                        [l(:label_this_week), 'current_week'],
                        [l(:label_last_week), 'last_week'],
                        [l(:label_last_n_weeks, 2), 'last_2_weeks'],
                        [l(:label_last_n_days, 7), '7_days'],
                        [l(:label_this_month), 'current_month'],
                        [l(:label_last_month), 'last_month'],
                        [l(:label_last_n_days, 30), '30_days'],
                        [l(:label_this_year), 'current_year']],
                        value)
  end
end
