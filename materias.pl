% materias.pl
materia_aprobada(algebra).
materia_aprobada(discreta).

% Una materia se puede cursar si su correlativa está aprobada
puede_cursar(analisis2) :- materia_aprobada(algebra).
puede_cursar(prolog) :- materia_aprobada(discreta).
puede_cursar(sistemas_operativos) :- materia_aprobada(arquitectura).