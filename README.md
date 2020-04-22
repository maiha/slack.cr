# slack.cr

Simple CLI client to Slack API

```console
$ slack-cli --ls profile
team.profile.get
users.profile.get

$ slack-cli users.profile.get | jq .profile.email
"maiha@wota.jp"

$ slack-cli users.lookupByEmail -d email=maiha@wota.jp | jq .user.name
"maiha"
```

## Usage

```
usage: slack-cli [options...] <api> [<args>]
```

##### API Execution

If you want to call the `users.profile.get` API, just type it in!

```console
$ slack-cli users.profile.get
```

API parameters can be specified by `-d <key>=<val>'option.
For example, `users.lookupByEmail` API needs `email` parameter.

```console
$ slack-cli users.lookupByEmail -d email=maiha@wota.jp
{"ok":true,"user":{"name":"maiha","id":...
```

##### API Information

How do you know the parameters of the API? Well, just add the `-h`!

```console
$ slack-cli users.lookupByEmail -h 
API
  users.lookupByEmail (https://slack.com/api/users.lookupByEmail)
  Find a user with an email address.

Argument Example                 Required Description
-------- ----------------------- -------- -------------------------------------------
email    spengler@ghostbuster... Required An email address belonging to a user in ...
```

All API lists can be retrieved with the `--ls` option. Also, that list is filtered by ARG1.

```console
$ slack-cli --ls
admin.apps.approve
admin.apps.approved.list
...

$ slack-cli --ls users.list
admin.users.list
usergroups.users.list
```

## API Token

You can specify the *API TOKEN* in one of the following ways.

* by arg: `slack-cli --token XXXXX ...`
* by env: `SLACK_TOKEN=XXXXX slack-cli ...`

## API Catalog

slack-cli maintains a catalog of API information.
The catalog is bundled with slack-cli and can only be executed with APIs registered in it.
The original data for API information uses the following
* https://github.com/aki017/slack-api-docs

If you want to use a new API that doesn't exist in the built-in catalog,
you can specify the latest catalog information in the directory.

```console
$ git clone --depth 1 https://github.com/aki017/slack-api-docs.git
$ slack-cli -c slack-api-docs/methods ...
```

## Development

See [README.cr.md](README.cr.md)

## Contributing

1. Fork it (<https://github.com/maiha/slack.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
