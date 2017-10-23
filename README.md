# Docker image for OP5 Monitor
OP5 Monitor is a software product for server, Network monitoring and management based on the Open Source project Nagios.
This repository contains the OP5 Monitor software, in docker. It is also available on: [Docker Hub](https://hub.docker.com/r/op5com/op5-monitor)

![OP5 Monitor, in docker](https://user-images.githubusercontent.com/2470979/30489703-398bcd3e-9a38-11e7-88e3-8b2da7b67a4f.png)

> This image is not a OP5 official release and therefore does not adhere to your support agreement you may have with OP5.

## Features

 * Latest version of OP5 monitor to date (currently v7.3.17) on CentOS 6.9
 * Pre-bundled with a trial license
 * Support for **triggering hooks** on prestart, poststart and poststop. **Slack** hook example is included.
 * Support for **importing OP5 backup files** to help quickly launch testing/development environments
 * Support for **installing OP5 license keys**. Defaults to trial license if none if specified

## Install

Pull the docker image from Docker Hub:

```sh
$ docker pull op5com/op5-monitor
```

or, clone this repo to your docker server and build it:

```sh
$ git clone https://github.com/misiupajor/op5-monitor-docker.git
```

```sh
$ docker build --rm -t op5com/op5-monitor .
```

## Usage

Run the docker container:

```sh
$ docker run -tid -p 443:443 op5com/op5-monitor
```

Now you can reach OP5 Monitor on:

https://`<docker server>`:443

## Adding hooks (optional)

You can add custom hooks by adding any script to entrypoint.d/hooks/ directory. Ensure that they are well defined in entrypoint.d/hooks.json and that enabled is is true, something like this will work:

```json
{
        "prestart": [
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["prestart"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "contained_started"],
                "enabled": true
            }
        ],
        "poststart": [
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["poststart"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "contained_booted"],
                "enabled": true
            }
        ],
        "poststop":[
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["poststop"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "container_stopped"],
                "enabled": true
            }
        ]
}
```

And then build:

```sh
$ docker build --rm -t op5com/op5-monitor .
```

## Importing OP5 backup files (optional)

You can import existing OP5 backups. This can be helpful when you need to spin up an identical copy of your production OP5 servers, say for testing or development purposes.

In order to do so, you first need to create a **compatible** backup for docker on one of your OP5 master or peer server, using:
```sh
$ op5-backup -- -ssh -sysconfig -op5-system
```

Then place the backup file generated by op5-backup (ends with .backup-extension) in a folder locally on your docker host (eg: /tmp/backups/{backup file}.backup), and run your docker container:

```sh
$ docker run -tid -e -v /tmp/backups/:/usr/libexec/entrypoint.d/backups/ IMPORT_BACKUP=<backup file>.backup -p 443:443 op5com/op5-monitor
```

## Importing OP5 license keys (optional)

You can import your OP5 license key if needed. If not specified, it defaults to the trial license.

In order to do so, place your license key (eg. op5license.lic) in a folder locally on your docker host: (eg: /tmp/licenses/{license file}.lic), and then run your docker container:

```sh
$ docker run -tid -e -v /tmp/licenses/:/usr/libexec/entrypoint.d/licenses/ LICENSE_KEY=<license file>.lic -p 443:443 op5com/op5-monitor
```


## Contributors

Thanks goes to these wonderful people:

* Caesar Ahlenhed ([@MrFriday AB](https://www.mrfriday.com))
* Christian Nilsson ([@OP5](https://www.op5.com))
* Ken Dobbins ([@OP5](https://www.op5.com))
* Robert Claesson ([@OP5](https://www.op5.com))

## Author
**Misiu Pajor**

* [github/misiupajor](https://github.com/misiupajor)
