require 'grape_client/version'
require 'active_support/all'

module GrapeClient
  $LOAD_PATH.unshift(File.dirname(__FILE__))

  Dir["#{File.dirname(__FILE__)}/grape_client/*.rb"].each do |f|
    file = File.basename(f, File.extname(f))

    autoload file.camelize, "grape_client/#{file}"
  end
end
