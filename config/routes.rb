if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    get 'timesheet/index', :to => 'timesheet#index'
    get 'timesheet/context_menu', :to => 'timesheet#context_menu'
    match 'timesheet/report', :to => 'timesheet#report', :via => [:get, :post]
    match 'timesheet/reset', :to => 'timesheet#reset', :via => :delete
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.connect 'timesheet/index', controller: 'timesheet', action: 'index'
    map.connect 'timesheet/context_menu', controller: 'timesheet', action: 'context_menu'
    map.connect 'timesheet/report.:format', controller: 'timesheet', action: 'report'
    map.connect 'timesheet/reset', controller: 'timesheet', action: 'reset', :conditions => { :method => :delete }
  end
end
