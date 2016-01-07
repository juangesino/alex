require "alex/version"
require "alex/cli"
require "alex/generators/init_generators"
require "alex/generators/style_generators"
require "alex/generators/template_generators"
require "alex/generators/api_generators"
require "alex/helpers/alex_helper"
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
