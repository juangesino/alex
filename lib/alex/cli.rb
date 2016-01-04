require 'thor'
require 'fileutils'
require 'json'

module Alex
  class Cli < Thor

    desc "new APPNAME", "This will start the new app wizard"
    long_desc <<-NEW_APP

    `new APPNAME` will start the new app wizard creating a new app with the name of your choosing.

    NEW_APP

    def new( appname )

      FileUtils.mkdir_p ".alex"
      template_file = File.new(".alex/#{appname}.rb", 'w')

      puts "Creating template file for new app `#{appname}`...\n"

      puts "\nDatabase:\n"
      puts "Using SQLite for development.\n"
      db = ask("Which do you use for production?\n\n[0] PostgreSQL (default)\n[1] SQLite\n[2] None\n\n")
      db = 0 if db.blank?

      # puts "\nServer Type:\n"
      # server_type = ask("Which type of server are you building?\n\n[0] WebServer (default)\n[1] API\n[2] WebServer + API\n\n")
      # server_type = 0 if server_type.blank?

      puts "\nDevise:\n"
      if yes?("Would you like to install Devise?")
        devise = true

        devise_model_name = ask("What would you like the user model to be called? [user]")
        devise_model_name = "user" if devise_model_name.blank?

        if yes?("Would you like to generate views and controllers for #{devise_model_name}?")
          devise_model_scaffold = true
        else
          devise_model_scaffold = false
        end

        if yes?("Would you like Devise's views?")
          devise_views = true
        else
          devise_views = false
        end

        if yes?("Would you like to have UserRoles?")
          user_roles = true
          puts "\nCanCan:\n"
          if yes?("Would you like to install CanCan to handle authorization?")
            cancan = true
          else
            cancan = false
          end
        else
          user_roles = false
        end

        puts "\nActiveAdmin:\n"
        if yes?("Would you like to install ActiveAdmin?")
          active_admin = true
        else
          active_admin = false
        end

      else
          devise = false
      end

      puts "\nFigaro:\n"
      if yes?("Would you like to install Figaro?")
        figaro = true
      else
        figaro = false
      end

      puts "\nCSS Frameworks:\n"
      if yes?("Would you like to install a CSS Frameworks?")
        css = true
        css_fw = ask("Which CSS Framework would you like to use?\n\n[0] Bootstrap (default)\n[1] None\n\n")
        css_fw = 0 if css_fw.blank?
      else
        css = false
      end


      options = OpenStruct.new({
          :appname => appname,
          :db => db,
          # :server_type => server_type,
          :devise => devise,
          :devise_model_name => devise_model_name,
          :devise_model_scaffold => devise_model_scaffold,
          :devise_views =>  devise_views,
          :user_roles => user_roles,
          :cancan =>  cancan,
          :active_admin => active_admin,
          :figaro => figaro,
          :css => css,
          :css_fw => css_fw
        })

      init_file = "gsub_file \"Gemfile\", \"gem \\'spring\\'\", \"\"\n"

      if options.devise
        template_file.puts("gem 'devise'\n")
        init_file = init_file + "generate \\'devise:install\\'\ngenerate \\'devise\\', \\'#{options.devise_model_name}\\'\n"

        if options.devise_views
          init_file = init_file + "generate \\'devise:views\\'\n"
        end

        if options.devise_model_scaffold
          init_file = init_file + "generate(:scaffold_controller, \\'#{options.devise_model_name}\\')\n"
          init_file = init_file + "insert_into_file \\'config/routes.rb\\', \"resources :users\\n\", after: \"devise_for :users\\n\" \n"
        end

      end

      if options.user_roles
        init_file = init_file + "generate(:scaffold, \\'user_role\\',\\'name:string\\',\\'-c=scaffold_controller\\')\n"
        init_file = init_file + "insert_into_file \\'app/models/user_role.rb\\', \"has_many :users\\n\", after: \"class UserRole < ActiveRecord::Base\\n\" \n"
        init_file = init_file + "insert_into_file \\'app/models/user.rb\\', \"belongs_to :user_role\\n\", after: \"class User < ActiveRecord::Base\\n\" \n"
        init_file = init_file + "generate(:migration, \\'AddUserRoleIdToUser\\',\\'user_role_id:integer\\')\n"
      end

      if options.cancan
        template_file.puts("gem 'cancan'\n")
        init_file = init_file + "generate \\'cancan:ability\\'\n"
      end

      if options.active_admin
        template_file.puts("gem 'activeadmin'\n")
        init_file = init_file + "generate \\'active_admin:install\\'\n"
        init_file = init_file + "generate \\'active_admin:resource #{options.devise_model_name}\\'\n"
        if options.user_roles
          init_file = init_file + "generate \\'active_admin:resource user_role\\'\n"
        end
      end

      if options.figaro
        template_file.puts("gem 'figaro'\n")
        init_file = init_file + "run \\'bundle exec figaro install\\'\n"
      end



      if options.db.to_i == 0
        template_file.puts("gsub_file 'Gemfile', \"gem \'sqlite3\'\", \"gem \'sqlite3\', group: :development\"\n")
        template_file.puts("gem('pg', group: :production)\n")
      elsif options.db.to_i == 1

      else
        template_file.puts("gsub_file 'Gemfile', \"gem \'sqlite3\'\", \"gem \'sqlite3\', group: :development\"\n")
      end


      if options.css
        case options.css_fw.to_i
          when 0
            # Add Bootstrap CSS
            # Download Bootstrap CSS
            init_file = init_file + "run \\'wget -P vendor/assets/stylesheets/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\\'\n"
            # Add CSS to application.css
            init_file = init_file + "insert_into_file \\'app/assets/stylesheets/application.css\\', \\'*= require bootstrap.min\n\\', before: \"*/\\n\"\n"
            # Download jQuery JS
            init_file = init_file + "run \\'wget -P vendor/assets/javascripts/ https://code.jquery.com/jquery-2.1.4.min.js\\'\n"
            # Add jQuery to application.js
            init_file = init_file + "append_file \\'app/assets/javascripts/application.js\\', \\'//= require jquery-2.1.4.min\\'\n"
            # Download Bootstrap JS
            init_file = init_file + "run \\'wget -P vendor/assets/javascripts/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\\'\n"
            # Add JS to application.js
            init_file = init_file + "append_file \\'app/assets/javascripts/application.js\\', \\'//= require bootstrap.min\\'\n"
          else
        end
      end

      init_file = init_file + "rake \\'db:migrate\\'\n"
      init_file = init_file + "git add: \\'.\\', commit: \\'-m \"initial commit\"\\'\n"

      template_file.puts("append_file '.gitignore', '.idea/'")
      template_file.puts("git :init")
      template_file.puts("create_file 'config/alex/init.rb', '#{init_file}'")
      template_file.close

      exec "rails new #{appname} -m .alex/#{appname}.rb"
    end

    desc "init", "This will run the initilization template of your app"
    long_desc <<-INIT_APP

    `init` will run the initilization template of your app.

    INIT_APP

    def init
      exec "rake rails:template LOCATION=config/alex/init.rb"
    end

  end
end
