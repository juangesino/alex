require "alex/version"
require "alex/cli"
require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require 'json'

module Alex
  def self.build_template(appname, options)

          FileUtils.mkdir_p ".alex"
          template_file = File.new(".alex/#{appname}.rb", 'w')

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

          if options.pages
            # Create the controller
            init_file = init_file + "generate(:controller, \\'Pages\\',\\'index\\')\n"
            # Define route
            init_file = init_file + "gsub_file \\'config/routes.rb\\', \"get \\'pages/index\\'\", \"root \\'pages#index\\'\"\n"
          end


          if options.css
            case options.css_fw.to_i
              when 0
                # Add Bootstrap CSS
                # Download Bootstrap CSS
                init_file = init_file + "run \\'wget -P vendor/assets/stylesheets/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\\'\n"
                # Add CSS to application.css
                init_file = init_file + "insert_into_file \\'app/assets/stylesheets/application.css\\', \\'*= require bootstrap.min\n\\', before: \"*/\\n\"\n"
                # Download Bootstrap JS
                init_file = init_file + "run \\'wget -P vendor/assets/javascripts/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\\'\n"
                # Add JS to application.js
                init_file = init_file + "append_file \\'app/assets/javascripts/application.js\\', \\'//= require bootstrap.min\\'\n"
              else
            end
          end

          template_file.puts("append_file '.gitignore', '.idea/'")
          template_file.puts("git :init")

          template_file.puts("create_file 'config/alex/init.rb', '#{init_file}'")

          if options.server_type.to_i == 1 || options.server_type.to_i == 2
            if options.devise && yes?("\nAPI:\nWould you like me to build the API auth? (default: No)")
              ### START API CONFIG (WITH AUTH)
                    template_file.puts(<<-'ALEXGEN'
              append_file 'config/alex/init.rb', <<-'ALEX'
              gsub_file 'app/controllers/application_controller.rb', "protect_from_forgery with: :exception", ""

              inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
      protect_from_forgery with: :null_session
      before_filter :add_allow_credentials_headers

      def add_allow_credentials_headers
        response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, DELETE, PUT, PATCH, OPTIONS'
      end

      def options
        head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type, authorization, User-App-Token'
      end
              RUBY
              end

              create_file 'app/controllers/api/v1/api_controller.rb'

              append_file 'app/controllers/api/v1/api_controller.rb', <<-'RUBY'
    module Api
      module V1
        class ApiController < ApplicationController
          respond_to :json
          protect_from_forgery with: :null_session
          before_filter :check_token
          skip_before_filter :check_token, :only => [:auth]

          def current_user
            @current_user
          end

          def check_auth
            user = User.where(token: params[:token]).first
            if user
              respond_with @current_user
            else
              respond_with status: 402
            end
          end

          def auth
            authenticate_or_request_with_http_basic do |username, password|
              resource = User.find_by_email(username)
              if resource && resource.valid_password?(password)
                sign_in :user, resource
                @current_user = resource
                @current_user.token = Digest::MD5.hexdigest("#{DateTime.now}#{@current_user.email}")
                @current_user.save
                respond_with status: 200, token: @current_user.token, user: @current_user
              else
                respond_with status: 402
              end
            end
          end

          def check_token
            user = User.where(token: request.headers["User-App-Token"]).first
            if user && request.headers["User-App-Token"]
              @current_user = user
            else
              respond_with status: 402
            end
          end


        end
      end
    end

              RUBY

              inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-'RUBY'
      match '*any' => 'application#options', :via => [:options]
      namespace :api, defaults: {format: 'json'} do
        namespace :v1 do
          # Auth
          match "/auth" => "api#auth", via: [:get]
          match "/check_auth" => "api#check_auth", via: [:get]
        end
      end
              RUBY
              end

              ALEX
                    ALEXGEN
                    )
              ### START API CONFIG (WITH AUTH)
            else
              ### START API CONFIG (NO AUTH)
                    template_file.puts(<<-'ALEXGEN'
              append_file 'config/alex/init.rb', <<-'ALEX'
              gsub_file 'app/controllers/application_controller.rb', "protect_from_forgery with: :exception", ""

              inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
      protect_from_forgery with: :null_session
      before_filter :add_allow_credentials_headers

      def add_allow_credentials_headers
        response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
        response.headers['Access-Control-Allow-Credentials'] = 'true'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, DELETE, PUT, PATCH, OPTIONS'
      end

      def options
        head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type, authorization, User-App-Token'
      end
              RUBY
              end

              create_file 'app/controllers/api/v1/api_controller.rb'

              append_file 'app/controllers/api/v1/api_controller.rb', <<-'RUBY'
    module Api
      module V1
        class ApiController < ApplicationController
          respond_to :json
          protect_from_forgery with: :null_session

        end
      end
    end

              RUBY

              inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-'RUBY'
      match '*any' => 'application#options', :via => [:options]
      namespace :api, defaults: {format: 'json'} do
        namespace :v1 do

        end
      end
              RUBY
              end

              ALEX
                    ALEXGEN
                    )
              ### START API CONFIG (NO AUTH)
            end
          end


          template_file.puts(<<-'ALEXGEN'
    append_file 'config/alex/init.rb', <<-'ALEX'
    rake 'db:migrate'
    git add: '.', commit: '-m "Initial commit"'
    ALEX
          ALEXGEN
          )

          template_file.close

  end

end
