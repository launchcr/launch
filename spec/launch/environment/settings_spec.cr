require "../../spec_helper"

module Launch::Environment
  describe Settings do
    Spec.after_each do
      Launch::Server.configure do |settings|
        settings.port = 3001
        settings.name = "Launch_App"
      end
    end

    it "loads default environment settings" do
      settings = Launch::Environment::Settings.new

      settings.logging.severity.should eq Log::Severity::Debug
      settings.logging.colorize.should eq true
      settings.database_url.should eq ""
      settings.host.should eq "0.0.0.0"
      settings.name.should eq "Launch_App"
      settings.port.should eq 3001
      settings.port_reuse.should eq true
      settings.process_count.should eq 1
      settings.redis_url.should eq "redis://localhost:6379"
      settings.secret_key_base.should_not be_nil
      settings.session.should eq({
        :key => "launch.session", :store => :signed_cookie, :expires => 0,
      })
      settings.ssl_key_file.should be_nil
      settings.ssl_cert_file.should be_nil
    end

    it "defaults can be overwritten" do
      Launch::Server.configure do |settings|
        settings.port = 8080
        settings.name = "test_app"
      end

      Launch.settings.port.should eq 8080
      Launch.settings.name.should eq "test_app"
    end
  end
end
