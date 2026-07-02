# Planner.pl

Planner.pl es una herramienta web interactiva diseñada para ayudar a los alumnos de la carrera de Licenciatura en Informática (Plan 2010) a organizar y planificar su trayectoria cuatrimestre a cuatrimestre. 

El núcleo del sistema de planificación utiliza **Prolog** para modelar el plan de estudios, las correlatividades y el estado académico del alumno. Mediante un algoritmo de búsqueda con heurística, el sistema calcula una propuesta de avance cuatrimestral respetando la capacidad de carga (esfuerzo) máxima del alumno.

## Requisitos Previos

Para poder ejecutar la aplicación de forma local, es necesario contar con los siguientes componentes en el sistema:

1. **Python 3.10 o superior**: Entorno de ejecución principal de la aplicación.
2. **SWI-Prolog**: Motor lógico de Prolog requerido por la biblioteca `pyswip` para resolver el modelo académico.

### Instalación de SWI-Prolog

* **Debian o cualquier distribución basada en debian (ej. Ubuntu o Linux Mint)**:
  ```bash
  sudo apt-get update
  sudo apt-get install swi-prolog
  ```
* **macOS** (utilizando Homebrew):
  ```bash
  brew install swi-prolog
  ```
* **Windows**:
  Descargar e instalar el ejecutable desde la [página oficial de SWI-Prolog](https://www.swi-prolog.org/download/stable) y asegurarse de agregar el binario al PATH del sistema durante el proceso de instalación.

---

## Guía de Instalación y Ejecución Local

Sigue estos pasos para configurar el entorno y poner en marcha la aplicación:

### 1. Clonar el repositorio
Si aún no tienes el código localmente, clona el repositorio o extrae el archivo comprimido:
```bash
git clone <url-del-repositorio>
cd ia-tp-final
```

### 2. Crear un entorno virtual de Python
Se recomienda crear un entorno virtual para aislar las dependencias del proyecto:
```bash
python3 -m venv .venv
```

### 3. Activar el entorno virtual
* En **Linux / macOS**:
  ```bash
  source .venv/bin/activate
  ```
* En **Windows** (PowerShell):
  ```powershell
  .venv\Scripts\Activate.ps1
  ```
* En **Windows** (CMD):
  ```cmd
  .venv\Scripts\activate.bat
  ```

### 4. Instalar las dependencias de Python
Con el entorno virtual activo, instala las bibliotecas requeridas desde el archivo `requirements.txt`:
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 5. Iniciar la aplicación
Ejecuta el servidor de desarrollo de Streamlit:
```bash
streamlit run app.py
```

Una vez iniciado, la consola indicará la dirección local de acceso (típicamente `http://localhost:8501`). Abre esta URL en cualquier navegador web.

---

## Estructura del Proyecto

* `app.py`: Archivo principal que configura la navegación y el entorno global de Streamlit.
* `pages/`: Vistas de la aplicación.
  * `inicio.py`: Pantalla de bienvenida, guía de uso y copia de seguridad (importación/exportación en JSON).
  * `mis_datos.py`: Formulario de configuración de parámetros del alumno y estados de materias.
  * `sugerencia_planificacion.py`: Panel de generación y visualización de la propuesta sugerida.
* `prolog/`: Archivos lógicos.
  * `planner-core.pl`: Reglas de inferencia, heurística y cálculo del plan.
  * `lic-informatica-2010.pl`: Base de conocimiento con la definición del plan de estudios y sus correlativas.
* `utils/`: Módulos auxiliares de Python.
  * `prolog_service.py`: Puente de comunicación entre Streamlit y SWI-Prolog.
  * `constants.py`: Listados de materias, colores y catálogos estáticos de la interfaz.
* `static/`: Recursos visuales (logotipo y favicon).