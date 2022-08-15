# mitamae-plugin-resource-supervisord-program

This plugin provides supervisord_program resource to configure supervised process for [mitamae](https://github.com/itamae-kitchen/mitamae/tree/master).

## Example
```rb
supervisord_program 'osakana' do
  command "osakana --suisui"
  settings(
    stdout_logfile: "/var/log/supervisor/osakana_stdout.log",
    stderr_logfile: "/var/log/supervisor/osakana_stderr.log",
  )
end
```
## Actions
- supervise (default)
  - render configuration file and reload supervisord
- stop
  - `supervise` + `supervisorctl stop #{program}`
- start
  - `supervise` + `supervisorctl start #{program}`
- restart
  - `supervise` + `supervisorctl restart #{program}`

## Attributes

|Name|Value|Default|Required|Description
|:--:|:--:|:--:|:--:|:--:|
|action|Symbol|:supervise|Yes||
|command|String|(no default)|Yes|The command that will be run when this program is started. |
|settings|Hash|(no default)|No|[program:x section settings](http://supervisord.org/configuration.html#program-x-section-settings)|
