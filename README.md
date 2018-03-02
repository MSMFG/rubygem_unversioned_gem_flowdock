# unversioned_gem_flowdock

This gem is aimed at providing CA Flowdock notifications during continuous delivery pipeline runs to highlight RubyGem installations that have missing version pins.

Logically it should be installed as early on as possible within your pipelines to analyse remaining gem install activity and is limited in it's dependencies to Ruby standard libraries and gem_pre_unversioned_install (which itself has been crafted to avoid additional dependencies).

Configuration is passed by environment variables as follows

## RUBYGEM_UNVERSIONED_FLOW

This is mandatory and needs to be set to the FLOW token associated with the flow that should receive the chat messages. Without this being set the module will not attempt to post anything and will report no errors.

## RUBYGEM_UNVERSIONED_HOSTNAME_CMD

Should you wish, you can provide a command to determine the hostname in place of the default hostname command. This command can be passed with arguments should you, for example, wish to use something like facter.

```
export RUBYGEM_UNVERSIONED_HOSTNAME_CMD='facter mycustomfactforhostnamesinmycompany'
```

This is primarily in recognition that companies may well have more meaningful information to locate a host than is present in the default hostname.

At runtime this is processed to determine that the command exists and is executable otherwise the default 'hostname' command will be used. This has been done in recognition that some gem checks may be performed within a pipeline _prior_ to the more useful hostname command being present upon the host - in this case early reports will give the hostname and later reports will provide the more meaningful information.

## RUBYGEM_UNVERSIONED_TEMPLATE

Indicates the _full_ path to an alternative ERB template that may be used to format the message as required - the template takes 3 variables 'hostname', 'name' and 'version' with the default template source looking like this..

```
**<%= hostname -%>** tried to install gem **<%= name -%>** without specifying a version.
RubyGems chose **<%= version %> automatically**. If you do not want to keep seeing this
message or performing an emergency fix in the future then please consider locating the
install and providing a version pinning
```

And producing output that looks like this..

RubyGems 11:20
**C02T6183G8WL** tried to install gem **net-ssh** without specifying a version.
RubyGems chose **4.2.0 automatically**. If you do not want to keep seeing this
message or performing an emergency fix in the future then please consider locating the
install and providing a version pinning #rubygems #version