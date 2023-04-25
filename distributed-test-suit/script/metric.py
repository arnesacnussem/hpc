from ray.util.metrics import Counter, Histogram, Gauge


class Metric:
    def __init__(self):
        self.job_executed = Counter("hpc_job_executed", description="Total job executed", tag_keys=('errors',))
        self.job_succeed = Counter("hpc_job_success", description="Successfully corrected the error",
                                   tag_keys=('errors',))
        self.batch_generation = Gauge("hpc_batch_generationTime", description="Batch generation time")
        self.batch_execution = Gauge("hpc_batch_executionTime", description="Batch execution time")
