import streamlit as st
import json
from utils.prolog_service import PrologService


col_logo, col_title = st.columns([1, 10])
with col_logo:
    st.image("./static/favicon.png", width=64)
with col_title:
    st.title("Planner.pl")
st.write(
    "Esta herramienta permite organizar y planificar la carrera de Licenciatura en Informática (2010). "
    "Calcula el trayecto cuatrimestre a cuatrimestre respetando tus límites."
)

st.markdown("""
### ¿Cómo usar la aplicación?
1. **Paso 1: Configura tus datos académicos** 
   * Dirígete a la pestaña **"Mis Datos"** en la barra lateral.
   * Modifica tu capacidad de carga (puedes estimarla con el asistente interactivo) y otros datos.
   * Haz clic en **"Guardar Datos"** para registrar tu estado. La aplicación validará que tu progreso académico sea consistente con las correlatividades.
2. **Paso 2: Genera una planificación** 
   * Dirígete a la pestaña **"Planificación"** en la barra lateral.
   * Haz clic en **"Generar Planificación"** para ejecutar el algoritmo en Prolog.
   * El sistema te mostrará tu plan cuatrimestre por cuatrimestre con las materias que deberías cursar o rendir.
3. **Paso 3: Guarda o restaura tu progreso (Opcional)** 
   * Puedes exportar tu progreso a un archivo JSON o importar uno existente en cualquier momento desde esta página.
""")



# --- COPIA DE SEGURIDAD (IMPORTAR / EXPORTAR) ---
st.write("---")
st.subheader("¿Ya estuviste antes aquí?")

if "uploader_key" not in st.session_state:
    st.session_state.uploader_key = 0

col_exp, col_imp = st.columns(2)

with col_exp:
    st.write("Exporta tu progreso actual para guardarlo en un archivo JSON.")
    data_to_export = {
        "capacidad": st.session_state.capacidad,
        "anio": st.session_state.anio,
        "cuatrimestre": st.session_state.cuatrimestre,
        "optativa_1": st.session_state.optativa_1,
        "optativa_2": st.session_state.optativa_2,
        "asignaturas_estados": st.session_state.asignaturas_estados
    }
    json_string = json.dumps(data_to_export, indent=2)
    st.download_button(
        label="📥 Exportar datos a JSON",
        data=json_string,
        file_name="mi_progreso_academico.json",
        mime="application/json",
        use_container_width=True
    )

with col_imp:
    st.write("Carga tu archivo JSON para restaurar tu progreso guardado.")
    uploaded_file = st.file_uploader(
        "Subir archivo JSON", 
        type=["json"], 
        key=f"uploader_{st.session_state.uploader_key}",
        label_visibility="collapsed"
    )
    
    if uploaded_file is not None:
        if st.button("Cargar datos desde el archivo", type="primary", use_container_width=True):
            try:
                imported_data = json.load(uploaded_file)
                required_keys = ["capacidad", "anio", "cuatrimestre", "optativa_1", "optativa_2", "asignaturas_estados"]
                if all(k in imported_data for k in required_keys):
                    # Validar académicamente el progreso
                    es_valido = PrologService.validar_estado_alumno(
                        prolog=st.session_state.prolog,
                        capacidad=imported_data["capacidad"],
                        anio=imported_data["anio"],
                        cuatrimestre=imported_data["cuatrimestre"],
                        optativa_1=imported_data["optativa_1"],
                        optativa_2=imported_data["optativa_2"],
                        asignaturas_estados=imported_data["asignaturas_estados"]
                    )
                    
                    if es_valido:
                        # 1. Guardar en datos principales
                        st.session_state.capacidad = int(imported_data["capacidad"])
                        st.session_state.anio = int(imported_data["anio"])
                        st.session_state.cuatrimestre = int(imported_data["cuatrimestre"])
                        st.session_state.optativa_1 = str(imported_data["optativa_1"])
                        st.session_state.optativa_2 = str(imported_data["optativa_2"])
                        st.session_state.asignaturas_estados = imported_data["asignaturas_estados"]
                        
                        # 2. Borrar temporales para forzar la reinicialización con los nuevos valores
                        st.session_state.pop("temp_capacidad", None)
                        st.session_state.pop("temp_anio", None)
                        st.session_state.pop("temp_cuatrimestre", None)
                        st.session_state.pop("temp_optativa_1", None)
                        st.session_state.pop("temp_optativa_2", None)
                        
                        for code in list(st.session_state.keys()):
                            if code.startswith("temp_seg_"):
                                st.session_state.pop(code, None)
                            
                        # 3. Limpiar planificación previa
                        st.session_state.pop("resultado_plan", None)
                        
                        st.session_state.mostrar_importacion_exito = True
                        st.session_state.uploader_key += 1
                        st.rerun()
                    else:
                        st.error("El estado académico del archivo JSON no es válido según las correlativas de la carrera.")
                else:
                    st.error("El formato del archivo JSON no es válido.")
            except Exception as e:
                st.error(f"Error al importar el archivo: {e}")

if st.session_state.pop("mostrar_importacion_exito", False):
    st.success("¡Progreso académico importado y guardado con éxito!")


