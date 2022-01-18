module Admin
  class UssdMenusController < BaseController

    def index
      super
    end

    def show
      super
    end

    def new
      super
      @attributes[:end_request].update(boolean: true)
    end

    def create
      super
    end

    def edit
      super
      @attributes[:end_request].update(boolean: true)
    end

    def update
      super
    end
  end
end
