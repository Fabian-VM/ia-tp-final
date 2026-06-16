import streamlit as st
from pyswip import Prolog
import re

# --- CONFIGURACIÓN DE PÁGINA ---
st.set_page_config(
    page_title="Planificador Académico Óptimo",
    page_icon="🎓",
    layout="wide"
)

# --- PARSER DE ASIGNATURAS ---
def parse_asignaturas():
    filepath = "prolog/lic-informatica-2010.pl"
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Regex para capturar las asignaturas
    pattern = r"asignatura\s*\(\s*'([^']+)'\s*,\s*([a-zA-Z0-9_]+)\s*,\s*([a-zA-Z0-9_]+)\s*,\s*periodo_plan\(\s*([1-5])\s*,\s*([1-2]|_)\s*\)\s*\)"
    matches = re.findall(pattern, content)
    
    asignaturas = []
    for code, tipo, name, anio, cuatrimestre in matches:
        name_friendly = name.replace("_", " ").title()
        replacements = {
            "Informatica": "Informática",
            "Matematica": "Matemática",
            "Matematico": "Matemático",
            "Analisis": "Análisis",
            "Algebra": "Álgebra",
            "Estadistica": "Estadística",
            "Diseno": "Diseño",
            "Teoricos": "Teóricos",
            "Transmision": "Transmisión",
            "Simulacion": "Simulación",
            "Programacion": "Programación",
            "Algoritmica": "Algorítmica",
            "Tecnologias": "Tecnologías",
            "Expresion": "Expresión",
            "Logica": "Lógica",
            "Acreditacion": "Acreditación",
            "Ingenieria": "Ingeniería",
            "Gestion": "Gestión",
            "Planificacion": "Planificación",
            "Monitorizacion": "Monitorización",
            "Visualizacion": "Visualización",
            "Iii": "III",
            "Ii": "II",
            "I": "I",
            "Si": "SI",
        }
        for orig, rep in replacements.items():
            name_friendly = name_friendly.replace(orig, rep)
            
        words = name_friendly.split()
        for i, word in enumerate(words):
            if word.lower() in ["de", "y", "o", "a", "en"]:
                words[i] = word.lower()
        name_friendly = " ".join(words)
        if name_friendly:
            name_friendly = name_friendly[0].upper() + name_friendly[1:]
            
        asignaturas.append({
            "code": code,
            "type": tipo,
            "name": name_friendly,
            "year": int(anio),
            "cuatrimestre": cuatrimestre
        })
    return asignaturas

# --- MAPEO DE ESTADOS ---
STATE_OPTIONS = {
    "materia": ["Sin Iniciar", "Cursada", "Aprobada"],
    "tesina": ["Sin Iniciar", "Proyecto Pres.", "Aprobada"],
    "acreditacion": ["Sin Iniciar", "Aprobada"],
    "curso": ["Sin Iniciar", "Aprobada"]
}

DB_TO_DISPLAY = {
    "sin_iniciar": "Sin Iniciar",
    "cursada": "Cursada",
    "proyecto_presentado": "Proyecto Pres.",
    "aprobada": "Aprobada"
}

DISPLAY_TO_DB = {v: k for k, v in DB_TO_DISPLAY.items()}

# --- INICIALIZACIÓN DE PROLOG Y DATOS ---
if "prolog_init" not in st.session_state:
    st.session_state.prolog = Prolog()
    st.session_state.prolog.consult("prolog/prolog-program.pl")
    st.session_state.prolog.consult("prolog/lic-informatica-2010.pl")
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

