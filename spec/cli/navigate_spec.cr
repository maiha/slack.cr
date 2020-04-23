require "./spec_helper"

describe "slack-cli" do
  it "=> usage: slack-cli" do
    run  "slack-cli"
    output.should start_with("usage: slack-cli")
    shell.exit_code.should eq(1)
  end
end

describe "slack-cli xxx" do
  it "=> No API found for 'xxx'. See 'slack-cli --ls'." do
    run  "slack-cli xxx"
    output.should eq "No API found for 'xxx'. See 'slack-cli --ls'."
    shell.exit_code.should eq(1)
  end
end
