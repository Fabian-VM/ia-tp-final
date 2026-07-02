import streamlit as st
from utils.constants import DB_TO_DISPLAY
from utils.prolog_service import PrologService

# --- CONFIGURACIÓN DE PÁGINA ---
st.logo("./static/favicon.png")

st.set_page_config(
    page_title="Planner.pl",
    page_icon="./static/favicon.png",
    layout="wide"
)

# --- INICIALIZACIÓN DE PROLOG Y DATOS GLOBALES ---
if "prolog_init" not in st.session_state:
    st.session_state.prolog = PrologService.init_prolog()
    st.session_state.prolog_init = True

if "asignaturas_lista" not in st.session_state:
    st.session_state.asignaturas_lista = PrologService.obtener_asignaturas(st.session_state.prolog)

if "asignaturas_estados" not in st.session_state:
    st.session_state.asignaturas_estados = {}
    default_states = {}
    for subj in st.session_state.asignaturas_lista:
        code = subj["code"]
        state = default_states.get(code, "sin_iniciar")
        st.session_state.asignaturas_estados[code] = state
        
        widget_key = f"widget_seg_{code}"
        st.session_state[widget_key] = DB_TO_DISPLAY.get(state, "Sin Iniciar")

# Inicialización de datos del alumno por defecto
if "capacidad" not in st.session_state:
    st.session_state.capacidad = 26

if "anio" not in st.session_state:
    st.session_state.anio = 2026

if "cuatrimestre" not in st.session_state:
    st.session_state.cuatrimestre = 1

if "optativa_1" not in st.session_state:
    st.session_state.optativa_1 = "IF024"

if "optativa_2" not in st.session_state:
    st.session_state.optativa_2 = "IF028"

# --- NAVEGACIÓN ---
inicio = st.Page(
    "pages/inicio.py",
    title="Inicio",
    icon="🏠"
)

mis_datos = st.Page(
    "pages/mis_datos.py",
    title="Mis Datos",
    icon="👤"
)
sugerencia = st.Page(
    "pages/sugerencia_planificacion.py",
    title="Planificación",
    icon="📊"
)

# --- INFORMACIÓN EN SIDEBAR ---
st.sidebar.info(
    "Este proyecto utiliza **Prolog** para ejecutar un algoritmo de búsqueda "
    "con heurística, que calcula una planificación para completar la carrera.\n\n"
    "Nota: el algoritmo simplifica y modela el problema omitiendo "
    "ciertos detalles que se tendrían en cuenta en una cursada real, como el calendario académico.*"
)

pg = st.navigation([inicio, mis_datos, sugerencia])
pg.run()