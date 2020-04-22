require "./spec_helper"

describe "slack-cli --help" do
  it "=> usage: slack-cli" do
    run! "slack-cli --help"
    output.should start_with("usage: slack-cli")
  end
end

describe "slack-cli --help users.info" do
  it "=> users.info (Gets information about a user.)" do
    run  "slack-cli --help users.info"
    output.should eq <<-EOF
users.info (Gets information about a user.)
  Argument       Example     Required Description
  -------------- ----------- -------- -------------------------------------------
  user           W1234567890 Required User to get info on
  include_locale true        Optional Set this to true to receive the locale f...
EOF
  end
end

describe "slack-cli --help xxx" do
  it "=> No API catalogs for [xxx]" do
    run  "slack-cli --help xxx"
    output.should start_with("No API catalogs for [xxx]")
  end
end
