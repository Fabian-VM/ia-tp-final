
% PERIODOS
anio_plan(1).
anio_plan(2).
anio_plan(3).
anio_plan(4).
anio_plan(5).
ultimo_anio_plan(5).

% DATOS DE ASIGNATURAS
tipo_asignatura(acreditacion).
tipo_asignatura(curso).
tipo_asignatura(materia).
tipo_asignatura(tesina).
estado_tipo_asignatura(_, sin_iniciar).
estado_tipo_asignatura(materia, cursada).
estado_tipo_asignatura(tesina, proyecto_presentado).
estado_tipo_asignatura(_, aprobada).
siguiente_estado_tipo_asignatura(materia, sin_iniciar, cursada, 6).
siguiente_estado_tipo_asignatura(materia, cursada, aprobada, 2).
siguiente_estado_tipo_asignatura(acreditacion, sin_iniciar, aprobada, 2).
siguiente_estado_tipo_asignatura(curso, sin_iniciar, aprobada, 2).
siguiente_estado_tipo_asignatura(tesina, sin_iniciar, proyecto_presentado, 2).
siguiente_estado_tipo_asignatura(tesina, proyecto_presentado, aprobada, 8).
estado_asignatura_superado(Estado, estado_asignatura(_, Estado)).
estado_asignatura_superado(EstadoSuperado, estado_asignatura(Codigo, EstadoReal)) :-
    asignatura(Codigo, Tipo, _, _),
    siguiente_estado_tipo_asignatura(Tipo, AnteriorEstadoReal, EstadoReal, _),
    estado_asignatura_superado(EstadoSuperado, estado_asignatura(Codigo, AnteriorEstadoReal)).


% ASIGNATURAS
% asignatura(Código, Tipo, Nombre, periodo_plan(AnioPlan, Cuatrimestre))
% 1°
asignatura('IF001', materia, elementos_de_informatica, periodo_plan(1, 1)).
asignatura('MA045', materia, algebra, periodo_plan(1, 1)).
asignatura('IF002', materia, expresion_de_problemas_y_algoritmos, periodo_plan(1, 1)).
asignatura('IF003', materia, algoritmica_y_programacion_i, periodo_plan(1, 2)).
asignatura('MA046', materia, analisis_matematico, periodo_plan(1, 2)).
asignatura('MA008', materia, elementos_de_logica_y_matematica_discreta, periodo_plan(1, 2)).
asignatura('FA007', acreditacion, acreditacion_de_idioma, periodo_plan(1, _)).
% 2°
asignatura('IF004', materia, sistemas_y_organizaciones, periodo_plan(2, 1)).
asignatura('IF005', materia, arquitectura_de_computadoras, periodo_plan(2, 1)).
asignatura('IF006', materia, algoritmica_y_programacion_ii, periodo_plan(2, 1)).
asignatura('IF007', materia, bases_de_datos_i, periodo_plan(2, 2)).
asignatura('MA006', materia, estadistica, periodo_plan(2, 2)).
asignatura('IF008', materia, programacion_orientada_a_objetos, periodo_plan(2, 2)).
% 3°
asignatura('IF009', materia, laboratorio_de_programacion_y_lenguajes, periodo_plan(3, 1)).
asignatura('IF010', materia, analisis_y_diseno_de_sistemas, periodo_plan(3, 1)).
asignatura('IF011', materia, sistemas_operativos, periodo_plan(3, 1)).
asignatura('IF012', materia, desarrollo_de_software, periodo_plan(3, 2)).
asignatura('IF013', materia, fundamentos_teoricos_de_informatica, periodo_plan(3, 2)).
asignatura('MA047', materia, complementos_matematicos, periodo_plan(3, 2)).
asignatura('FA102', curso, estrategias_comunicacionales, periodo_plan(3, 2)).
asignatura('FA103', curso, relaciones_humanas, periodo_plan(3, 2)).
% 4°
asignatura('IF015', materia, ingenieria_de_software, periodo_plan(4, 1)).
asignatura('IF018', materia, inteligencia_artificial, periodo_plan(4, 1)).
asignatura('IF019', materia, redes_y_transmision_de_datos, periodo_plan(4, 1)).
asignatura('IF016', materia, aspectos_legales_y_profesionales, periodo_plan(4, 2)).
asignatura('IF020', materia, paradigmas_y_lenguajes_de_programacion, periodo_plan(4, 2)).
asignatura('IF022', materia, sistemas_distribuidos, periodo_plan(4, 2)).
% 5°
asignatura('IF021', materia, arquitectura_de_redes_y_servicios, periodo_plan(5, 1)).
asignatura('IF017', materia, taller_de_nuevas_tecnologias, periodo_plan(5, 1)).
asignatura('IF025', materia, sistemas_embebidos_y_de_tiempo_real, periodo_plan(5, 2)).
asignatura('IF026', tesina, tesina, periodo_plan(5, _)).
% Optativas 
asignatura('IF014', materia, base_de_datos_ii, periodo_plan(5, 1)) :- optativa_elegida_i('IF014').
asignatura('IF024', materia, informatica_industrial, periodo_plan(5, 1)) :- optativa_elegida_i('IF024').
asignatura('IF027', materia, modelos_y_simulacion, periodo_plan(5, 1)) :- optativa_elegida_i('IF027').
asignatura('IF023', materia, diseno_de_aplicaciones_web, periodo_plan(5, 2)) :- optativa_elegida_ii('IF023').
asignatura('IF034', materia, sistemas_paralelos_ii, periodo_plan(5, 2)) :- optativa_elegida_ii('IF034').
asignatura('IF053', materia, planificacion_y_gestion_si, periodo_plan(5, 2)) :- optativa_elegida_ii('IF053').
asignatura('IF028', materia, monitorizacion_y_visualizacion, periodo_plan(5, 2)) :- optativa_elegida_ii('IF028').

