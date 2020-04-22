{% begin %}
TARGET_TRIPLE = "{{`crystal -v | grep x86_64 | cut -d: -f2`.strip}}"
CATALOG_INFO  = "{{`cat gen/catalog.info`.strip}}"
{% end %}
PROGRAM = File.basename(PROGRAM_NAME)
VERSION = Shard.version
