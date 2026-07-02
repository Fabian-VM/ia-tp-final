import streamlit as st
import json
from utils.constants import (
    STATE_OPTIONS, DB_TO_DISPLAY, DISPLAY_TO_DB,
    optativas_i_options, optativas_ii_options, YEAR_COLOR_NAMES,
    OPTATIVAS_REQUISITOS
)
from utils.prolog_service import PrologService

@st.dialog("Estimar capacidad de carga")
def estimar_capacidad_modal():
    st.write("La capacidad de carga es un puntaje que indica cuántas asignaturas puedes cursar o aprobar en un cuatrimestre. El algoritmo lo necesita para planificar teniendo en cuenta esa situación.")
    st.write("Responde las siguientes preguntas para estimar tu capacidad de carga:")
    
    cant_cursar = st.number_input("¿Cuántas materias podrías cursar? (suma 6 puntos por cada unidad)", min_value=0, value=0, step=1)
    cant_aprobar = st.number_input("¿Cuántas materias podrías aprobar? (suma 2 puntos por cada unidad)", min_value=0, value=0, step=1)
    cant_cursos = st.number_input("¿Cuántos cursos podrías hacer? (suma 2 puntos por cada unidad)", min_value=0, value=0, step=1)
    
    capacidad_estimada = (cant_cursar * 6) + (cant_aprobar * 2) + (cant_cursos * 2)
    capacidad_final = max(10, capacidad_estimada)
    
    st.info(f"Capacidad de carga calculada: **{capacidad_estimada}** puntos")
    st.warning("El valor mínimo de capacidad es 10. Si el resultado es menor, se guardará como 10.")
    
    if st.button("Aceptar", type="primary"):
        st.session_state.temp_capacidad = capacidad_final
        st.rerun()

# --- INICIALIZACIÓN DE VALORES TEMPORALES EN SESSION STATE ---
if "temp_capacidad" not in st.session_state:
    st.session_state.temp_capacidad = st.session_state.capacidad

if "temp_anio" not in st.session_state:
    st.session_state.temp_anio = st.session_state.anio

if "temp_cuatrimestre" not in st.session_state:
    st.session_state.temp_cuatrimestre = st.session_state.cuatrimestre

if "temp_optativa_1" not in st.session_state:
    st.session_state.temp_optativa_1 = st.session_state.optativa_1

if "temp_optativa_2" not in st.session_state:
    st.session_state.temp_optativa_2 = st.session_state.optativa_2

for subj in st.session_state.asignaturas_lista:
    code = subj["code"]
    key = f"temp_seg_{code}"
    if key not in st.session_state:
        current_db_state = st.session_state.asignaturas_estados.get(code, "sin_iniciar")
        st.session_state[key] = DB_TO_DISPLAY.get(current_db_state, "Sin Iniciar")

# --- DETECCIÓN DE CAMBIOS ---
has_changes = False

if st.session_state.temp_capacidad != st.session_state.capacidad:
    has_changes = True
if st.session_state.temp_anio != st.session_state.anio:
    has_changes = True
if st.session_state.temp_cuatrimestre != st.session_state.cuatrimestre:
    has_changes = True
if st.session_state.temp_optativa_1 != st.session_state.optativa_1:
    has_changes = True
if st.session_state.temp_optativa_2 != st.session_state.optativa_2:
    has_changes = True

for subj in st.session_state.asignaturas_lista:
    code = subj["code"]
    temp_val = st.session_state.get(f"temp_seg_{code}")
    saved_db_val = st.session_state.asignaturas_estados.get(code, "sin_iniciar")
    saved_disp_val = DB_TO_DISPLAY.get(saved_db_val, "Sin Iniciar")
    if temp_val != saved_disp_val:
        has_changes = True

# --- VALIDACIÓN DE COHERENCIA EN OPTATIVAS ---
optativas_coherentes = True
error_optativas_msg = ""

req_optativa_1 = OPTATIVAS_REQUISITOS.get(st.session_state.temp_optativa_2)
if req_optativa_1 and st.session_state.temp_optativa_1 != req_optativa_1:
    optativas_coherentes = False
    optativa_1_name = optativas_i_options.get(req_optativa_1, req_optativa_1)
    optativa_2_name = optativas_ii_options.get(st.session_state.temp_optativa_2, st.session_state.temp_optativa_2)
    error_optativas_msg = f"La asignatura optativa **{optativa_2_name}** requiere que selecciones **{optativa_1_name}** como Optativa I."

st.title("Mis datos 👤")
st.write("Ingresa tus parámetros de planificación y el estado de tus asignaturas.")

# Botón de guardar arriba del todo, habilitado solo si hay cambios y son coherentes
guardar = st.button("Guardar Datos", type="primary", disabled=not has_changes or not optativas_coherentes)

# Mostrar banner de éxito persistente a un rerun
if st.session_state.get("mostrar_exito", False):
    st.success("¡Tus datos han sido guardados con éxito!")
    st.session_state.mostrar_exito = False

# Mostrar si hay cambios sin guardar
if has_changes:
    if not optativas_coherentes:
        st.error(error_optativas_msg)
    else:
        st.warning("Tienes cambios sin guardar.")
elif not optativas_coherentes:
    st.error(error_optativas_msg)


