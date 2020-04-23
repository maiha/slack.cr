require "spec"
require "../src/slack"
require "shard"
require "shell"

# Since we test in docker, we don't use __DIR__, but relative to project root
SLACK_CLI = "bin/slack-cli-dev"
OUT_PATH  = "tmp/spec/out"

LAST_SHELL = [Shell::Seq.new]
def shell : Shell::Seq
  LAST_SHELL[0]
end

def run(cmd : String, raw = false) : Shell::Seq
  cmd = cmd.gsub(/\s+/m, " ")
  cmd = cmd.sub(/slack-cli/, "#{SLACK_CLI}") unless raw
  Pretty.write(OUT_PATH, cmd)
  LAST_SHELL[0] = Shell::Seq.run("#{cmd} > #{OUT_PATH} 2>&1")
  unless raw
    system("sed -i -e 's/slack-cli-dev/slack-cli/g' #{OUT_PATH}") || fail("sed")
  end
  return shell
end

def run!(cmd : String) : Shell::Seq
  LAST_SHELL[0] = run(cmd)
  shell.success? || fail(output)
  return shell
end

def output(n : Int32? = nil) : String
  buf = File.read(OUT_PATH).chomp
  if n
    buf = buf.split(/\n/)[0,n].join("\n")
  end
  buf
end

def assert(buf)
  exp = buf.chomp.split(/n/)
  got = output.chomp.split(/n/)
  diff = Pretty.diff(exp, got)
  if diff.any?
    fail(diff.to_s)
  end
end
