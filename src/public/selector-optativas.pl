% Con la aclaración de que en Madryn ahora mismo solo esta inf industrial y la otra

% Asignaturas optativas
asignatura('IF014', materia, base_de_datos_ii, 5, 1).
asignatura('IF024', materia, informatica_industrial, 5, 1).
asignatura('IF027', materia, modelos_y_simulacion, 5, 1).
asignatura('IF023', materia, diseno_de_aplicaciones_web, 5, 2).
asignatura('IF034', materia, sistemas_paralelos_ii, 5, 2).
asignatura('IF053', materia, planificacion_y_gestion_si, 5, 2).
asignatura('IF028', materia, monitorizacion_y_visualizacion, 5, 2).
% Correlatividades de optativas
requisito('IF014', requiere(cursada, 'IF010')).
requisito('IF024', requiere(cursada, 'IF015')).
requisito('IF024', requiere(cursada, 'IF019')).
requisito('IF027', requiere(cursada, 'IF020')).
requisito('IF023', requiere(cursada, 'IF009')).
requisito('IF023', requiere(cursada, 'IF015')).
requisito('IF023', requiere(cursada, 'IF019')).
requisito('IF034', requiere(cursada, 'IF018')).
requisito('IF053', requiere(cursada, 'IF015')).
requisito('IF028', requiere(cursada, 'IF024')).

opciones_optativa_1(Codigo) :-
    asignatura(Codigo, materia, _, 5, 1).

opciones_optativa_2(Codigo, Optativa1) :-
    asignatura(Optativa1, materia, _, 5, 1),
    asignatura(Codigo, materia, _, 5, 2),
    not((
        asignatura(OtraOptativa, materia, _, 5, 1),
        requisito(Codigo, requiere(cursada, OtraOptativa)),
        OtraOptativa \= Optativa1
    )).

