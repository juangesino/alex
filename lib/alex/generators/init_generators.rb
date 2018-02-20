module Alex
  module Generators
    class InitGenerators
      def initialize(appname, options)
        template_file = File.open(".alex/#{appname}.rb", 'a')
        init_file = "gsub_file \"Gemfile\", \"gem \\'spring\\'\", \"\"\n"
        if options.devise
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
          init_file = init_file + "generate \\'cancan:ability\\'\n"
        end
        if options.active_admin
          init_file = init_file + "generate \\'active_admin:install\\'\n"
          init_file = init_file + "generate \\'active_admin:resource #{options.devise_model_name}\\'\n"
          if options.user_roles
            init_file = init_file + "generate \\'active_admin:resource user_role\\'\n"
          end
        end
        if options.figaro
          init_file = init_file + "run \\'bundle exec figaro install\\'\n"
        end
        if options.pages
          init_file = init_file + "generate(:controller, \\'Pages\\',\\'index\\')\n"
          init_file = init_file + "gsub_file \\'config/routes.rb\\', \"get \\'pages/index\\'\", \"root \\'pages#index\\'\"\n"
        end
        if options.css
          case options.css_fw.to_i
            when 0
              init_file = init_file + "run \\'wget -P vendor/assets/stylesheets/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\\'\n"
              init_file = init_file + "insert_into_file \\'app/assets/stylesheets/application.css\\', \\'*= require bootstrap.min\n\\', before: \"*/\\n\"\n"
              init_file = init_file + "run \\'wget -P vendor/assets/javascripts/ https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\\'\n"
              init_file = init_file + "append_file \\'app/assets/javascripts/application.js\\', \\'//= require bootstrap.min\\'\n"
            else
          end
        end
        if options.css_fw.to_i > 1
          init_file = init_file + "run \\'alex style #{options.css_template}\\'\n"
        end
        # init_file = "gsub_file \"Gemfile\", \"gem \\'alex\\'\", \"\"\n"
        # init_file = "gsub_file \"Gemfile\", \"gem \\'zip\\'\", \"\"\n"
        template_file.write("insert_into_file 'config/alex/init.rb', '#{init_file}\n', after: '### START INIT FILE\n'")
        template_file.close
      end
    end
  end
end
