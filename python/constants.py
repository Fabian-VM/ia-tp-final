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

# --- OPTATIVAS DISPONIBLES ---
optativas_i_options = {
    "IF014": "IF014: Base de Datos II",
    "IF024": "IF024: Informática Industrial",
    "IF027": "IF027: Modelos y Simulación"
}

optativas_ii_options = {
    "IF023": "IF023: Diseño de Aplicaciones Web",
    "IF034": "IF034: Sistemas Paralelos II",
    "IF053": "IF053: Planificación y Gestión SI",
    "IF028": "IF028: Monitorización y Visualización"
}

# --- COLORES DISTINTIVOS ---
YEAR_COLOR_NAMES = {
    1: "blue",
    2: "green",
    3: "orange",
    4: "red",
    5: "violet",
    "tesina": "gray"
}