# --- INYECCIÓN DE ESTILOS CSS ---
st.markdown("""
<style>
/* Estilo base para la tarjeta de asignatura */
.card-container {
    border-radius: 8px;
    padding: 12px 14px;
    margin-bottom: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
    border-left: 5px solid #ccc;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.card-container:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
}

/* Colores distintivos por año */
.card-anio-1 {
    border-left-color: #1e88e5; /* Azul */
    background-color: rgba(30, 144, 255, 0.07);
}
.card-anio-2 {
    border-left-color: #2e7d32; /* Verde */
    background-color: rgba(46, 125, 50, 0.07);
}
.card-anio-3 {
    border-left-color: #fbc02d; /* Amarillo */
    background-color: rgba(251, 192, 45, 0.09);
}
.card-anio-4 {
    border-left-color: #c2185b; /* Rojo/Rosado */
    background-color: rgba(194, 24, 91, 0.07);
}
.card-anio-5 {
    border-left-color: #7b1fa2; /* Violeta */
    background-color: rgba(123, 31, 162, 0.07);
}
.card-tesina {
    border-left-color: #212121; /* Negro/Blanco */
    background-color: rgba(33, 33, 33, 0.08);
}

/* Detalles de texto */
.card-code {
    font-size: 0.72rem;
    font-style: italic;
    opacity: 0.7;
    margin-bottom: 2px;
}
.card-title {
    font-size: 1.0rem;
    font-weight: 700;
    margin: 0 0 4px 0;
    line-height: 1.25;
}
.card-meta {
    font-size: 0.78rem;
    opacity: 0.8;
    margin-bottom: 2px;
}

/* Ajustes para el segmented_control para que quede más compacto */
div[data-testid="stSegmentedControl"] {
    margin-top: 0px !important;
    margin-bottom: 12px !important;
}
</style>
""", unsafe_allow_html=True)

# --- FORMATTEADOR DE SOLUCIÓN PROLOG ---
def format_solucion(solucion, asignaturas_lista):
    name_map = {s["code"]: s["name"] for s in asignaturas_lista}
    html_lines = []
    try:
        if isinstance(solucion, list):
            for i, periodo in enumerate(solucion):
                periodo_num = i + 1
                html_lines.append(f"<div style='margin-bottom: 12px;'><strong>Periodo {periodo_num}</strong><ul>")
                if isinstance(periodo, list):
                    for avance in periodo:
                        av_str = str(avance)
                        match = re.search(r"estado_asignatura\((?:'([^']+)'|([a-zA-Z0-9_]+)),\s*([a-zA-Z0-9_]+)\)", av_str)
                        if match:
                            code = match.group(1) or match.group(2)
                            state = match.group(3)
                            name = name_map.get(code, code)
                            state_friendly = DB_TO_DISPLAY.get(state, state)
                            html_lines.append(f"<li><strong>{code}</strong> - {name} &rarr; <code>{state_friendly}</code></li>")
                        else:
                            html_lines.append(f"<li>{av_str}</li>")
                else:
                    html_lines.append(f"<li>{str(periodo)}</li>")
                html_lines.append("</ul></div>")
            return "\n".join(html_lines)
    except Exception as e:
        return f"<pre>Error al formatear: {e}\nRaw: {solucion}</pre>"
    return str(solucion)

# --- RENDERIZADO DE INTERFAZ ---
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
        
    optativa_1 = st.text_input("Optativa elegida I:", value="IF024").strip()
    optativa_2 = st.text_input("Optativa elegida II:", value="IF028").strip()
    
    boton_generar = st.form_submit_button("Generar Planificación Óptima")

