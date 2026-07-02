import streamlit as st
from utils.constants import (
    optativas_i_options, optativas_ii_options, YEAR_COLOR_NAMES, DB_TO_DISPLAY, STATE_OPTIONS
)
from utils.prolog_service import PrologService

prolog = st.session_state.prolog

st.title("Planificación de asignaturas")

# Obtener datos guardados de session_state
capacidad = st.session_state.capacidad
anio = st.session_state.anio
cuatrimestre = st.session_state.cuatrimestre
optativa_1 = st.session_state.optativa_1
optativa_2 = st.session_state.optativa_2

# Mostrar resumen de datos del alumno actuales
st.info(
    f"**Tus parámetros actuales:**\n"
    f"- Capacidad de carga: {capacidad} puntos\n"
    f"- Próximo período a iniciar: {anio} - {cuatrimestre}° Cuatrimestre\n"
    f"- Optativa I elegida: {optativas_i_options.get(optativa_1, optativa_1)}\n"
    f"- Optativa II elegida: {optativas_ii_options.get(optativa_2, optativa_2)}\n"
    f"\n*Puedes modificar estos parámetros en la página de \"Mis datos\"*"
)

boton_generar = st.button("Generar Planificación", type="primary")

# --- PROCESAMIENTO AL PRESIONAR EL BOTÓN ---
if boton_generar:
    with st.spinner("Actualizando base de conocimiento y buscando solución..."):
        st.session_state.resultado_plan = PrologService.ejecutar_consulta_plan(
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
    st.subheader("Planificación sugerida")
    if res["tipo"] == "success":        
        # Parsea el plan de Prolog
        plan_procesado = PrologService.procesar_plan(res["plan"], st.session_state.asignaturas_lista)
        
        for periodo in plan_procesado:
            anio_cal = periodo["anio_cal"]
            cuat_cal = periodo["cuat_cal"]
            cuat_display = f"{cuat_cal}° Cuatrimestre" if cuat_cal != "_" else "Periodo Completo"
            st.write(f"#### {anio_cal} - {cuat_display}")
            
            # Ordenar materias por estado (de más último/avanzado a primero/inicial)
            state_priority = {
                "aprobada": 1,
                "proyecto_presentado": 2,
                "cursada": 3,
                "sin_iniciar": 4
            }
            materias_ordenadas = sorted(
                periodo["materias"],
                key=lambda s: state_priority.get(s["state"], 99)
            )
            
            for subj in materias_ordenadas:
                code = subj["code"]
                tipo = subj["type"]
                name = subj["name"]
                cuat = subj["cuatrimestre"]
                state = subj["state"]
                y = subj["year"]
                
                color = "gray" if tipo == "tesina" else YEAR_COLOR_NAMES.get(y, "blue")
                periodo_display = f"{y}° Año" if cuat == "_" else f"{y}° Año - {cuat}° Cuat."
                tipo_display = "Tesina" if tipo == "tesina" else tipo.capitalize()
                
                state_friendly = DB_TO_DISPLAY.get(state, state)
                
                with st.container(border=True):
                    # Fila 1: Información de la asignatura
                    st.markdown(f"**{code}** &nbsp;&bull;&nbsp; :{color}[**{name}**] &nbsp;&bull;&nbsp; *{tipo_display}* &nbsp;&bull;&nbsp; *{periodo_display}*")
                    
                    # Fila 2: Selector de estado deshabilitado
                    options = STATE_OPTIONS.get(tipo, ["Sin Iniciar", "Aprobada"])
                    if state_friendly not in options:
                        options = [state_friendly] + [opt for opt in options if opt != state_friendly]
                    
                    st.segmented_control(
                        label=f"Estado de {name}",
                        options=options,
                        default=state_friendly,
                        key=f"plan_seg_{anio_cal}_{cuat_cal}_{code}",
                        disabled=True,
                        label_visibility="collapsed"
                    )
    elif res["tipo"] == "warning":
        st.warning(res["mensaje"])
    elif res["tipo"] == "error":
        st.error(res["mensaje"])

