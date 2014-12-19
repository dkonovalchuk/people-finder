module Api
  class FindController < ApplicationController
    respond_to :json
    layout false

    def show
      render json: person_finder.result
    end

    private

    def person_finder
      @person_finder ||= ::PeopleFinder.new(params[:email], params[:name])
    end
  end
end