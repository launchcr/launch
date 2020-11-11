module Launch::CLI
  class Scaffold < Generator
    command :scaffold
    property model : Generator
    property controller : Generator
    property view : Generator

    def initialize(name, fields)
      super(name, fields)
      @model = Model.new(name, fields)
      @view = ScaffoldPage.new(name, fields)
      @controller = Controller.new(name, fields)
    end

    def render(directory, **args)
      model.render(directory, **args)
      controller.render(directory, **args)
      view.render(directory, **args) if @config.mode != "minimal"
    end
  end
end
