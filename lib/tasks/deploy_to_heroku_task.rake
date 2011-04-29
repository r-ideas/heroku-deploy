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

  task :update_db do
    puts 'Starting database update'
    `heroku rake db:migrate`
    puts 'Database was update success'
  end

  task :after_deploy do
    puts 'done...'
  end

  task :rename_app, :newname do |t, args|
    puts "Rename heroku application to #{args[:newname]}"
  end

end
