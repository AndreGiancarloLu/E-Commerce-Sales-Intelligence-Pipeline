
from dotenv import load_dotenv
from google.cloud import bigquery
from google.cloud import storage
from io import BytesIO
import pandas as pd
import os
import sys
from google.api_core.exceptions import GoogleAPIError

# Load environment variables from .env file
load_dotenv()

def fetch_bigquery_data(table_name: str) -> pd.DataFrame:
    try:
        creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        project    = os.getenv("BQ_PROJECT")

        if not creds_path:
            raise ValueError("GOOGLE_APPLICATION_CREDENTIALS not set in .env")
        if not project:
            raise ValueError("BQ_PROJECT not set in .env")

        # Initialize BigQuery client
        client = bigquery.Client(project=project)

        # Example: Query the public dataset `bigquery-public-data.samples.natality`
        query = f"""
        SELECT *
        FROM `{table_name}`
        """

        # Run query and convert to DataFrame
        df = client.query(query).to_dataframe()

        return df

    except Exception as e:
        print(f"Error fetching BigQuery data: {e}", file=sys.stderr)
        return None

def load_into_gcs_bucket(df: pd.DataFrame, destination_blob_name: str):
    try:
        creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        bucket_name = os.getenv("GCS_BUCKET_NAME")

        if not creds_path:
            raise ValueError("GOOGLE_APPLICATION_CREDENTIALS not set in .env")
        if not bucket_name:
            raise ValueError("GCS_BUCKET_NAME not set in .env")

        # Initialize GCS client
        storage_client = storage.Client()

        # Get the bucket
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(destination_blob_name)

        parquet_buffer = BytesIO()
        df.to_parquet(parquet_buffer, index=False)
        parquet_buffer.seek(0)

        blob.upload_from_file(parquet_buffer, content_type="application/octet-stream")
        print(f"DataFrame uploaded to gs://{bucket_name}/{destination_blob_name}")

        return f"gs://{bucket_name}/{destination_blob_name}"


    except Exception as e:
        print(f"Error loading data into GCS bucket: {e}", file=sys.stderr)

def load_gcs_to_bigquery(table_name: str, GCS_URI: str):
    try:
        creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        project    = os.getenv("BQ_PROJECT")

        if not creds_path:
            raise ValueError("GOOGLE_APPLICATION_CREDENTIALS not set in .env")
        if not project:
            raise ValueError("BQ_PROJECT not set in .env")
        
        client = bigquery.Client(project=project)

        # Define table reference
        table_ref = f"{project}.raw.{table_name}"

        # Configure the load job
        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.PARQUET,
            autodetect=True
        )

        # Start the load job
        load_job = client.load_table_from_uri(
            GCS_URI,
            table_ref,
            job_config=job_config
        )

        print(f"Starting job {load_job.job_id}...")
        load_job.result()  # Wait for job to complete

        # Confirm results
        destination_table = client.get_table(table_ref)
        print(f"Loaded {destination_table.num_rows} rows into {table_ref}.")

    except GoogleAPIError as e:
        print(f"Google API error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    table_names = [
        "bigquery-public-data.thelook_ecommerce.orders",
        "bigquery-public-data.thelook_ecommerce.users",
        "bigquery-public-data.thelook_ecommerce.products",
        "bigquery-public-data.thelook_ecommerce.order_items"
    ]

    for table in table_names:
        data = fetch_bigquery_data(table)
        if data is not None:
            print(f"{table} data was successfully fetched. Number of rows: {len(data)}")
            destination_blob_name = f"{table.split('.')[-1]}.parquet"
            gcs_uri = load_into_gcs_bucket(data, destination_blob_name)
            if gcs_uri:
                load_gcs_to_bigquery(table.split('.')[-1], gcs_uri)
        
            
