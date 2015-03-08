require 'haml'
require 'sinatra/base'

module Crono
  class Web < Sinatra::Base
    set :root, File.expand_path(File.dirname(__FILE__) + "/../../web")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views, Proc.new { "#{root}/views" }

    get '/' do
      @jobs = Crono::CronoJob.all
      haml :dashboard, format: :html5
    end

    get '/jobs/:id' do
      @job = Crono::CronoJob.find(params[:id])
      haml :job
    end
  end
end
