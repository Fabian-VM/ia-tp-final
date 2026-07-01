import re

def parse_asignaturas(filepath="prolog/lic-informatica-2010.pl"):
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
