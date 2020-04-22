require "./spec_helper"

describe "slack-cli --ls" do
  it "=> admin.apps.approve..." do
    run! "slack-cli --ls"
    output(2).should eq <<-EOF
admin.apps.approve
admin.apps.approved.list
EOF
  end
end

describe "slack-cli --ls users.info" do
  it "=> users.info" do
    run! "slack-cli --ls users.info"
    output.should eq("users.info")
  end
end

describe "slack-cli --ls users.info -v" do
  it "=> users.info (Gets information about a user.)" do
    run! "slack-cli --ls users.info -v"
    output.should start_with("users.info (Gets information about a user.)")
  end
end
