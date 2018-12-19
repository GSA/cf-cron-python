# Running A Python Cron Job on Cloud Foundry

This repository demonstrates scheduling a Python script on Cloud Foundry using a traditional crontab, all within a Docker image.

Traditional cron daemons need to run as root and have opinionated defaults for logging and error notifications. This makes them unsuitable for running in a containerized environment like Docker. Instead of a system cron daemon, we're using [supercronic](https://github.com/aptible/supercronic) to run the cron tab. This method is demonstrated without a python script [here](https://github.com/Meshcloud/cf-cron). 

## How it works

This application uses `supercronic` on the `crontab` file, all within a Docker container. The `crontab` file specifies a single cron job, which is to execute `main.py` every 10 seconds. You could add additional jobs by adding new lines to `crontab` that specify a schedule and command.

Since some Python tasks are a bit more complicated than printing `datetime.datetime.now()`, this example also demos installation of many debian dependencies. Most of these support [`textract`](https://textract.readthedocs.io/en/stable/installation.html).

After `cf push`ing this app to a Cloud Foundry environment, you can see that it executes the job every ten seconds when you log the output with `cf logs APPNAME`:

```

```


