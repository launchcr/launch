require "../spec_helper"

struct UserSocket < Launch::WebSockets::ClientSocket; end

struct RoomSocket < Launch::WebSockets::ClientSocket; end

describe Launch do
  describe ".env" do
    it "should return test" do
      Launch.env.test?.should be_truthy
      Launch.env.==("test").should be_truthy
      Launch.env.==("development").should be_falsey
      Launch.env.!=("development").should be_truthy
      Launch.env.!=("test").should be_falsey
    end
  end

  describe Launch::Server do
    describe ".configure" do
      it "defines socket endpoint" do
        Launch::Server.router.socket_routes = [] of NamedTuple(path: String, handler: Launch::WebSockets::Server::Handler)

        Launch::Server.configure do
          pipeline :web do
          end

          routes :web do
            websocket "/user", UserSocket
            websocket "/room", RoomSocket
          end
        end

        router = Launch::Server.router
        websockets = router.socket_routes

        websockets[0][:path].should eq "/user"
        websockets[0][:handler].is_a?(Launch::WebSockets::Server::Handler).should be_true
        websockets[1][:path].should eq "/room"
        websockets[1][:handler].is_a?(Launch::WebSockets::Server::Handler).should be_true
      end
    end
  end
end