% REQUISITOS
% requisito(estado_asignatura(Codigo, Estado), requiere(estado_asignatura(Codigo, Estado)))
requisito(estado_asignatura('IF003', cursada), requiere(estado_asignatura('IF002', cursada))).
requisito(estado_asignatura('IF005', cursada), requiere(estado_asignatura('IF001', cursada))).
requisito(estado_asignatura('IF006', cursada), requiere(estado_asignatura('IF003', cursada))).
requisito(estado_asignatura('IF006', cursada), requiere(estado_asignatura('MA008', cursada))).
requisito(estado_asignatura('IF007', cursada), requiere(estado_asignatura('IF006', cursada))).
requisito(estado_asignatura('MA006', cursada), requiere(estado_asignatura('MA045', cursada))).
requisito(estado_asignatura('MA006', cursada), requiere(estado_asignatura('MA046', cursada))).
requisito(estado_asignatura('IF008', cursada), requiere(estado_asignatura('IF006', cursada))).
requisito(estado_asignatura('IF009', cursada), requiere(estado_asignatura('IF008', cursada))).
requisito(estado_asignatura('IF010', cursada), requiere(estado_asignatura('IF004', cursada))).
requisito(estado_asignatura('IF010', cursada), requiere(estado_asignatura('IF007', cursada))).
requisito(estado_asignatura('IF011', cursada), requiere(estado_asignatura('IF005', cursada))).
requisito(estado_asignatura('IF011', cursada), requiere(estado_asignatura('IF006', cursada))).
requisito(estado_asignatura('IF012', cursada), requiere(estado_asignatura('IF008', cursada))).
requisito(estado_asignatura('IF012', cursada), requiere(estado_asignatura('IF010', cursada))).
requisito(estado_asignatura('IF013', cursada), requiere(estado_asignatura('IF006', cursada))).
requisito(estado_asignatura('IF013', cursada), requiere(estado_asignatura('MA008', cursada))).
requisito(estado_asignatura('MA047', cursada), requiere(estado_asignatura('MA045', cursada))).
requisito(estado_asignatura('MA047', cursada), requiere(estado_asignatura('MA046', cursada))).
requisito(estado_asignatura('IF015', cursada), requiere(estado_asignatura('IF012', cursada))).
requisito(estado_asignatura('IF015', cursada), requiere(estado_asignatura('MA006', cursada))).
requisito(estado_asignatura('IF018', cursada), requiere(estado_asignatura('IF013', cursada))).
requisito(estado_asignatura('IF018', cursada), requiere(estado_asignatura('MA047', cursada))).
requisito(estado_asignatura('IF019', cursada), requiere(estado_asignatura('IF011', cursada))).
requisito(estado_asignatura('IF020', cursada), requiere(estado_asignatura('IF009', cursada))).
requisito(estado_asignatura('IF020', cursada), requiere(estado_asignatura('IF013', cursada))).
requisito(estado_asignatura('IF022', cursada), requiere(estado_asignatura('IF019', cursada))).
requisito(estado_asignatura('IF021', cursada), requiere(estado_asignatura('IF019', cursada))).
requisito(estado_asignatura('IF017', cursada), requiere(estado_asignatura('IF015', cursada))).
requisito(estado_asignatura('IF017', cursada), requiere(estado_asignatura('IF019', cursada))).
requisito(estado_asignatura('IF025', cursada), requiere(estado_asignatura('IF015', cursada))).
requisito(estado_asignatura('IF025', cursada), requiere(estado_asignatura('IF022', cursada))).
requisito(estado_asignatura('FA102', aprobada), requiere(cantidad_minima_aprobadas(10))).
requisito(estado_asignatura('FA103', aprobada), requiere(cantidad_minima_aprobadas(10))).
requisito(estado_asignatura('IF016', cursada), requiere(cantidad_minima_aprobadas(15))).
requisito(estado_asignatura('IF014', cursada), requiere(estado_asignatura('IF010', cursada))) :- optativa_elegida_i('IF014').
requisito(estado_asignatura('IF024', cursada), requiere(estado_asignatura('IF015', cursada))) :- optativa_elegida_i('IF024').
requisito(estado_asignatura('IF024', cursada), requiere(estado_asignatura('IF019', cursada))) :- optativa_elegida_i('IF024').
requisito(estado_asignatura('IF027', cursada), requiere(estado_asignatura('IF020', cursada))) :- optativa_elegida_i('IF027').
requisito(estado_asignatura('IF023', cursada), requiere(estado_asignatura('IF009', cursada))) :- optativa_elegida_ii('IF023').
requisito(estado_asignatura('IF023', cursada), requiere(estado_asignatura('IF015', cursada))) :- optativa_elegida_ii('IF023').
requisito(estado_asignatura('IF023', cursada), requiere(estado_asignatura('IF019', cursada))) :- optativa_elegida_ii('IF023').
requisito(estado_asignatura('IF034', cursada), requiere(estado_asignatura('IF018', cursada))) :- optativa_elegida_ii('IF034').
requisito(estado_asignatura('IF053', cursada), requiere(estado_asignatura('IF015', cursada))) :- optativa_elegida_ii('IF053').
requisito(estado_asignatura('IF028', cursada), requiere(estado_asignatura('IF024', cursada))) :- optativa_elegida_ii('IF028').
requisito(estado_asignatura('IF026', proyecto_presentado), requiere(estado_asignatura(Codigo, cursada))) :-
    asignatura(Codigo, _, _, periodo_plan(4, _)).
