module PluginHelper
  def yml_config_contents
    <<-FILE
      routes:
        pipelines:
          api:
            - post "/plugin", PluginController, :create
    FILE
  end
end
