# Docker image for OP5 Monitor

OP5 Monitor is a software product for server, Network monitoring and management based on the Open Source project Nagios. 

The goal of this repository is to enable you to run a clean and base image of OP5 Monitor, in docker.

*See [OP5 Monitor Documentation	](https://kb.op5.com/x/KwCP) for User and Admin manual.*

## Includes

 * Latest version of OP5 monitor to date (currently v7.3.15)
 * Pre-bundled with a trial license


## Usage

Clone this repo to your docker server.

Build the docker image:

`$ docker build --tm t op5/monitor-base`

Run the docker container:

`$ docker run -tid -p 445:443 op5/monitor-base` 

Now you can reach OP5 Monitor on:

https://`<docker server>`:445

## Adding hooks

You can add custom hooks by adding any script to /entrypoint.d/hooks/ directory. Ensure that they are executable and defined in /entrypoint.d/hooks.json like this:

```json
{
        "start": [
            {
                "path": "/bin/echo",
                "args": ["--action", "container_started"]
            },
            {
                "path": "/usr/bin/echo",
                "args": ["arg1", "arg2"]
            }
        ],
        "stop":[
            {
                "path": "/bin/echo",
                "args": ["--update_cmdb"]
            },
            {
                "path": "/bin/echo",
                "args": ["--action", "container_stopped"]
            }
        ]
}
```
