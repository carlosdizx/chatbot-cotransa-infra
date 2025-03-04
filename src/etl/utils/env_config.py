import os
from dotenv import load_dotenv


def load_config() -> dict:
    load_dotenv()

    return {
        "PDF_LIST_FILE": os.getenv("PDF_LIST_FILE", "../data/URLsS3.txt"),
        "S3_BUCKET_NAME": os.getenv("S3_BUCKET_NAME"),
        "OPEN_AI_API_KEY": os.getenv("OPEN_AI_API_KEY"),
    }
