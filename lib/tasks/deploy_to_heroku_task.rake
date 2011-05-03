namespace :heroku do
  desc "Deploy to heroku"
  task :deploy do
    current_branch = `git branch | grep ^* | awk '{ print $2 }'`.strip
    Rake::Task['heroku:before_deploy'].invoke(current_branch)
    Rake::Task['heroku:update_code'].invoke(current_branch)
    Rake::Task['heroku:update_db'].invoke
    Rake::Task['heroku:after_deploy'].invoke
  end

  task :before_deploy, :branch do |t, args|
    puts "Deploying from branch '#{args[:branch]}' to heroku"
  end

  task :update_code, :branch do |t, args|
    puts "Starting update code on heroku"
    `git push heroku #{args[:branch]}`
    puts "Deployment Complete"
  end

  desc "Run migration on Heroku"
  task :update_db do
    puts 'Starting database update'
    `heroku rake db:migrate`
    puts 'Database was update success'
  end

  task :after_deploy do
    puts 'done...'
  end

  desc "Rename application and git remote. Run like rake heroku:rename_app[<old_name>,<new_name>]"
  task :rename_app, :old_name, :new_name do |t, args| 
    puts "Rename heroku application to '#{args.new_name}'"
    `heroku rename #{args.new_name} --app #{args.old_name}`
    `git remote rm heroku`
    `git remote add heroku git@heroku.com:#{args.new_name}.git`
    puts "Heroku application was change name to '#{args.new_name}'"
  end

  desc "Import local db to heroku. Run like rake rake heroku:import[<app_name>]"
  task :import, :app_name do |t, args|
    puts 'Databese import running...'
    `heroku db:pull --confirm #{args.app_name}`
    puts 'Database import finish success.'
  end

  desc "Export local db to heroku. Run like rake heroku:export[<app_name>]"
  task :export, :app_name do |t, args|
    puts 'Database export running...'
    `heroku db:push --confirm #{args.app_name}`
    puts 'Database export finish success.'
  end

end
