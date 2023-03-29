import pandas as pd
import boto3
import os
import json
import logging
import datetime


logger = logging.getLogger('MyLogger')
logger.setLevel(logging.INFO)


def transform_lambda_handler(event, context):
    files = list_csv_files()
    data_frames = read_csv(files)
    merge_data_frames(data_frames)


def list_csv_files():
    s3 = boto3.resource('s3')
    s3_bucket_json = json.loads(os.environ['OI_STORER_SECRET_STRING'])
    ingestion_bucket = s3.Bucket(s3_bucket_json['s3_bucket_name'])

    file_list = ['address', 'design', 'counterparty',
                 'purchase_order', 'staff', 'sales_order',
                 'payment', 'transaction', 'payment_type',
                 'currency', 'department']

    ingestion_csv_files = ingestion_bucket.objects.all()
    # print(ingestion_csv_files)

    for file in file_list:
        # print(summary_object)
        if file not in [item.key for item in ingestion_csv_files]:
            raise Exception('files are not complete')

    return [item.key for item in ingestion_csv_files]


def read_csv(key):
    s3 = boto3.client('s3')
    s3_bucket_json = json.loads(os.environ['OI_STORER_SECRET_STRING'])
    ingestion_bucket = s3_bucket_json['s3_bucket_name']

    try:

        obj = s3.get_object(Bucket=ingestion_bucket, Key=key)
        df = pd.read_csv(obj['Body'])
        return df

    except Exception as e:
        logger.error(f'An error occurred reading csv file: {e}')
        raise Exception()


def transform_currency(df_currency):
    return df_currency.drop(columns=['created_at', 'last_updated'])


def transform_design(df_design):
    return df_design.drop(columns=['created_at', 'last_updated'])


def transform_address(df_address):
    return df_address.drop(columns=['created_at', 'last_updated']).rename(
        columns={'address_id': 'location_id'})


def create_dim_date():
    df = pd.DataFrame(pd.date_range(
        '3/11/2022', '1/5/2023'), columns=['date'])
    df['date_id'] = df['date'].dt.strftime('%Y%m%d').astype(int)
    df['year'] = df['date'].dt.year
    df['month'] = df['date'].dt.month
    df['day'] = df['date'].dt.day
    df['day_of_week'] = df['date'].dt.dayofweek
    df['day_name'] = df['date'].dt.strftime("%A")
    df['month_name'] = df['date'].dt.strftime("%B")
    df['quarter'] = df['date'].dt.quarter

    return df.loc[:, df.columns != 'date']


def merge_data_frames():
    pass


def store_parquet():
    pass
