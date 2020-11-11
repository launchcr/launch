require "../../spec_helper"

module Launch::Environment
  describe Loader do
    Dir.cd CURRENT_DIR

    it "loads a .env file into ENV" do
      Loader.new("./spec/support/config/.env").load_dotenv_files
      ENV["LAUNCH_TEST_ENV"].should eq "true"
    end

    it "can handle no .env file" do
      Loader.new("./invalid_dir").load_dotenv_files.should be_false
    end
  end
end
