import streamlit as st
from python.constants import (
    STATE_OPTIONS, DB_TO_DISPLAY, DISPLAY_TO_DB,
    optativas_i_options, optativas_ii_options, YEAR_COLOR_NAMES
)
from python.parser import parse_asignaturas
from python.prolog_solver import init_prolog, ejecutar_consulta_plan, format_solucion

# --- CONFIGURACIÓN DE PÁGINA ---
st.set_page_config(
    page_title="Planificador Académico Óptimo",
    page_icon="🎓",
    layout="wide"
)

# --- INICIALIZACIÓN DE PROLOG Y DATOS ---
if "prolog_init" not in st.session_state:
    st.session_state.prolog = init_prolog()
    st.session_state.prolog_init = True

prolog = st.session_state.prolog

if "asignaturas_lista" not in st.session_state:
    st.session_state.asignaturas_lista = parse_asignaturas()

if "asignaturas_estados" not in st.session_state:
    st.session_state.asignaturas_estados = {}
    default_states = {
        "IF001": "cursada",
        "IF002": "cursada",
        "FA007": "aprobada"
    }
    for subj in st.session_state.asignaturas_lista:
        code = subj["code"]
        state = default_states.get(code, "sin_iniciar")
        st.session_state.asignaturas_estados[code] = state
        
        widget_key = f"widget_seg_{code}"
        st.session_state[widget_key] = DB_TO_DISPLAY.get(state, "Sin Iniciar")

# --- RENDERIZADO DE INTERFAZ ---
st.title("Planificador Académico Óptimo 🎓")

st.subheader("Ingrese los datos del alumno")

# Campos de entrada interactivos (fuera de formulario para que filtren la UI en tiempo real)
capacidad = st.number_input("Capacidad de carga del alumno:", min_value=1, value=25, step=1)

col1, col2 = st.columns(2)
with col1:
    anio = st.number_input("Próximo Año de Período:", min_value=2020, max_value=2030, value=2023, step=1)
with col2:
    cuatrimestre = st.selectbox("Próximo Cuatrimestre:", [1, 2])
    
col3, col4 = st.columns(2)
with col3:
    optativa_1 = st.selectbox(
        "Optativa elegida I:",
        options=list(optativas_i_options.keys()),
        format_func=lambda x: optativas_i_options[x],
        index=1 # Default es IF024
    )
with col4:
    optativa_2 = st.selectbox(
        "Optativa elegida II:",
        options=list(optativas_ii_options.keys()),
        format_func=lambda x: optativas_ii_options[x],
        index=3 # Default es IF028
    )

boton_generar = st.button("Generar Planificación Óptima", type="primary")

# --- PROCESAMIENTO AL PRESIONAR EL BOTÓN ---
if boton_generar:
    with st.spinner("Actualizando base de conocimiento y buscando solución..."):
        st.session_state.resultado_plan = ejecutar_consulta_plan(
            prolog=prolog,
            capacidad=capacidad,
            anio=anio,
            cuatrimestre=cuatrimestre,
            optativa_1=optativa_1,
            optativa_2=optativa_2,
            asignaturas_estados=st.session_state.asignaturas_estados
        )

# --- SUGERENCIA DEL PLAN SUGERIDO (PERSISTENTE) ---
if "resultado_plan" in st.session_state:
    res = st.session_state.resultado_plan
    st.write("---")
    if res["tipo"] == "success":
        st.success(res["mensaje"])
        st.write("### Plan sugerido:")
        formatted_html = format_solucion(res["plan"], st.session_state.asignaturas_lista)
        st.markdown(formatted_html, unsafe_allow_html=True)
    elif res["tipo"] == "warning":
        st.warning(res["mensaje"])
    elif res["tipo"] == "error":
        st.error(res["mensaje"])

# --- VISTA AVANZADA EN FORMATO TEXTO ---
with st.expander("Ver estado de asignaturas en formato Prolog (Depuración)"):
    activas = []
    for cod, est in st.session_state.asignaturas_estados.items():
        if est != "sin_iniciar":
            if cod in optativas_i_options and cod != optativa_1:
                continue
            if cod in optativas_ii_options and cod != optativa_2:
                continue
            activas.append(f"estado_asignatura('{cod}',{est})")
    st.code("[" + ",\n ".join(activas) + "]")

# --- SECCIÓN DE TARJETAS POR AÑO ---
st.write("---")
st.write("## 📚 Estado de las Asignaturas")

# Iterar sobre cada año mostrándolos secuencialmente en la página
for y in range(1, 6):
    st.write(f"### {y}° Año")
    
    # Filtrar asignaturas de este año
    subjs_year_raw = [s for s in st.session_state.asignaturas_lista if s["year"] == y]
    
    # Filtrar optativas no elegidas si es el 5° año
    subjs_year = []
    for s in subjs_year_raw:
        code = s["code"]
        if code in optativas_i_options and code != optativa_1:
            continue
        if code in optativas_ii_options and code != optativa_2:
            continue
        subjs_year.append(s)
        
    # Grid de 3 columnas para las tarjetas
    cols = st.columns(3)
    for idx, subj in enumerate(subjs_year):
        col = cols[idx % 3]
        with col:
            code = subj["code"]
            tipo = subj["type"]
            name = subj["name"]
            cuat = subj["cuatrimestre"]
            
            # Determinar color
            color = "gray" if tipo == "tesina" else YEAR_COLOR_NAMES.get(y, "blue")
            
            # Formatear periodo y tipo
            periodo_display = f"{y}° Año" if cuat == "_" else f"{y}° Año - {cuat}° Cuat."
            tipo_display = "Tesina" if tipo == "tesina" else tipo.capitalize()
            
            # Tarjeta nativa usando st.container(border=True)
            with st.container(border=True):
                # Código en cursiva arriba del título
                st.markdown(f"*{code}*")
                
                # Título con el color distintivo del año
                st.markdown(f"### :{color}[{name}]")
                
                # Metadata
                st.write(f"**Tipo:** {tipo_display}")
                st.write(f"**Periodo:** {periodo_display}")
                
                # Selector de estado
                options = STATE_OPTIONS.get(tipo, ["Sin Iniciar", "Aprobada"])
                new_display = st.segmented_control(
                    label=f"Estado de {name}",
                    options=options,
                    key=f"widget_seg_{code}",
                    label_visibility="collapsed"
                )
                
                # Sincronizar estado
                disp_val = new_display if new_display is not None else "Sin Iniciar"
                st.session_state.asignaturas_estados[code] = DISPLAY_TO_DB.get(disp_val, "sin_iniciar")