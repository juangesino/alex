module Alex
  module Generators
    class ApiGenerators
      def self.auth
        return <<-'ALEXGEN'
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
      end
      def self.no_auth
        return <<-'ALEXGEN'
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
    end
    end
  end
end
