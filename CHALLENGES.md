# Challenges I ran into

## ECS and RDS needing each other

The ECS task needs the database secret ARN from the RDS module, but the RDS
security group is supposed to only allow the ECS task's security group. When I
created the task security group inside the ECS module that made a loop: ECS
needs RDS, RDS needs ECS. I pulled the app security group up into the stack
module and passed its id down into both ECS and RDS. That broke the loop and the
database still only takes traffic from the app.

## State before the pipeline exists

Terraform wants to store its state in S3, but it can't create the very bucket
it's about to use for state. So I create the bucket, the DynamoDB lock table,
and the OIDC provider and role by hand once, and everything else runs in the
pipeline. I pass the bucket name at init time with backend-config instead of
hardcoding it.

## New image not actually deploying

At first I used update-service with force-new-deployment thinking it would ship
the new image, but that just reruns the existing task definition. The image is
part of the task def, not the service. So the deploy job now pulls the current
task def, swaps in the new image, registers a new revision, and rolls the
service to it. I also told the Terraform ECS service to ignore changes to the
task definition so it doesn't undo what the pipeline does.

## Rotating the password without breaking running tasks

I turned on daily rotation in Secrets Manager using the AWS Postgres rotation
function. The thing to watch is that ECS injects the secret when a task starts,
so a task that's already running keeps the old password until it restarts. Since
this is single user rotation, once the password changes the old one stops
working. For the assignment the tasks pick up the new value on their next
deploy or restart, and I noted that a fully hands off setup would have the app
re read the secret on reconnect. I also had to give the rotation lambda its own
security group and allow it into the database, and drop it in the app subnets so
it can actually reach RDS.

## No AWS keys in GitHub

Instead of putting an access key and secret into GitHub I set up OIDC. Actions
gets a short lived token and assumes a role whose trust policy is locked to my
repo. Nothing long lived is stored anywhere.

## Manual approval for production

Staging should deploy on its own but prod shouldn't. I used a GitHub environment
called production with myself as a required reviewer. Both the infra apply and
the app deploy target that environment, so the run stops and waits for me to
approve before it does anything to prod.

## ALB access logs failing to write

Turning on ALB access logs didn't work until the log bucket allowed the regional
ELB account to put objects. I looked that account up with the elb service
account data source and added a bucket policy, with a depends_on so the policy
is there before the ALB comes up.

## Caching the Docker build

To speed up image builds I added layer caching. In CI the layers cache in the
GitHub Actions cache, and in CD I push the cache to the ECR repo as a buildcache
tag so the next build reuses it. I first looked at using S3 for the docker cache
but the S3 buildkit backend is experimental and flaky in Actions, so the
registry cache in ECR was the reliable choice.

## Separating secrets from variables

Not everything the pipeline needs is actually secret. I kept the role ARN and
the Slack webhook as repository secrets, and moved the state bucket name and the
alert email to repository variables, read with vars instead of secrets.

## Things I'd do with more time

- tighten the deploy role, right now it's broad for convenience
- one NAT gateway per AZ for real high availability
- add HTTPS with an ACM cert and a redirect, and a WAF
- blue green deploys with CodeDeploy so rollbacks are instant
- copy snapshots to another region for disaster recovery
