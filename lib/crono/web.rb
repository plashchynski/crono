require 'haml'
require 'sinatra/base'
require 'crono'

module Crono
  # Web is a Web UI Sinatra app
  class Web < Sinatra::Base
    set :root, File.expand_path(File.dirname(__FILE__) + '/../../web')
    set :public_folder, proc { "#{root}/assets" }
    set :views, proc { "#{root}/views" }

    get '/' do
      @jobs = Crono::CronoJob.all
      haml :dashboard, format: :html5
    end

    get '/job/:id' do
      @job = Crono::CronoJob.find(params[:id])
      haml :job
    end
  end
end
