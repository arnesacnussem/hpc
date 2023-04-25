import asyncio
import os.path

from ray.dashboard.modules.job.common import JobStatus
from ray.dashboard.modules.job.sdk import JobSubmissionClient

client = JobSubmissionClient("http://localhost:8265")

jidFN = "jid.txt"
jid = None
if os.path.isfile(jidFN):
    jidF = open(jidFN, "r")
    jid = jidF.read()
    status = client.get_job_status(jid)
    if status.is_terminal():
        print(f"Job {jid} Terminated with status {status.name}")
        # read log to extract latest progress
        logs = client.get_job_logs(jid)
        print(logs)
        exit(0 if status is JobStatus.SUCCEEDED else 1)

if jid is None:
    print(f"No existing job found, creating new...")
    jid = client.submit_job(
        entrypoint="python script.py",

        runtime_env={
            "env_vars": {
                "REDIS_HOST": "redis-master.kuberay.svc.cluster.local",
                "REDIS_PASSWORD": "X7WZakrtUk",
            },
            "working_dir": "./",
            "pip": [
                "oct2py",
                "redis[hiredis]"
            ]
        }
    )
    print(f"New job created {jid}.")
    # open(jidFN, "w+").write(jid)


async def follow_logs():
    print(f"Following logs of job {jid}")
    async for lines in client.tail_job_logs(jid):
        print(lines, end='')


asyncio.run(follow_logs())
print(f"Job {jid} Terminated with status {client.get_job_status(jid).name}")
