{% begin %}
TARGET_TRIPLE = "{{`crystal -v | grep x86_64 | cut -d: -f2`.strip}}"
CATALOG_INFO  = "{{`cat gen/catalog.info`.strip}}"
{% end %}
VERSION = Shard.version
