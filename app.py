import streamlit as st
from pyswip import Prolog

# 1. Configuración inicial de Prolog
prolog = Prolog()
prolog.consult("materias.pl")  # Carga tu archivo de Prolog

# 2. Interfaz de usuario con Streamlit
st.title("Verificador de Correlativas 🎓")
st.write("Consulta qué materias puedes cursar según el estado actual de Prolog.")

# Lista de materias para que el usuario elija
materia = st.selectbox(
    "¿Qué materia quieres verificar?",
    ["analisis2", "prolog", "sistemas_operativos"]
)

if st.button("Verificar Disponibilidad"):
    # 3. Armar la consulta dinámica para Prolog: "puede_cursar(materia)"
    # Usamos bool() porque query() devuelve una lista vacía si es falso, o con elementos si es verdadero
    consulta = f"puede_cursar({materia})"
    
    try:
        resultado = list(prolog.query(consulta))
        
        if resultado:
            st.success(f"¡Sí! Puedes cursar **{materia}** porque cumples con los requisitos.")
        else:
            st.error(f"No puedes cursar **{materia}**. Te falta aprobar la materia correlativa.")
            
    except Exception as e:
        st.error(f"Hubo un error en la consulta de Prolog: {e}")

# 4. Extra: Mostrar qué hay actualmente en la "base de datos" de Prolog
if st.checkbox("Mostrar materias aprobadas actualmente"):
    aprobadas = list(prolog.query("materia_aprobada(X)"))
    # extraemos el valor de la variable X que devuelve Prolog
    lista_materias = [m["X"] for m in aprobadas]
    st.write(lista_materias)