# --- ACCIÓN DE GUARDADO ---
if guardar:
    # 1. Construir estados de asignaturas temporales para validar
    temp_estados = {}
    for subj in st.session_state.asignaturas_lista:
        code = subj["code"]
        disp_val = st.session_state.get(f"temp_seg_{code}", "Sin Iniciar")
        if disp_val is None:
            disp_val = "Sin Iniciar"
        temp_estados[code] = DISPLAY_TO_DB.get(disp_val, "sin_iniciar")
        
    # 2. Validar usando la regla estado/1 de Prolog
    es_valido = PrologService.validar_estado_alumno(
        prolog=st.session_state.prolog,
        capacidad=st.session_state.temp_capacidad,
        anio=st.session_state.temp_anio,
        cuatrimestre=st.session_state.temp_cuatrimestre,
        optativa_1=st.session_state.temp_optativa_1,
        optativa_2=st.session_state.temp_optativa_2,
        asignaturas_estados=temp_estados
    )
    
    if not es_valido:
        st.error("El estado académico ingresado no es válido según correlatividades de la carrera. Revisa que el estado de tus asignaturas este conforme a tu historia académica y vuelve a intentarlo.")
    else:
        # Si es válido, procedemos a guardar
        st.session_state.capacidad = st.session_state.temp_capacidad
        st.session_state.anio = st.session_state.temp_anio
        st.session_state.cuatrimestre = st.session_state.temp_cuatrimestre
        st.session_state.optativa_1 = st.session_state.temp_optativa_1
        st.session_state.optativa_2 = st.session_state.temp_optativa_2
        
        # Sincronizar estados de asignaturas
        for code, state_db in temp_estados.items():
            st.session_state.asignaturas_estados[code] = state_db
            
        # Limpiar planificación guardada al actualizar los datos
        st.session_state.pop("resultado_plan", None)
            
        st.session_state.mostrar_exito = True
        st.rerun()

st.write("---")
st.subheader("Parámetros de planificación")

# --- CAMPOS DE ENTRADA (FUERA DE FORM PARA DETECTAR CAMBIOS EN TIEMPO REAL) ---
col_cap, col_btn = st.columns([2.5, 1])
with col_cap:
    capacidad_input = st.number_input(
        "Capacidad de carga por cuatrimestre:", 
        min_value=10, 
        key="temp_capacidad", 
        step=1
    )
with col_btn:
    st.write("")
    st.write("")
    if st.button("¿Qué es la capacidad de carga?", use_container_width=True):
        estimar_capacidad_modal()

col1, col2 = st.columns(2)
with col1:
    st.selectbox(
        "Próximo cuatrimestre a iniciar:", 
        [1, 2], 
        key="temp_cuatrimestre"
    )
with col2:
    st.number_input(
        "Año:", 
        min_value=2010, 
        max_value=2100, 
        key="temp_anio", 
        step=1
    )

col3, col4 = st.columns(2)
with col3:
    optativa_1_keys = list(optativas_i_options.keys())
    st.selectbox(
        "Optativa elegida I:",
        options=optativa_1_keys,
        format_func=lambda x: optativas_i_options[x],
        key="temp_optativa_1"
    )
with col4:
    optativa_2_keys = list(optativas_ii_options.keys())
    st.selectbox(
        "Optativa elegida II:",
        options=optativa_2_keys,
        format_func=lambda x: optativas_ii_options[x],
        key="temp_optativa_2"
    )

st.write("---")
st.write("### Estados de mis asignaturas")

# Iterar sobre cada año mostrando las materias correspondientes
for y in range(1, 6):
    st.write(f"#### {y}° Año")
    
    # Filtrar asignaturas de este año
    subjs_year_raw = [s for s in st.session_state.asignaturas_lista if s["year"] == y]
    
    # Filtrar optativas no elegidas basadas en las que están seleccionadas temporalmente
    subjs_year = []
    for s in subjs_year_raw:
        code = s["code"]
        if code in optativas_i_options and code != st.session_state.temp_optativa_1:
            continue
        if code in optativas_ii_options and code != st.session_state.temp_optativa_2:
            continue
        subjs_year.append(s)
        
    # Mostrar tarjetas
    for subj in subjs_year:
        code = subj["code"]
        tipo = subj["type"]
        name = subj["name"]
        cuat = subj["cuatrimestre"]
        
        color = "gray" if tipo == "tesina" else YEAR_COLOR_NAMES.get(y, "blue")
        periodo_display = f"{y}° Año" if cuat == "_" else f"{y}° Año - {cuat}° Cuat."
        tipo_display = "Tesina" if tipo == "tesina" else tipo.capitalize()
        
        with st.container(border=True):
            st.markdown(f"**{code}** &nbsp;&bull;&nbsp; :{color}[**{name}**] &nbsp;&bull;&nbsp; *{tipo_display}* &nbsp;&bull;&nbsp; *{periodo_display}*")
            
            options = STATE_OPTIONS.get(tipo, ["Sin Iniciar", "Aprobada"])
            
            disp_val = st.session_state.get(f"temp_seg_{code}", "Sin Iniciar")
            st.segmented_control(
                label=f"Estado de {name}",
                options=options,
                default=disp_val,
                key=f"temp_seg_{code}",
                label_visibility="collapsed"
            )
