require 'thor'
require 'fileutils'
require 'json'
module Alex
  class Cli < Thor
    desc "new APPNAME", "This will start the new app wizard"
    long_desc <<-NEW_APP
    `new APPNAME` will start the new app wizard creating a new app with the name of your choosing.
    NEW_APP
    method_option :no_build, :type => :boolean, :default => false
    def new( appname )
      build = options[:no_build]
      puts "Creating template file for new app `#{appname}`...\n"
      db = ask("\nDatabase:\nUsing SQLite for development.\nWhich do you use for production?\n\n[0] PostgreSQL (default)\n[1] SQLite\n[2] None\n\n")
      db = 0 if db.blank?
      server_type = ask("\nServer Type:\nWhich type of server are you building?\n\n[0] WebServer (default)\n[1] API\n[2] WebServer + API\n\n")
      server_type = 0 if server_type.blank?
      if yes?("\nDevise:\nWould you like to install Devise? (default: No)")
        devise = true
        devise_model_name = ask("What would you like the user model to be called? [user]")
        devise_model_name = "user" if devise_model_name.blank?
        if yes?("Would you like to generate views and controllers for #{devise_model_name}? (default: No)")
          devise_model_scaffold = true
        else
          devise_model_scaffold = false
        end
        if yes?("Would you like Devise's views? (default: No)")
          devise_views = true
        else
          devise_views = false
        end
        if yes?("Would you like to have UserRoles? (default: No)")
          user_roles = true
          if yes?("\nCanCan:\nWould you like to install CanCan to handle authorization? (default: No)")
            cancan = true
          else
            cancan = false
          end
        else
          user_roles = false
        end
        if yes?("\nActiveAdmin:\nWould you like to install ActiveAdmin? (default: No)")
          active_admin = true
        else
          active_admin = false
        end
      else
          devise = false
      end
      if yes?("\nFigaro:\nWould you like to install Figaro? (default: No)")
        figaro = true
      else
        figaro = false
      end
      if server_type.to_i != 1 && yes?("\nCSS Frameworks:\nWould you like to install a CSS Frameworks? (default: No)")
        css = true
        css_fw = ask("Which CSS Framework would you like to use?\n\n[0] Bootstrap (default)\n[1] None\n\n")
        css_fw = 0 if css_fw.blank?
      else
        css = false
      end
      if server_type.to_i != 1 && yes?("\nControllers:\nWould you like me to create a PagesController for your root page? (default: No)")
        pages = true
      else
        pages = false
      end
      if devise && yes?("\nAPI:\nWould you like me to build the API auth? (default: No)")
        api_auth = true
      else
        api_auth = false
      end
      options = OpenStruct.new({
          :appname => appname,
          :db => db,
          :server_type => server_type,
          :devise => devise,
          :devise_model_name => devise_model_name,
          :devise_model_scaffold => devise_model_scaffold,
          :devise_views =>  devise_views,
          :user_roles => user_roles,
          :cancan =>  cancan,
          :active_admin => active_admin,
          :figaro => figaro,
          :css => css,
          :css_fw => css_fw,
          :pages => pages,
          :api_auth => api_auth
        })
      puts "\nBuilding template file in ./alex/#{options.appname}.rb"
      Alex.build_template(appname, options)
      puts "\nDone!\n\n"
      if !build
        puts "\nBuilding app applying template file ./alex/#{options.appname}.rb"
        system "rails new #{options.appname} -m .alex/#{options.appname}.rb"
        puts <<-'ALEX'

Done!


=======================================================

Your app is ready!

Now you just have to run the initilization.

Navigate to the app directory:
cd APPNAME/

And tell Alex to run the initilization:
alex init


=======================================================
        ALEX
      else
        puts <<-'ALEX'

Skip build app.
Done!


=======================================================

Your template is ready!

You ran Alex with the --no-build option
This means Alex just creates the template file inside .alex/

=======================================================
        ALEX
      end
    end
    desc "init", "This will run the initilization template of your app"
    long_desc <<-INIT_APP
    `init` will run the initilization template of your app.
    INIT_APP
    def init
      exec "rake rails:template LOCATION=config/alex/init.rb"
    end

    desc "unzip", "This will run the initilization template of your app"
    long_desc <<-INIT_APP
    `init` will run the initilization template of your app.
    INIT_APP
    def unzip(file, destination)
      Alex::Helpers::AlexHelper.unzip(file, destination)
    end

  end
end
