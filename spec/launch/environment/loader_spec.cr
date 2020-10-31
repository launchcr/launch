require "../../spec_helper"

module Launch::Environment
  describe Loader do
    Dir.cd CURRENT_DIR

    it "raises error for non existent credentials file" do
      expect_raises Launch::Exceptions::Credentials do
        Loader.new.credentials
      end
    end

    it "load settings from YAML file" do
      Loader.new("./spec/support/config/credentials.yml.enc").credentials["secret_key_base"].should eq SECRET_KEY
    end
  end
end
