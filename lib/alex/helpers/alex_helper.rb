require 'zip'

module Alex
  module Helpers
    class AlexHelper
      def self.unzip (file, destination)
          Zip::File.open(file) { |zip_file|
              zip_file.each { |f|
                  f_path=File.join(destination, f.name)
                  FileUtils.mkdir_p(File.dirname(f_path))
                  zip_file.extract(f, f_path) unless File.exist?(f_path)
              }
          }
      end
    end
  end
end