requisito(estado_asignatura('IF026', aprobada), requiere(estado_asignatura(Codigo, aprobada))) :-
    asignatura(Codigo, _, _, periodo_plan(4, _)).
requisito(estado_asignatura('IF026', aprobada), requiere(estado_asignatura(Codigo, cursada))) :-
    asignatura(Codigo, materia, _, periodo_plan(5, 1)).
requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura('FA007', aprobada))) :-
    anio_plan(AnioPlan),
    AnioPlan >= 2,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura('FA102', aprobada))) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura('FA103', aprobada))) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
% Aprobación
requisito(estado_asignatura(Codigo, aprobada), requiere(estado_asignatura(Codigo, cursada))) :-
    asignatura(Codigo, materia, _, _).
requisito(estado_asignatura(Codigo, aprobada), requiere(estado_asignatura(Codigo, proyecto_presentado))) :-
    asignatura(Codigo, tesina, _, _).
% Correlatividad de materias para aprobar
requisito(estado_asignatura(Codigo, aprobada), requiere(estado_asignatura(Correlativa, aprobada))) :- 
    asignatura(Codigo, materia, _, _), 
    asignatura(Correlativa, materia, _, _), 
    requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura(Correlativa, cursada))).
% Precorrelatividad de materias para aprobar
requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura(Precorrelativa, aprobada))) :- 
    asignatura(Codigo, materia, _, _), 
    asignatura(Precorrelativa, materia, _, _), 
    requisito(estado_asignatura(Codigo, cursada), requiere(estado_asignatura(Correlativa, cursada))), 
    requisito(estado_asignatura(Correlativa, cursada), requiere(estado_asignatura(Precorrelativa, cursada))).

% CUMPLIMIENTO DE REQUISITOS
% No son generativos, solo validan dadas las entradas
cumple_requisito(EstadosAsignaturas, estado_asignatura(Codigo, EstadoDeseado)) :-
    member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
    estado_asignatura_superado(EstadoDeseado, estado_asignatura(Codigo, EstadoReal)).

cumple_requisito(EstadosAsignaturas, cantidad_minima_aprobadas(CantidadMinima)) :-
    findall(Codigo, (
        member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
        estado_asignatura_superado(aprobada, estado_asignatura(Codigo, EstadoReal))
    ), Lista),
    length(Lista, CantidadAprobadas),
    CantidadAprobadas >= CantidadMinima.


