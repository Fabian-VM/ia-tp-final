import re
from pyswip import Prolog
from utils.constants import DB_TO_DISPLAY, optativas_i_options, optativas_ii_options

class PrologService:
    @staticmethod
    def init_prolog(program_path="prolog/planner-core.pl", plan_path="prolog/lic-informatica-2010.pl"):
        """
        Inicializa una instancia de Prolog y carga los archivos de programa y plan de estudios.
        """
        prolog = Prolog()
        prolog.consult(program_path)
        prolog.consult(plan_path)
        return prolog

    @staticmethod
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

    @staticmethod
    def obtener_asignaturas(prolog):
        """
        Obtiene la lista de asignaturas consultando directamente la base de conocimiento de Prolog.
        """
        query = "clause(asignatura(Code, Tipo, Name, periodo_plan(Anio, Cuatrimestre)), Body)"
        results = list(prolog.query(query))
        
        asignaturas = []
        for r in results:
            code = str(r['Code'])
            tipo = str(r['Tipo'])
            name = str(r['Name'])
            anio = int(r['Anio'])
            cuat = r['Cuatrimestre']
            cuat_str = str(cuat) if isinstance(cuat, int) or (isinstance(cuat, str) and cuat in ('1', '2')) else "_"
            
            asignaturas.append({
                "code": code,
                "type": tipo,
                "name": name,
                "year": anio,
                "cuatrimestre": cuat_str
            })
        return asignaturas

    @staticmethod
    def procesar_plan(solucion, asignaturas_lista):
        """
        Parsea la solución de Prolog en una estructura de datos de Python limpia y estructurada.
        """
        # Create mapping of code -> info
        info_map = {s["code"]: s for s in asignaturas_lista}
        
        plan_procesado = []
        
        if not isinstance(solucion, list):
            return []
            
        # La solución viene en orden cronológico inverso, la mostramos en orden cronológico
        solucion_chronological = list(reversed(solucion))
        
        for periodo in solucion_chronological:
            periodo_str = str(periodo)
            
            # Extraemos el año y el cuatrimestre del periodo calendario
            match_periodo = re.search(r"periodo_calendario\((\d+),\s*([0-9a-zA-Z_]+)\)", periodo_str)
            if match_periodo:
                anio_cal = match_periodo.group(1)
                cuat_cal = match_periodo.group(2)
            else:
                anio_cal = "Desconocido"
                cuat_cal = "_"
                
            materias_periodo = []
            
            # Buscamos todas las asignaturas que avanzaron en este período
            matches = re.findall(r"estado_asignatura\((?:'([^']+)'|([a-zA-Z0-9_]+)),\s*([a-zA-Z0-9_]+)\)", periodo_str)
            for m in matches:
                code = m[0] or m[1]
                state = m[2]
                
                # Obtener datos de la asignatura
                subj_info = info_map.get(code, {
                    "code": code,
                    "name": code,
                    "type": "materia",
                    "year": 1,
                    "cuatrimestre": "_"
                })
                
                materias_periodo.append({
                    "code": code,
                    "name": subj_info["name"],
                    "type": subj_info["type"],
                    "year": subj_info["year"],
                    "cuatrimestre": subj_info["cuatrimestre"],
                    "state": state
                })
                
            plan_procesado.append({
                "anio_cal": anio_cal,
                "cuat_cal": cuat_cal,
                "materias": materias_periodo
            })
            
        return plan_procesado

    @staticmethod
    def validar_estado_alumno(prolog, capacidad, anio, cuatrimestre, optativa_1, optativa_2, asignaturas_estados):
        """
        Valida el estado del alumno usando la regla estado(estado_alumno(...)) en Prolog.
        """
        from utils.constants import optativas_i_options, optativas_ii_options
        
        # Construimos la lista de estados para la consulta
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
            # Limpiamos y asertamos optativas elegidas para que se resuelvan las firmas de asignatura/4
            list(prolog.query("retractall(optativa_elegida_i(_))"))
            list(prolog.query("retractall(optativa_elegida_ii(_))"))
            prolog.assertz(f"optativa_elegida_i('{optativa_1}')")
            prolog.assertz(f"optativa_elegida_ii('{optativa_2}')")
            
            # Ejecutar consulta
            query_str = f"estado(estado_alumno({string_lista_asignaturas}, proximo_periodo_calendario({anio}, {cuatrimestre}), capacidad_carga({capacidad})))"
            res = list(prolog.query(query_str))
            return bool(res)
        except Exception as e:
            print(f"Error al validar estado en Prolog: {e}")
            return False
