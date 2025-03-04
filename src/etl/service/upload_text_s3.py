import requests
import boto3
from PyPDF2 import PdfReader
import os

from src.etl.utils.env_config import load_config

config = load_config()

PDF_LIST_FILE = config.get("PDF_LIST_FILE")
S3_BUCKET_NAME = config.get("S3_BUCKET_NAME")

s3_client = boto3.client("s3")


def read_pdf_from_url(url):
    response = requests.get(url)
    response.raise_for_status()

    with open("temp.pdf", "wb") as f:
        f.write(response.content)

    pdf_reader = PdfReader("temp.pdf")
    text = "\n".join([page.extract_text() for page in pdf_reader.pages if page.extract_text()])

    return text.strip() if text else "No se pudo extraer el texto."


def upload_to_s3(file_name, content):
    """Sube el texto extraído a un bucket de S3."""
    s3_key = f"extracted_texts/{file_name}.txt"  # Carpeta en S3
    s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=s3_key, Body=content.encode("utf-8"))
    print(f"✅ Archivo {file_name}.txt subido a S3 en {s3_key}")


def process_documents():
    """Lee el archivo con URLs de PDFs, extrae el contenido y lo almacena en S3."""
    if not os.path.exists(PDF_LIST_FILE):
        print(f"❌ El archivo {PDF_LIST_FILE} no existe.")
        return

    with open(PDF_LIST_FILE, "r") as f:
        urls = [line.strip() for line in f.readlines() if line.strip()]

    for url in urls:
        file_name = url.split("/")[-1].replace(".pdf", "")  # Nombre sin extensión
        print(f"🔄 Procesando: {file_name}")

        content = read_pdf_from_url(url)

        if content:
            upload_to_s3(file_name, content)  # Guardar en S3


if __name__ == "__main__":
    process_documents()
