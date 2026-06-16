
% PERIODOS
anio_plan(1).
anio_plan(2).
anio_plan(3).
anio_plan(4).
anio_plan(5).

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
% requisito(Codigo, requiere(Requisito))
requisito(cursada, 'IF003', requiere(cursada, 'IF002')).
requisito(cursada, 'IF005', requiere(cursada, 'IF001')).
requisito(cursada, 'IF006', requiere(cursada, 'IF003')).
requisito(cursada, 'IF006', requiere(cursada, 'MA008')).
requisito(cursada, 'IF007', requiere(cursada, 'IF006')).
requisito(cursada, 'MA006', requiere(cursada, 'MA045')).
requisito(cursada, 'MA006', requiere(cursada, 'MA046')).
requisito(cursada, 'IF008', requiere(cursada, 'IF006')).
requisito(cursada, 'IF009', requiere(cursada, 'IF008')).
requisito(cursada, 'IF010', requiere(cursada, 'IF004')).
requisito(cursada, 'IF010', requiere(cursada, 'IF007')).
requisito(cursada, 'IF011', requiere(cursada, 'IF005')).
requisito(cursada, 'IF011', requiere(cursada, 'IF006')).
requisito(cursada, 'IF012', requiere(cursada, 'IF008')).
requisito(cursada, 'IF012', requiere(cursada, 'IF010')).
requisito(cursada, 'IF013', requiere(cursada, 'IF006')).
requisito(cursada, 'IF013', requiere(cursada, 'MA008')).
requisito(cursada, 'MA047', requiere(cursada, 'MA045')).
requisito(cursada, 'MA047', requiere(cursada, 'MA046')).
requisito(cursada, 'IF015', requiere(cursada, 'IF012')).
requisito(cursada, 'IF015', requiere(cursada, 'MA006')).
requisito(cursada, 'IF018', requiere(cursada, 'IF013')).
requisito(cursada, 'IF018', requiere(cursada, 'MA047')).
requisito(cursada, 'IF019', requiere(cursada, 'IF011')).
requisito(cursada, 'IF020', requiere(cursada, 'IF009')).
requisito(cursada, 'IF020', requiere(cursada, 'IF013')).
requisito(cursada, 'IF022', requiere(cursada, 'IF019')).
requisito(cursada, 'IF021', requiere(cursada, 'IF019')).
requisito(cursada, 'IF017', requiere(cursada, 'IF015')).
requisito(cursada, 'IF017', requiere(cursada, 'IF019')).
requisito(cursada, 'IF025', requiere(cursada, 'IF015')).
requisito(cursada, 'IF025', requiere(cursada, 'IF022')).
requisito(aprobada, 'FA102', requiere(cantidad_minima_aprobadas, 10)).
requisito(aprobada, 'FA103', requiere(cantidad_minima_aprobadas, 10)).
requisito(cursada, 'IF016', requiere(cantidad_minima_aprobadas, 15)).
requisito(cursada, 'IF014', requiere(cursada, 'IF010')) :- optativa_elegida_i('IF014').
requisito(cursada, 'IF024', requiere(cursada, 'IF015')) :- optativa_elegida_i('IF024').
requisito(cursada, 'IF024', requiere(cursada, 'IF019')) :- optativa_elegida_i('IF024').
requisito(cursada, 'IF027', requiere(cursada, 'IF020')) :- optativa_elegida_i('IF027').
requisito(cursada, 'IF023', requiere(cursada, 'IF009')) :- optativa_elegida_ii('IF023').
requisito(cursada, 'IF023', requiere(cursada, 'IF015')) :- optativa_elegida_ii('IF023').
requisito(cursada, 'IF023', requiere(cursada, 'IF019')) :- optativa_elegida_ii('IF023').
requisito(cursada, 'IF034', requiere(cursada, 'IF018')) :- optativa_elegida_ii('IF034').
requisito(cursada, 'IF053', requiere(cursada, 'IF015')) :- optativa_elegida_ii('IF053').
requisito(cursada, 'IF028', requiere(cursada, 'IF024')) :- optativa_elegida_ii('IF028').
requisito(proyecto_presentado, 'IF026', requiere(cursada, Codigo)) :-
    asignatura(Codigo, materia, _, periodo_plan(4, _)).
requisito(aprobada, 'IF026', requiere(aprobada, Codigo)) :-
    asignatura(Codigo, _, _, periodo_plan(4, _)).
requisito(aprobada, 'IF026', requiere(cursada, Codigo)) :-
    asignatura(Codigo, materia, _, periodo_plan(5, 1)).
requisito(aprobada, 'IF026', requiere(aprobada, Codigo)) :-
    asignatura(Codigo, curso, _, periodo_plan(5, 1)).
requisito(cursada, Codigo, requiere(aprobada, 'FA007')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 2,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(cursada, Codigo, requiere(aprobada, 'FA102')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(cursada, Codigo, requiere(aprobada, 'FA103')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(aprobada, Codigo, requiere(cursada, Codigo)) :-
    asignatura(Codigo, materia, _, _).
requisito(aprobada, Codigo, requiere(aprobada, Correlativa)) :- 
    asignatura(Codigo, _, _, _), 
    asignatura(Correlativa, _, _, _), 
    requisito(cursada, Codigo, requiere(cursada, Correlativa)).
requisito(cursada, Codigo, requiere(aprobada, Precorrelativa)) :- 
    asignatura(Codigo, _, _, _), 
    asignatura(Precorrelativa, _, _, _), 
    requisito(cursada, Codigo, requiere(cursada, Correlativa)), 
    requisito(cursada, Correlativa, requiere(cursada, Precorrelativa)).
requisito(aprobada, Codigo, requiere(proyecto_presentado, Codigo)) :-
    asignatura(Codigo, tesina, _, _).


% CUMPLIMIENTO DE REQUISITOS
% No son generativos, solo validan dadas las entradas
cumple_este_requisito(requiere(EstadoDeseado, Codigo), EstadosAsignaturas) :-
    member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
    estado_asignatura_superado(EstadoDeseado, estado_asignatura(Codigo, EstadoReal)).
cumple_este_requisito(requiere(cantidad_minima_aprobadas, CantidadMinima), EstadosAsignaturas) :-
    findall(Codigo, (
        member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
        estado_asignatura_superado(aprobada, estado_asignatura(Codigo, EstadoReal))
    ), Lista),
    length(Lista, CantidadAprobadas),
    CantidadAprobadas >= CantidadMinima.


