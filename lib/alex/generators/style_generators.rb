module Alex
  module Generators
    class StyleGenerators
      def initialize(template_name)
        puts "Running StyleGenerators"
        # Read which template to use
        puts "I will use template #{template_name}"
        # e.g.: template_name = "AdminLTE-2.3.0"
        # Wget folder from https://github.com/juangesino/alex-templates
        system "wget -P . https://github.com/juangesino/alex-templates/raw/master/#{template_name}.zip"
        # Unzip folder
        Alex::Helpers::AlexHelper.unzip("#{template_name}.zip", '.')
        # Copy files
        # CSS files to vendor/assets/stylesheets/
        Alex::Helpers::AlexHelper.move_recursively("#{template_name}/css", 'vendor/assets/stylesheets')
        # JS files to vendor/assets/javascripts/
        Alex::Helpers::AlexHelper.move_recursively("#{template_name}/js", 'vendor/assets/javascripts')
        # Fonts files to app/assets/fonts/
        FileUtils::mkdir_p 'app/assets/fonts/'
        Alex::Helpers::AlexHelper.move_recursively("#{template_name}/fonts", 'app/assets/fonts')
        # Images files to app/assets/images/
        Alex::Helpers::AlexHelper.move_recursively("#{template_name}/img", 'app/assets/images')
        # Less files to vendor/assets/less/
        FileUtils::mkdir_p 'vendor/assets/less/'
        Alex::Helpers::AlexHelper.move_recursively("#{template_name}/less", 'vendor/assets/less')
        # application.js file to app/assets/javascripts/
        FileUtils.mv("#{template_name}/application.js", "app/assets/javascripts", {:force => true, :verbose => true})
        # application.css file to app/assets/stylesheets/
        FileUtils.mv("#{template_name}/application.css", "app/assets/stylesheets", {:force => true, :verbose => true})
        # index.html.erb file to app/views/pages/
        FileUtils.mv("#{template_name}/index.html.erb", "app/views/pages", {:force => true, :verbose => true})
        # application.html.erb file to app/views/layouts/
        FileUtils.mv("#{template_name}/application.html.erb", "app/views/layouts", {:force => true, :verbose => true})
        # Delete folders
        FileUtils.rm_rf("#{template_name}.zip")
        FileUtils.rm_rf("#{template_name}")
      end
    end
  end
end
