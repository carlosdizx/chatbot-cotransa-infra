import openai
import numpy as np
import pandas as pd
import boto3

from src.etl.utils.env_config import load_config

# Cargar configuración
config = load_config()
OPENAI_API_KEY = config["OPEN_AI_API_KEY"]
S3_BUCKET_NAME = config["S3_BUCKET_NAME"]
EMBEDDINGS_FILE = "normative_embeddings_cache.csv"  # Nombre del archivo en local
S3_EMBEDDINGS_KEY = "normative_embeddings_cache.csv"  # Archivo en la raíz del bucket S3

# Inicializar clientes de AWS
s3_client = boto3.client("s3")
client = openai.OpenAI(api_key=OPENAI_API_KEY)


def list_s3_files(prefix="extracted_texts/"):
    """Lista los archivos en la carpeta `extracted_texts/` dentro del bucket S3."""
    response = s3_client.list_objects_v2(Bucket=S3_BUCKET_NAME, Prefix=prefix)
    return [obj["Key"] for obj in response.get("Contents", []) if obj["Key"].endswith(".txt")]


def read_s3_file(s3_key):
    """Lee el contenido de un archivo almacenado en S3."""
    response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=s3_key)
    return response["Body"].read().decode("utf-8")


def upload_file_to_s3(local_path, s3_key):
    """Sube un archivo local a la raíz del bucket en S3."""
    s3_client.upload_file(local_path, S3_BUCKET_NAME, s3_key)
    print(f"✅ Archivo {s3_key} subido a S3 en la raíz del bucket.")


def get_embedding(text: str, model="text-embedding-ada-002") -> list:
    """Obtiene el embedding de un texto usando OpenAI Embeddings."""
    response = client.embeddings.create(input=text, model=model)
    return response.data[0].embedding


def dividir_texto(texto, max_words=100):
    """Divide el texto en fragmentos más pequeños para embeddings."""
    palabras = texto.split()
    return [" ".join(palabras[i:i + max_words]) for i in range(0, len(palabras), max_words)]


def embed_texts_from_s3():
    """Carga documentos desde S3, los divide en fragmentos y obtiene embeddings."""
    files = list_s3_files()
    fragmentos = []

    for file in files:
        print(f"📄 Procesando: {file}")
        texto = read_s3_file(file)  # Leer el contenido del archivo desde S3
        fragmentos.extend(dividir_texto(texto, max_words=100))

    # Generar embeddings para cada fragmento
    df = pd.DataFrame(fragmentos, columns=["text"])
    df["embedding"] = df["text"].apply(lambda x: get_embedding(x))

    # Convertir embeddings a string antes de guardarlos
    df["embedding"] = df["embedding"].apply(lambda x: ",".join(map(str, x)))
    df.to_csv(EMBEDDINGS_FILE, index=False)  # Guardar en CSV

    # Subir el archivo CSV a la raíz del bucket en S3
    upload_file_to_s3(EMBEDDINGS_FILE, S3_EMBEDDINGS_KEY)

    return df


def load_embeddings():
    """Carga los embeddings desde S3 si existen, o los genera."""
    try:
        # Intentar descargar el archivo de embeddings desde S3
        s3_client.download_file(S3_BUCKET_NAME, S3_EMBEDDINGS_KEY, EMBEDDINGS_FILE)
        print("📥 Archivo de embeddings descargado desde S3.")
    except Exception as e:
        print("⚠️ No se encontró el archivo en S3. Generando nuevos embeddings...")
        return embed_texts_from_s3()  # Si no hay embeddings, generarlos desde S3

    # Cargar los embeddings desde el archivo descargado
    df = pd.read_csv(EMBEDDINGS_FILE)
    df["embedding"] = df["embedding"].apply(lambda x: np.array([float(i) for i in x.split(",")]))
    return df


def cosine_similarity(vec1, vec2):
    """Calcula la similitud de coseno entre dos vectores."""
    return np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2))


def find_relevant_regulation(query: str, n_resultados=3):
    """Busca los fragmentos más relevantes basados en embeddings."""
    df = load_embeddings()  # Cargar los embeddings de S3 o generarlos
    query_embedding = get_embedding(query)

    df["similaridad"] = df["embedding"].apply(lambda x: cosine_similarity(x, query_embedding))
    df = df.sort_values(by="similaridad", ascending=False)

    fragmentos_relevantes = df.iloc[:n_resultados]["text"].tolist()  # Obtener los más relevantes
    return " ".join(fragmentos_relevantes)


if __name__ == "__main__":
    print("📌 Iniciando procesamiento de normativas desde S3...")
    embed_texts_from_s3()
    print("✅ Embeddings generados y almacenados en S3.")
