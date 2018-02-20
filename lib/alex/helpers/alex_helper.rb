require 'zip'

module Alex
  module Helpers
    class AlexHelper
      def self.unzip (file, destination)
        Zip::ZipFile.open(file) { |zip_file|
          zip_file.each { |f|
            f_path=File.join(destination, f.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            zip_file.extract(f, f_path) unless File.exist?(f_path)
          }
        }
      end
      def self.move_recursively(origin, destination)
        Dir.glob(File.join("#{origin}", '*')).each do |file|
          FileUtils.move file, File.join("#{destination}", File.basename(file)), {:force => true, :verbose => true}
        end
      end
    end
  end
end
