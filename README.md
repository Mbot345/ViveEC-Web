# ViveEC

Sistema de streaming musical desarrollado con Django y SQL Server.

## Requisitos

* Python 3.12 o superior
* SQL Server
* SQL Server Management Studio (SSMS)

## Instalación

### 1. Descargar el proyecto

Clonar o descargar este repositorio.

### 2. Crear y activar entorno virtual

Windows:

```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 4. Crear la base de datos

Ejecutar el script SQL ubicado en:

```text
database/Script Creacion base de datos ViceEC.sql
```

### 5. Configurar la conexión a SQL Server

Editar el archivo:

```text
config/settings.py
```

y colocar las credenciales correspondientes del servidor SQL.

### 6. Ejecutar el proyecto

```bash
python manage.py runserver
```

### 7. Abrir en el navegador

```text
http://127.0.0.1:8000
```
