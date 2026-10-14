# CI/CD — Data Lake Terraform (DMS → S3 → Glue)

Guía para subir este proyecto a GitHub y ejecutar el pipeline de Terraform
con GitHub Actions.

---

## 1. Qué hace el pipeline

Archivo: `.github/workflows/terraform.yml`

| Job     | Cuándo corre                                  | Qué hace                                 |
|---------|-----------------------------------------------|------------------------------------------|
| `plan`  | En cada `push` y `pull_request` a `main`      | `fmt` → `init` → `validate` → `plan`     |
| `apply` | En `push` a `main` o ejecución manual         | `init` → `apply -auto-approve`           |

El job `apply` depende de `plan` (`needs: plan`) y usa el `environment: production`,
que permite exigir **aprobación manual** antes de aplicar cambios reales.

---

## 2. Requisitos previos (una sola vez)

### 2.1 Crear el repositorio en GitHub
Crea un repo vacío en GitHub (por ejemplo `dms-datalake`). No agregues README
ni .gitignore desde la UI para evitar conflictos (ya los tienes en local).

### 2.2 Configurar los secretos del repo
En GitHub: **Settings → Secrets and variables → Actions → New repository secret**

| Secret                   | Valor                                      |
|--------------------------|--------------------------------------------|
| `AWS_ACCESS_KEY_ID`      | Access key del usuario IAM (cuenta 998361628237) |
| `AWS_SECRET_ACCESS_KEY`  | Secret key correspondiente                 |

> El backend `backend.tf` usa `profile = "datalake"` para tu máquina local.
> En CI no existe ese profile, por eso el workflow hace
> `terraform init -backend-config="profile="` para vaciarlo y usar las
> credenciales que inyecta `aws-actions/configure-aws-credentials`.

### 2.3 (Opcional) Proteger el apply con aprobación
En GitHub: **Settings → Environments → New environment → `production`**
y agrega "Required reviewers". Así el job `apply` esperará tu aprobación.

---

## 3. Subir el código por primera vez

Desde la raíz del proyecto (`c:\IteraProcess\DMS-DATALAKE`):

```powershell
# 1. Inicializar git
git init
git branch -M main

# 2. Agregar el remoto (reemplaza <usuario> y <repo>)
git remote add origin https://github.com/<usuario>/<repo>.git

# 3. Agregar archivos (el .gitignore ya excluye state y secretos)
git add .

# 4. Primer commit
git commit -m "Infra inicial: data lake DMS -> S3 -> Glue con Terraform"

# 5. Subir
git push -u origin main
```

Al hacer `push` a `main`, GitHub Actions dispara el workflow automáticamente.

---

## 4. Flujo de trabajo recomendado (día a día)

Trabaja con ramas y Pull Requests para que el `plan` se revise antes del `apply`:

```powershell
# Crear una rama para tu cambio
git checkout -b feature/mi-cambio

# ... editar archivos .tf ...

git add .
git commit -m "Describe tu cambio"
git push -u origin feature/mi-cambio
```

Luego abre un Pull Request hacia `main` en GitHub:
1. El job `plan` corre y puedes revisar el plan en la pestaña **Actions**.
2. Si todo está bien, haces merge del PR a `main`.
3. El merge dispara el job `apply` (con aprobación si configuraste el environment).

---

## 5. Archivos clave

| Archivo                              | Rol                                           |
|--------------------------------------|-----------------------------------------------|
| `.github/workflows/terraform.yml`    | Definición del pipeline                        |
| `.gitignore`                         | Evita subir state, planes y credenciales       |
| `backend.tf`                         | Backend S3 + DynamoDB para el tfstate          |
| `terraform.tfvars`                   | Valores (config NO sensible)                   |

---

## 6. Nota sobre `.terraform.lock.hcl`

La práctica recomendada por HashiCorp es **versionar** `.terraform.lock.hcl`
para fijar las versiones de providers en todo el equipo y en CI.

En este `.gitignore` está **ignorado** por el problema de "Access is denied"
que tuviste en Windows. Si quieres seguir la práctica recomendada:

1. Edita `.gitignore` y elimina (o comenta) la línea `.terraform.lock.hcl`.
2. Ejecuta:
   ```powershell
   git add .terraform.lock.hcl
   git commit -m "Fijar versiones de providers (lock file)"
   ```

Si lo versionas, el workflow usará exactamente las mismas versiones de
providers que en tu máquina.

---

## 7. Seguridad — qué NO se sube

El `.gitignore` ya excluye:
- `*.tfstate*` (el estado puede contener datos sensibles como passwords del DMS)
- `*.tfplan`, `tfplan.out` (planes guardados)
- `.terraform/` (plugins y cache)
- `.env`, `*.pem`, `*.key`, `.aws/` (credenciales)

> Importante: el password del endpoint source de DMS está hoy en el código
> como valor por defecto simulado. Para producción, muévelo a un secreto
> (GitHub Secret + variable Terraform, o AWS Secrets Manager) y nunca lo
> dejes en texto plano en el repo.
