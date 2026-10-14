"""
Glue Job de prueba: RAW -> CLEAN
--------------------------------
Lee data cruda (sucia) desde el bucket RAW, aplica una limpieza simple
(elimina filas totalmente vacías, normaliza nombres de columnas y quita
duplicados) y escribe el resultado en formato Parquet en el bucket CLEAN.

Es un ejemplo mínimo de prueba con datos sencillos.
"""
import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F

# Argumentos pasados desde Terraform (default_arguments)
args = getResolvedOptions(sys.argv, ["JOB_NAME", "SOURCE_BUCKET", "TARGET_BUCKET"])

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

source_path = "s3://{}/".format(args["SOURCE_BUCKET"])
target_path = "s3://{}/clean/".format(args["TARGET_BUCKET"])

# --- Datos de prueba simples (en un caso real se leería de source_path) ---
# Simulamos data "sucia": nombres con espacios, nulos y duplicados.
sample_data = [
    (1, "  ana  ", "ana@test.com", 30),
    (2, "beto", None, None),
    (3, "carla", "carla@test.com", 25),
    (3, "carla", "carla@test.com", 25),  # duplicado
    (None, None, None, None),            # fila vacía
]
columns = ["id", "nombre", "email", "edad"]
df = spark.createDataFrame(sample_data, columns)

# --- Limpieza simple ---
clean_df = (
    df.dropna(how="all")                       # quita filas totalmente vacías
      .dropDuplicates()                        # quita duplicados
      .withColumn("nombre", F.trim(F.col("nombre")))  # normaliza espacios
)

clean_df.show()

# Escribe en formato Parquet en el bucket CLEAN
clean_df.write.mode("overwrite").parquet(target_path)

print("RAW->CLEAN completado. Origen: {} Destino: {}".format(source_path, target_path))

job.commit()
