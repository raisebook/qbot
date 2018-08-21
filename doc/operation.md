# How to operate QBot

On startup, QBot queries cloudformation for queue names, and does this one stack at a time, based on the `AWS_STACKS` environment variable, 
and will start `WORKERS PER QUEUE` processes for each queue it finds.

It will only select queues that have the `QBotEndpoint` metadata defined for it.

**Be aware**: Starting a large number of QBot instances at the same time may cause you to encounter Cloudformation API Rate Limiting from AWS.
It is better to gradually add task instances until the required operational level is reached.

## Adding a new queue

  * If the queue exists in a Cloudformation stack QBot is already configured for, then simply restart QBot
      * This is easily done by scaling the service down to zero tasks, then back up to the required number
  * If the queue is in a new stack, then add it to the `*-ecs-task.yaml.erb` file and deploy your new version
  
## Removing a queue

It is **strongly** recommended that QBot be restarted once a queue has been removed. 
Otherwise QBot will repeatedly crash (and leak memory) while it tries to poll the missing queue.  
  
## Selectively listening on queues

If the `ONLY_QUEUES` environment variable is set, then (for all stacks) only the queues with names matching the list will be used

E.g. `ONLY_QUEUES=BackdockDumpComplianceDatabaseQueue,BackdockDumpDatabaseQueue,ApplicationFormReceivedQueue,DeploySpyQueue`
