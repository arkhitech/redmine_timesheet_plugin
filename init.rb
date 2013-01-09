require 'redmine'

## Taken from lib/redmine.rb
#if RUBY_VERSION < '1.9'
#  require 'faster_csv'
#else
#  require 'csv'
#  FCSV = CSV
#end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
  # if redmine plugins were railties:
  # object_to_prepare = config
end

object_to_prepare.to_prepare do
  require_dependency 'project'
  require_dependency 'principal'
  require_dependency 'user'
  Project.send(:include, RedmineTimesheetPlugin::Patches::ProjectPatch)
  User.send(:include, RedmineTimesheetPlugin::Patches::UserPatch)

  # Needed for the compatibility check
  begin
    require_dependency 'time_entry_activity'
  rescue LoadError
    # TimeEntryActivity is not available
  end
end

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_timesheet_plugin)
  Redmine::Plugin.register :redmine_timesheet_plugin do
    name 'Redmine Timesheet Plugin'
    author 'Hisham Malik'
    description 'This is a Timesheet plugin for Redmine to show timelogs for all projects'
    url 'http://github.com/techarete/redmine_timesheet_plugin'
    author_url 'https://github.com/hishammalik'

    version '0.7.0'
    requires_redmine :version_or_higher => '0.9.0'
    
    settings(:default => {
               'list_size' => '5',
               'precision' => '2',
               'project_status' => 'active',
               'user_status' => 'active'
             }, :partial => 'settings/timesheet_settings')

    permission :see_project_timesheets, { }, :require => :member

    menu(:top_menu,
         :timesheet,
         {:controller => :timesheet, :action => :index},
         :caption => :timesheet_title,
         :if => Proc.new {
           User.current.allowed_to?(:see_project_timesheets, nil, :global => true) ||
           User.current.allowed_to?(:view_time_entries, nil, :global => true) ||
           User.current.admin?
         })
  end
end
