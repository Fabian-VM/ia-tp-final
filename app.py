import streamlit as st
from pyswip import Prolog

# Inicializar Prolog y cargar la lógica base
# Usamos session_state para no recargar el archivo .pl en cada clic redundante
if "prolog_init" not in st.session_state:
    st.session_state.prolog = Prolog()
    st.session_state.prolog.consult("prolog/prolog-program.pl")
    st.session_state.prolog_init = True

prolog = st.session_state.prolog

st.title("Planificador Académico Óptimo 🎓")

# --- FORMULARIO DE ENTRADA DE DATOS ---
with st.form("datos_alumno_form"):
    st.subheader("Ingrese los datos del alumno")
    
    capacidad = st.number_input("Capacidad de carga del alumno:", min_value=1, value=25, step=1)
    
    col1, col2 = st.columns(2)
    with col1:
        anio = st.number_input("Próximo Año de Período:", min_value=2020, max_value=2030, value=2023, step=1)
    with col2:
        cuatrimestre = st.selectbox("Próximo Cuatrimestre:", [1, 2])
        
    # Input de asignaturas simulando el formato
    st.markdown("**Estados de asignaturas** (Formato: `CODIGO:estado`, uno por línea. Ej: `IF001:cursada`)")
    asignaturas_text = st.text_area(
        "Asignaturas:",
        value="IF001:cursada\nIF002:cursada\nFA007:aprobada",
        help="Escribe el código de la materia, dos puntos y el estado (cursada/aprobada). Una materia por línea."
    )
    
    optativa_1 = st.text_input("Optativa elegida I:", value="IF024").strip()
    optativa_2 = st.text_input("Optativa elegida II:", value="IF028").strip()
    
    # Botón de envío del formulario
    boton_generar = st.form_submit_button("Generar Planificación Óptima")

# --- PROCESAMIENTO AL PRESIONAR EL BOTÓN ---
if boton_generar:
    # 1. Validación de campos vacíos
    if not asignaturas_text.strip() or not optativa_1 or not optativa_2:
        st.error("Por favor, complete todos los campos obligatorios antes de continuar.")
    else:
        # 2. Parsear el texto de las asignaturas a formato Prolog
        # De "IF001:cursada" pasamos a "estado_asignatura('IF001',cursada)"
        lista_estados_prolog = []
        lineas = [linea.strip() for linea in asignaturas_text.split("\n") if linea.strip()]
        
        error_formato = False
        for linea in lineas:
            if ":" in linea:
                cod, est = linea.split(":", 1)
                lista_estados_prolog.append(f"estado_asignatura('{cod.strip()}',{est.strip()})")
            else:
                error_formato = True
                
        if error_formato:
            st.error("Error en el formato de las asignaturas. Use 'CODIGO:estado' (Ej: IF001:cursada)")
        else:
            # Construimos el string de la lista para Prolog: "[estado_asignatura(...), ...]"
            string_lista_asignaturas = "[" + ",".join(lista_estados_prolog) + "]"
            
            with st.spinner("Actualizando base de conocimiento y buscando solución..."):
                try:
                    # 3. LIMPIEZA DE HECHOS ANTERIORES (¡Ahora de forma correcta!)
                    # Ejecutamos retractall directamente como una consulta para que borre, no con assertz
                    list(prolog.query("retractall(capacidad_carga_alumno(_))"))
                    list(prolog.query("retractall(proximo_periodo_plan_alumno(_, _))"))
                    list(prolog.query("retractall(estados_asignaturas_alumno(_))"))
                    list(prolog.query("retractall(optativa_elegida_i(_))"))
                    list(prolog.query("retractall(optativa_elegida_ii(_))"))

                    # 4. INSERCIÓN DE NUEVOS HECHOS (Esto sí va con assertz)
                    prolog.assertz(f"capacidad_carga_alumno({capacidad})")
                    prolog.assertz(f"proximo_periodo_plan_alumno({anio}, {cuatrimestre})")
                    prolog.assertz(f"estados_asignaturas_alumno({string_lista_asignaturas})")
                    prolog.assertz(f"optativa_elegida_i('{optativa_1}')")
                    prolog.assertz(f"optativa_elegida_ii('{optativa_2}')")
                    
                    # 5. EJECUCIÓN DE LA CONSULTA OPTIMIZADA
                    query_id = prolog.query("iterative_deepening(Solucion)")
                    iterador = iter(query_id)
                    primera_respuesta = next(iterador, None)
                    
                    if primera_respuesta:
                        solucion_optima = primera_respuesta["Solucion"]
                        st.success("¡Solución óptima encontrada exitosamente!")
                        st.write("### Plan sugerido:")
                        st.write(solucion_optima)
                    else:
                        st.warning("No se encontró ninguna solución válida para los datos ingresados.")
                        
                    query_id.close()
                    
                except Exception as e:
                    st.error(f"Ocurrió un error interactuando con SWI-Prolog: {e}")