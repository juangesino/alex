require "alex/version"
require "alex/cli"
require "alex/generators/init_generators"
require "alex/generators/template_generators"
require 'active_support'
require 'active_support/core_ext'
require 'fileutils'
require 'json'

module Alex
  def self.build_template(appname, options)
    Alex::Generators::TemplateGenerators.new(appname, options)
    Alex::Generators::InitGenerators.new(appname, options)

  end

end
