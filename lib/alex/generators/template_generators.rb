require "alex/generators/api_generators"
module Alex
  module Generators
    class TemplateGenerators
      def initialize(appname, options)
        FileUtils.mkdir_p ".alex"
        template_file = File.new(".alex/#{appname}.rb", 'w')
        if options.devise
          template_file.puts("gem 'devise'\n")
        end
        if options.cancan
          template_file.puts("gem 'cancan'\n")
        end
        if options.active_admin
          template_file.puts("gem 'activeadmin'\n")
        end
        if options.figaro
          template_file.puts("gem 'figaro'\n")
        end
        if options.db.to_i == 0
          template_file.puts("gsub_file 'Gemfile', \"gem \'sqlite3\'\", \"gem \'sqlite3\', group: :development\"\n")
          template_file.puts("gem('pg', group: :production)\n")
        elsif options.db.to_i == 1
        else
          template_file.puts("gsub_file 'Gemfile', \"gem \'sqlite3\'\", \"gem \'sqlite3\', group: :development\"\n")
        end
        template_file.puts("append_file '.gitignore', '.idea/'")
        template_file.puts("git :init")
        template_file.puts("create_file 'config/alex/init.rb', '\n### START INIT FILE\n\n'")
        if options.server_type.to_i == 1 || options.server_type.to_i == 2
          if options.devise && options.api_auth
            template_file.puts(Alex::Generators::ApiGenerators.auth)
          else
            template_file.puts(Alex::Generators::ApiGenerators.no_auth)
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
  end
end
