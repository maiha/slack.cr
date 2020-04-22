require "./spec_helper"

describe "slack-cli --version" do
  it "=> slack-cli #{Shard.version} ..." do
    run! "slack-cli --version"
    output.should start_with("slack-cli #{Shard.version}")
  end
end
