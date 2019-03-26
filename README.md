# Running A Python Cron Job on Cloud Foundry

This repository demonstrates scheduling a Python script on Cloud Foundry using a traditional crontab within a Docker image.

Traditional cron daemons need to run as root and have opinionated defaults for logging and error notifications. This makes them unsuitable for running in a containerized environment like Docker. And Docker is sometimes preferable to Cloud Foundry buildpacks. So, instead of a system cron daemon, we're using [supercronic](https://github.com/aptible/supercronic) to run the cron tab. 

## How it works

This application uses `supercronic` on the `crontab` file, all within a Docker container. The `crontab` file specifies a single cron job, which is to execute `main.py` every 10 seconds. You could add additional jobs by adding new lines to `crontab` that specify a schedule and command.

Since some Python tasks are a bit more complicated than printing `datetime.datetime.now()`, this example also demos installation of a few debian dependencies and just one python requirement.

The image based on this Dockerfile can be found on DockerHub, so you can push the app to cloud.gov with

```
cf push cf-cron-python --docker-image csmcallister/cf-cron-python
```

Then, after it builds, use `cf logs cf-cron-python --recent` to see the print messages.
