class StaticPagesController < ApplicationController

  def index
    @persons = config[:persons].paginate(page: params[:page], per_page: 10)
  end

  private

  def config
    @config ||= YAML.load_file("#{Rails.root}/config/persons.yml").symbolize_keys!
  end
end
