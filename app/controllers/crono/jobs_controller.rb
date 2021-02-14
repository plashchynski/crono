module Crono
  class JobsController < ApplicationController
    def index
      @jobs = Crono::CronoJob.all
    end

    def show
      @job = Crono::CronoJob.find(params[:id])
    end
  end
end
