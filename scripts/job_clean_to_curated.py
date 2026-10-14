"""
Glue Job de prueba: CLEAN -> CURATED
------------------------------------
Lee data limpia desde el bucket CLEAN, aplica un curado simple (filtra
registros con email válido y genera una columna derivada) y escribe el
resultado listo para consumo en formato Parquet en el bucket CURATED.

Es un ejemplo mínimo de prueba con datos sencillos.
"""
import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F

args = getResolvedOptions(sys.argv, ["JOB_NAME", "SOURCE_BUCKET", "TARGET_BUCKET"])

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

source_path = "s3://{}/clean/".format(args["SOURCE_BUCKET"])
target_path = "s3://{}/curated/".format(args["TARGET_BUCKET"])

# --- Datos de prueba simples (en un caso real se leería de source_path) ---
sample_data = [
    (1, "ana", "ana@test.com", 30),
    (2, "beto", None, 40),
    (3, "carla", "carla@test.com", 25),
]
columns = ["id", "nombre", "email", "edad"]
df = spark.createDataFrame(sample_data, columns)

# --- Curado simple ---
curated_df = (
    df.filter(F.col("email").isNotNull())                       # solo con email
      .withColumn("mayor_de_edad", F.col("edad") >= F.lit(18))  # columna derivada
      .withColumn("procesado_en", F.current_timestamp())
)

curated_df.show()

# Escribe la data lista para consumo en formato Parquet
curated_df.write.mode("overwrite").parquet(target_path)

print("CLEAN->CURATED completado. Origen: {} Destino: {}".format(source_path, target_path))

job.commit()
