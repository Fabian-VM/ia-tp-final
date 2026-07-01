import re
from pyswip import Prolog
from python.constants import DB_TO_DISPLAY, optativas_i_options, optativas_ii_options

def init_prolog(program_path="prolog/prolog-program.pl", plan_path="prolog/lic-informatica-2010.pl"):
    """
    Inicializa una instancia de Prolog y carga los archivos de programa y plan de estudios.
    """
    prolog = Prolog()
    prolog.consult(program_path)
    prolog.consult(plan_path)
    return prolog

def ejecutar_consulta_plan(prolog, capacidad, anio, cuatrimestre, optativa_1, optativa_2, asignaturas_estados):
    """
    Actualiza la base de conocimiento de Prolog con el estado del alumno y busca el plan sugerido.
    """
    # Construimos la lista de estados del alumno filtrando las optativas no elegidas
    lista_estados_prolog = []
    for cod, est in asignaturas_estados.items():
        if est != "sin_iniciar":
            # Si es una optativa pero no la elegida, la ignoramos
            if cod in optativas_i_options and cod != optativa_1:
                continue
            if cod in optativas_ii_options and cod != optativa_2:
                continue
            lista_estados_prolog.append(f"estado_asignatura('{cod}',{est})")
    string_lista_asignaturas = "[" + ",".join(lista_estados_prolog) + "]"
    
    try:
        # Limpieza de hechos anteriores
        list(prolog.query("retractall(estado_inicial(_))"))
        list(prolog.query("retractall(optativa_elegida_i(_))"))
        list(prolog.query("retractall(optativa_elegida_ii(_))"))

        # Inserción de nuevos hechos
        prolog.assertz(f"estado_inicial(estado_alumno({string_lista_asignaturas}, proximo_periodo_calendario({anio}, {cuatrimestre}), capacidad_carga({capacidad})))")
        prolog.assertz(f"optativa_elegida_i('{optativa_1}')")
        prolog.assertz(f"optativa_elegida_ii('{optativa_2}')")
        
        # Ejecución de la consulta (iterative deepening)
        query_id = prolog.query("iterative_deepening(Solucion)")
        iterador = iter(query_id)
        primera_respuesta = next(iterador, None)
        
        if primera_respuesta:
            solucion_optima = primera_respuesta["Solucion"]
            resultado = {
                "tipo": "success",
                "mensaje": "¡Solución óptima encontrada exitosamente!",
                "plan": solucion_optima
            }
        else:
            resultado = {
                "tipo": "warning",
                "mensaje": "No se encontró ninguna solución válida para los datos ingresados.",
                "plan": None
            }
        query_id.close()
        return resultado
        
    except Exception as e:
        return {
            "tipo": "error",
            "mensaje": f"Ocurrió un error interactuando con SWI-Prolog: {e}",
            "plan": None
        }

def format_solucion(solucion, asignaturas_lista):
    """
    Formatea la solución cruda devuelta por Prolog en una estructura HTML organizada y legible.
    """
    name_map = {s["code"]: s["name"] for s in asignaturas_lista}
    html_lines = []
    try:
        if isinstance(solucion, list):
            # La solución viene en orden cronológico inverso, la mostramos en orden cronológico
            solucion_chronological = list(reversed(solucion))
            
            for i, periodo in enumerate(solucion_chronological):
                periodo_num = i + 1
                periodo_str = str(periodo)
                
                # Extraemos el año y el cuatrimestre del periodo calendario
                match_periodo = re.search(r"periodo_calendario\((\d+),\s*([0-9a-zA-Z_]+)\)", periodo_str)
                if match_periodo:
                    anio_cal = match_periodo.group(1)
                    cuat_cal = match_periodo.group(2)
                    cuat_display = f"{cuat_cal}° Cuat." if cuat_cal != "_" else ""
                    periodo_title = f"Periodo {periodo_num} ({anio_cal} - {cuat_display})"
                else:
                    periodo_title = f"Periodo {periodo_num}"
                
                html_lines.append(f"<div style='margin-bottom: 12px;'><strong>{periodo_title}</strong><ul>")
                
                # Buscamos todas las asignaturas que avanzaron en este período
                matches = re.findall(r"estado_asignatura\((?:'([^']+)'|([a-zA-Z0-9_]+)),\s*([a-zA-Z0-9_]+)\)", periodo_str)
                if matches:
                    for m in matches:
                        code = m[0] or m[1]
                        state = m[2]
                        name = name_map.get(code, code)
                        state_friendly = DB_TO_DISPLAY.get(state, state)
                        html_lines.append(f"<li><strong>{code}</strong> - {name} &rarr; <code>{state_friendly}</code></li>")
                else:
                    html_lines.append(f"<li>{periodo_str}</li>")
                html_lines.append("</ul></div>")
            return "\n".join(html_lines)
    except Exception as e:
        return f"<pre>Error al formatear: {e}\nRaw: {solucion}</pre>"
    return str(solucion)
