# QBot

[![Build status](https://badge.buildkite.com/d917655283d9ece85db04d0a5728658321a0d9178d1c83ceab.svg)](https://buildkite.com/raisebook/qbot) ~ [![Code Climate](https://codeclimate.com/repos/58634001dd44b6205d001a33/badges/7d91b94ede7b0ebab932/gpa.svg)](https://codeclimate.com/repos/58634001dd44b6205d001a33/feed)

A service that acts as a dispatcher of messages from SQS Queues to either HTTP(S) endpoints or AWS Lambda functions.

If the remote request fails, it will not be Acknowledged / Deleted on SQS, so any retry policies (including Dead Letter Queues) will be respected.

## Usage

### Step 1
Configure your SQS Queue with `QBotEndpoint` as metadata, for example, in the infrastructure repo:

```yaml
Resources:
  TestingQueue:
    Type: AWS::SQS::Queue
    Metadata:
      QBotEndpoint: "https://service.api.raisebook.com/graphql"
    Properties:    
      QueueName: $(AWS::StackName)-testing-queue
      etc: ...
```

or

```yaml
Resources:
  TestingLambdaQueue:
    Type: AWS::SQS::Queue
    Metadata:
      QBotEndpoint: $(MyFunction[Arn])
    Properties:
      QueueName: $(AWS::StackName)-testing-to-lambda
      etc: ...
```

If given a lambda ARN, then it will be (synchronously) invoked, and http(s) endpoints will be POST'ed to
 
### Step 2

Either send a message to the SQS queue directly (or pass it along from an SNS Topic).

## Message Format

```json
{
  "metadata": {
    "RequestID": "12345-12345-12345-12345-12345",
    "Authorization": "Bearer myt0ken",
    "Callback": "https://raisebook.dev/graphql"
  },
  "payload": {
    "my": "json payload"
  }
}
```

* Metadata block is optional
* If there is no metadata, wrapping the payload in a "payload" key is optional
* The payload itself should be in JSON format
* For Lambda invocations, the message will be passed through, as-is.

### Valid Metadata keys to HTTP Headers

| Metadata Key    | HTTP Header    |
|-----------------|----------------|
| CorrelationUUID | X-Request-ID   | 
| RequestID       | X-Request-ID   |
| Request_ID      | X-Request-ID   |
| X-Request-ID    | X-Request-ID   |
| Authorization   | Authorization  |
| Callback        | X-Callback     |


For _HTTP_ all other metadata keys will be **dropped**.

## Requeue items in the Dead Letter Queue

First, ensure you have exported your AWS credentials into your environment

Run ```qbot requeue <name of the queue>```

Let it run to completion - it looks like it hangs, but there is a 20 second timeout to make sure it cleares the queue out completely.

Looking for the code for this? Checkout https://github.com/raisebook/sqs-dead-letter-handling

## Raisebot

To save on typing docker-compose a thousand times a day, there is a helper application in the /bin folder. You can add ```PATH=./bin:$PATH``` to your bash_profile to speed things up even more.

Run ```qbot help``` for more information. You can run ```qbot help [command]``` for more information about a specific command.

__Note:__ The installation guide assumes the stockroom script is in your path - if you didn't add it, run ```bin/qbot``` instead.

This tool is a fork of [Sub](https://github.com/basecamp/sub)

## Installation

1. Check out the repository ```git clone git@github.com:raisebook/qbot```
1. run ```qbot build```
1. run ```qbot start```


![ROBOT](http://i.imgur.com/hBURPq9.jpg "Claptrap")

## Contributing

Please read the [Licence](LICENCE.md) and [Code of Conduct](COC.md) before contributing.

Patches can be submitted by following the usual GitHub "fork -> feature branch -> pull request" dance.

Thanks.
