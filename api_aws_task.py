import boto3

# get all the available services in the region(us-east-1)
session = boto3.Session()

services = session.get_available_services()

print(services)

# describe each ec2 instance details
ec2 = boto3.resource('ec2')
for instance in ec2.instances.all():
    print(instance.id, instance.state)

# describe each RDS instance details
client = boto3.client('rds')
response = client.describe_db_instances()
for i in response['DBInstances']:
    db_name = i['DBName']
    db_instance_name = i['DBInstanceIdentifier']
    db_type = i['DBInstanceClass']
    db_storage = i['AllocatedStorage']
    db_engine = i['Engine']
    print(db_instance_name, db_type, db_storage, db_engine)

# describe each S3 bucket in details
s3 = boto3.client('s3')
response = s3.list_buckets()['Buckets']
for bucket in response:
    print('Bucket name: {}, Created on: {}'.format(bucket['Name'], bucket['CreationDate']))