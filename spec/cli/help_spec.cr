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
    output.chomp.should eq <<-EOF
usage: slack-cli users.info <user> [include_locale]

parameters:
    user              User to get info on
    include_locale    Set this to true to receive the locale for this user. Defaul...

examples:
    slack-cli users.info -d user=W1234567890 -d include_locale=true
    slack-cli users.info W1234567890 true
    slack-cli users.info W1234567890
EOF
  end
end

describe "slack-cli --help xxx" do
  it "=> No API found for 'xxx'. See 'slack-cli --ls'." do
    run  "slack-cli --help xxx"
    output.should eq "No API found for 'xxx'. See 'slack-cli --ls'."
  end
end
