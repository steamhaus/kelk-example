'''
Based on https://github.com/dbnegative/lambda-cloudfront-log-ingester

MIT License

Original work Copyright (c) 2016 Jason Witting
Modified work Copyright (c) 2017 Steamhaus

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''
import os
import gzip
import csv
import dateutil.parser
import boto3
import datetime
from aws_requests_auth.boto_utils import BotoAWSRequestsAuth
from elasticsearch import Elasticsearch, RequestsHttpConnection
from elasticsearch import helpers

FIELDNAMES = (
    'type',
    'timestamp',
    'elb',
    'client_port',
    'target_port',
    'request_processing_time',
    'target_processing_time',
    'response_processing_time',
    'elb_status_code',
    'target_status_code',
    'received_bytes',
    'sent_bytes',
    'request',
    'user_agent',
    'ssl_cipher',
    'ssl_protocol',
    'target_group_arn',
    'trace_id',
    'domain_name',
    'chosen_cert_arn'
)


def parse_log(filename):
    recordset = []

    log = gzip.open(filename, mode='rt')
    csv.register_dialect('space', delimiter=' ', quoting=csv.QUOTE_MINIMAL)
    parsed_log = csv.DictReader(log, fieldnames=FIELDNAMES, dialect="space")

    date = datetime.datetime.today().strftime('%Y-%m-%d')

    for row in parsed_log:
        timestamp_string = row.pop('timestamp')
        row['timestamp'] = dateutil.parser.parse(timestamp_string)
        record = {
            "_index": "alb-logs-" + date,
            "_type": "logs",
            "_source": row
        }
        # append to recordset
        recordset.append(record)

    return recordset


def write_bulk(record_set, es_client):
    print("Writing data to ES")
    resp = helpers.bulk(es_client,
                        record_set,
                        chunk_size=1000,
                        timeout="60s")
    return resp


def lambda_handler(event, context):
    auth = BotoAWSRequestsAuth(aws_host=os.environ['ES_HOST'],
                               aws_region=os.environ['ES_REGION'],
                               aws_service='es')

    es_client = Elasticsearch(host=os.environ['ES_HOST'],
                              port=443,
                              use_ssl=True,
                              connection_class=RequestsHttpConnection,
                              http_auth=auth)

    s3_client = boto3.client('s3')

    event_bucket = event['Records'][0]['s3']['bucket']['name']
    event_key = event['Records'][0]['s3']['object']['key']
    downloaded_file_path = '/tmp/alb_log.gz'
    s3_client.download_file(event_bucket, event_key, downloaded_file_path)

    record_set = parse_log('/tmp/alb_log.gz')

    resp = write_bulk(record_set, es_client)
    print(resp)
