require "../../spec_helper"

module Launch::Environment
  describe Loader do
    Dir.cd CURRENT_DIR

    it "load .env file into ENV" do
      Loader.new("./spec/support/config/.env").load_dotenv_files
      ENV["LAUNCH_TEST_ENV"].should eq "true"
    end
  end
end