# --- PROCESAMIENTO AL PRESIONAR EL BOTÓN ---
if boton_generar:
    if not optativa_1 or not optativa_2:
        st.error("Por favor, complete todos los campos obligatorios antes de continuar.")
    else:
        # Construimos la lista de estados del alumno
        lista_estados_prolog = []
        for cod, est in st.session_state.asignaturas_estados.items():
            if est != "sin_iniciar":
                lista_estados_prolog.append(f"estado_asignatura('{cod}',{est})")
        string_lista_asignaturas = "[" + ",".join(lista_estados_prolog) + "]"
        
        with st.spinner("Actualizando base de conocimiento y buscando solución..."):
            try:
                # 3. LIMPIEZA DE HECHOS ANTERIORES (¡Con nombres corregidos!)
                list(prolog.query("retractall(capacidad_carga_alumno(_))"))
                list(prolog.query("retractall(proximo_periodo_calendario_alumno(_, _))"))
                list(prolog.query("retractall(estados_asignaturas_alumno(_))"))
                list(prolog.query("retractall(optativa_elegida_i(_))"))
                list(prolog.query("retractall(optativa_elegida_ii(_))"))

                # 4. INSERCIÓN DE NUEVOS HECHOS
                prolog.assertz(f"capacidad_carga_alumno({capacidad})")
                prolog.assertz(f"proximo_periodo_calendario_alumno({anio}, {cuatrimestre})")
                prolog.assertz(f"estados_asignaturas_alumno({string_lista_asignaturas})")
                prolog.assertz(f"optativa_elegida_i('{optativa_1}')")
                prolog.assertz(f"optativa_elegida_ii('{optativa_2}')")
                
                # 5. EJECUCIÓN DE LA CONSULTA OPTIMIZADA (SÓLO la primera solución para evitar bucle de backtracking)
                query_id = prolog.query("iterative_deepening(Solucion)")
                iterador = iter(query_id)
                primera_respuesta = next(iterador, None)
                
                if primera_respuesta:
                    solucion_optima = primera_respuesta["Solucion"]
                    st.session_state.resultado_plan = {
                        "tipo": "success",
                        "mensaje": "¡Solución óptima encontrada exitosamente!",
                        "plan": solucion_optima
                    }
                else:
                    st.session_state.resultado_plan = {
                        "tipo": "warning",
                        "mensaje": "No se encontró ninguna solución válida para los datos ingresados.",
                        "plan": None
                    }
                query_id.close()
                
            except Exception as e:
                st.session_state.resultado_plan = {
                    "tipo": "error",
                    "mensaje": f"Ocurrió un error interactuando con SWI-Prolog: {e}",
                    "plan": None
                }

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
    activas = [f"estado_asignatura('{cod}',{est})" for cod, est in st.session_state.asignaturas_estados.items() if est != "sin_iniciar"]
    st.code("[" + ",\n ".join(activas) + "]")

# --- SECCIÓN DE TARJETAS POR AÑO ---
st.write("---")
st.write("## 📚 Estado de las Asignaturas (Selecciona el estado haciendo clic en las tarjetas)")

# Separar por años usando pestañas de Streamlit
tabs = st.tabs(["1° Año", "2° Año", "3° Año", "4° Año", "5° Año y Optativas"])

for y in range(1, 6):
    with tabs[y-1]:
        # Filtrar asignaturas de este año
        subjs_year = [s for s in st.session_state.asignaturas_lista if s["year"] == y]
        
        # Grid de 3 columnas
        cols = st.columns(3)
        for idx, subj in enumerate(subjs_year):
            col = cols[idx % 3]
            with col:
                code = subj["code"]
                tipo = subj["type"]
                name = subj["name"]
                cuat = subj["cuatrimestre"]
                
                # Clase de color de la tarjeta
                card_class = "card-tesina" if tipo == "tesina" else f"card-anio-{y}"
                
                # Cuatrimestre formateado
                periodo_display = f"{y}° Año" if cuat == "_" else f"{y}° Año - {cuat}° Cuat."
                tipo_display = "Tesina" if tipo == "tesina" else tipo.capitalize()
                
                # HTML de la tarjeta
                card_html = f"""
                <div class="card-container {card_class}">
                    <div class="card-code">{code}</div>
                    <div class="card-title">{name}</div>
                    <div class="card-meta">{tipo_display} &bull; {periodo_display}</div>
                </div>
                """
                st.markdown(card_html, unsafe_allow_html=True)
                
                # Control segmentado
                options = STATE_OPTIONS.get(tipo, ["Sin Iniciar", "Aprobada"])
                
                new_display = st.segmented_control(
                    label=f"Estado de {name}",
                    options=options,
                    key=f"widget_seg_{code}",
                    label_visibility="collapsed"
                )
                
                # Actualizar el diccionario central en base al widget
                disp_val = new_display if new_display is not None else "Sin Iniciar"
                st.session_state.asignaturas_estados[code] = DISPLAY_TO_DB.get(disp_val, "sin_iniciar")