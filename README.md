# Running A Python Cron Job on Cloud Foundry

This repository demonstrates how to run scheduled Python scripts on Cloud Foundry with a very small footprint using a traditional crontab.

Traditional cron daemons need to run as root and have opinionated defaults for logging and error notifications. This makes them unsuitable for running in a containerized environment like Cloud Foundry. Instead of a system cron daemon we're using [supercronic](https://github.com/aptible/supercronic) to run the cron tab. This method is demonstrated without a python script [here](https://github.com/Meshcloud/cf-cron).

## How it works

This application is built using the binary buildpack and executes `supercronic` on the `crontab` file. The `crontab` file specifies a single cron job, which is to execute `main.py`. You could add additional jobs by adding a new line to `crontab` which specifies a schedule and command to the `crontab`. 

> Note: By default, `supercronic` will log [all output to stderr](https://github.com/aptible/supercronic/issues/16) so we redirect that to stdout in the cf manifest. 

Since some python tasks are a bit more complicated, this example allows you to install apt and debian packages. All of the [`textract` dependencies](https://textract.readthedocs.io/en/stable/installation.html) are currently in `apt.yml` and they will be installed during staging by the cloudfoundry [apt-buildpack](https://github.com/cloudfoundry/apt-buildpack)
courtesy of [multi-buildpack](https://github.com/cloudfoundry/multi-buildpack).

After `cf push`ing this sample app to a Cloud Foundry environment, you can see that it executes the job every minute when you log the output with `cf logs APPNAME`:

```
   2018-11-02T15:43:00.00-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:43:00Z" level=info msg=starting iteration=4 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
   2018-11-02T15:43:00.03-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:43:00Z" level=info msg="something logged at: 2018-11-02 19:43:00.034843" channel=stdout iteration=4 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
   2018-11-02T15:43:00.03-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:43:00Z" level=info msg="job succeeded" iteration=4 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
   2018-11-02T15:44:00.00-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:44:00Z" level=info msg=starting iteration=5 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
   2018-11-02T15:44:00.02-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:44:00Z" level=info msg="something logged at: 2018-11-02 19:44:00.026139" channel=stdout iteration=5 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
   2018-11-02T15:44:00.02-0400 [APP/PROC/WEB/0] OUT time="2018-11-02T19:44:00Z" level=info msg="job succeeded" iteration=5 job.command="./main.py" job.position=0 job.schedule="*/1 * * * *"
```

## A Current Quirk
At present, `requirements.txt` includes `textract`, which is what requires all of those external dependencies in `apt.yml`. If you `cf push` without `requirements.txt` in your `.cfignore`, the build will fail with the following error log:

```
Running setup.py install for pocketsphinx: started
           Running setup.py install for pocketsphinx: finished with status 'error'
           Complete output from command /tmp/contents763013409/deps/1/bin/python -u -c "import setuptools, tokenize;__file__='/tmp/pip-build-b0sqvgls/pocketsphinx/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /tmp/pip-jwvjcs6k-record/install-record.txt --single-version-externally-managed--compile:
           running install
           running build_ext
           building 'sphinxbase._ad' extension
           swigging swig/sphinxbase/ad.i to swig/sphinxbase/ad_wrap.c
           swig -python -modern -Ideps/sphinxbase/include -Ideps/sphinxbase/include/sphinxbase -Ideps/sphinxbase/include/android -Ideps/sphinxbase/swig -outdir sphinxbase -o swig/sphinxbase/ad_wrap.c swig/sphinxbase/ad.i
           :1: Error: Unable to find 'swig.swg'
           :3: Error: Unable to find 'python.swg'
           swig/sphinxbase/ad.i:56: Error: Unable to find 'pybuffer.i'
           deps/sphinxbase/swig/typemaps.i:1: Error: Unable to find 'exception.i'
           swig/sphinxbase/ad.i:99: Error: Unable to find 'pybuffer.i'
           error: command 'swig' failed with exit status 1
           ----------------------------------------
       Command "/tmp/contents763013409/deps/1/bin/python -u -c "import setuptools, tokenize;__file__='/tmp/pip-build-b0sqvgls/pocketsphinx/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /tmp/pip-jwvjcs6k-record/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /tmp/pip-build-b0sqvgls/pocketsphinx/
       You are using pip version 9.0.3, however version 18.1 is available.
       You should consider upgrading via the 'pip install --upgrade pip' command.
       **ERROR** Could not install pip packages: Couldn't run pip: exit status 1
       **ERROR** Unable to run all buildpacks: Failed to run all supply scripts: exit status 14
Failed to compile droplet: Failed to compile droplet: exit status 13
Exit status 223
```

Include it and the build passes. 

Future work in here is aimed at resolving this issue so that more complicated python scripts can be scheduled.
