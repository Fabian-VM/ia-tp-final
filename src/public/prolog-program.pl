

% =========== INPUT: HECHOS SOBRE EL ALUMNO ================

% Validaciones a agregar durante el cargado del JSON
% - No deben haber correlatividades circulares
% - Un estado por código, un código no puede tener más de un estado acá
% - Lo que está cursando debe estar acorde al cuatrimestre actual

% tambien se le deben pedir las optativas a elegir
% una vez esos datos cargados, mostrar la tabla de todas las asignaturas
% para que marque y luego ponga "generar planificación"


% =========== INPUT: HECHOS SOBRE EL PLAN DE ESTUDIOS ================

% PERIODOS DETERMINADOS POR EL PLAN
anio_plan(1).
anio_plan(2).
anio_plan(3).
anio_plan(4).
anio_plan(5).
ultimo_anio_plan(5).
cuatrimestre(1).
cuatrimestre(2).
% proximo_cuatrimestre(Actual, Siguiente, AnioSumado)
proximo_cuatrimestre(1, 2, 0).
proximo_cuatrimestre(2, 1, 1).
periodo_plan(AnioPlan, Cuatrimestre) :-
    anio_plan(AnioPlan),
    cuatrimestre(Cuatrimestre).
periodo_calendario(AnioCalendario, Cuatrimestre) :-
    number(AnioCalendario),
    cuatrimestre(Cuatrimestre).
siguiente_periodo_calendario(AnioCalendarioA, CuatrimestreA, AnioCalendarioB, CuatrimestreB) :-
    proximo_cuatrimestre(CuatrimestreA, CuatrimestreB, AnioSumado),
    AnioCalendarioB is AnioCalendarioA + AnioSumado.

% ETAPAS DE PROGRESO EN TIPOS DE ASIGNATURAS
tipo_asignatura(acreditacion).
tipo_asignatura(curso).
tipo_asignatura(materia).
tipo_asignatura(tesina).
estado_tipo_asignatura(_, sin_iniciar).
estado_tipo_asignatura(materia, cursada).
estado_tipo_asignatura(tesina, proyecto_presentado).
estado_tipo_asignatura(_, aprobada).
% siguiente_estado_tipo_asignatura(Tipo, EstadoInicial, EstadoSiguiente, Carga).
siguiente_estado_tipo_asignatura(materia, sin_iniciar, cursada, 6).
siguiente_estado_tipo_asignatura(materia, cursada, aprobada, 2).
siguiente_estado_tipo_asignatura(acreditacion, sin_iniciar, aprobada, 2).
siguiente_estado_tipo_asignatura(curso, sin_iniciar, aprobada, 2).
siguiente_estado_tipo_asignatura(tesina, sin_iniciar, proyecto_presentado, 2).
siguiente_estado_tipo_asignatura(tesina, proyecto_presentado, aprobada, 8).
asignatura_se_considera(Estado, estado_asignatura(_, Estado)).
asignatura_se_considera(cursada, estado_asignatura(Codigo, aprobada)) :-
    asignatura(Codigo, materia, _, _).


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
% Optativas hardcodeadas
asignatura('IF024', materia, informatica_industrial, periodo_plan(5, 1)).
asignatura('IF028', materia, monitorizacion_y_visualizacion, periodo_plan(5, 2)).


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
% Optativas hardcodeadas
requisito(cursada, 'IF024', requiere(cursada, 'IF015')).
requisito(cursada, 'IF024', requiere(cursada, 'IF019')).
requisito(cursada, 'IF028', requiere(cursada, 'IF024')).
% Tesina
requisito(proyecto_presentado, 'IF026', requiere(cursada, Codigo)) :-
    asignatura(Codigo, materia, _, periodo_plan(4, _)).
requisito(aprobada, 'IF026', requiere(aprobada, Codigo)) :-
    asignatura(Codigo, _, _, periodo_plan(4, _)).
requisito(aprobada, 'IF026', requiere(cursada, Codigo)) :-
    asignatura(Codigo, materia, _, periodo_plan(5, 1)).
requisito(aprobada, 'IF026', requiere(aprobada, Codigo)) :-
    asignatura(Codigo, curso, _, periodo_plan(5, 1)).
% Bloqueos por acreditaciones
requisito(cursada, Codigo, requiere(aprobada, 'FA007')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 2,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
% Bloqueos por cursos
requisito(cursada, Codigo, requiere(aprobada, 'FA102')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
requisito(cursada, Codigo, requiere(aprobada, 'FA103')) :-
    anio_plan(AnioPlan),
    AnioPlan >= 5,
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, _)).
% Reglas generales
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



% =========== REGLAS SOBRE EL PLAN DE ESTUDIOS ================

% CUMPLIMIENTO DE REQUISITOS
% No son generativos, solo validan dadas las entradas
cumple_este_requisito(requiere(EstadoDeseado, Codigo), EstadosAsignaturas) :-
    member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
    asignatura_se_considera(EstadoDeseado, estado_asignatura(Codigo, EstadoReal)).
cumple_este_requisito(requiere(cantidad_minima_aprobadas, CantidadMinima), EstadosAsignaturas) :-
    findall(Codigo, (
        member(estado_asignatura(Codigo, EstadoReal), EstadosAsignaturas),
        asignatura_se_considera(aprobada, estado_asignatura(Codigo, EstadoReal))
    ), Lista),
    length(Lista, CantidadAprobadas),
    CantidadAprobadas >= CantidadMinima.
cumple_estos_requisitos([], _).
cumple_estos_requisitos([Requisito|RestoRequisitos], EstadosAsignaturas) :-
    cumple_este_requisito(Requisito, EstadosAsignaturas),
    cumple_estos_requisitos(RestoRequisitos, EstadosAsignaturas).

verificar_requisitos_para(estado_asignatura(Codigo, EstadoDeseado), EstadosAsignaturas) :-
    findall(Requisito, requisito(EstadoDeseado, Codigo, Requisito), ListaRequisitos),
    cumple_estos_requisitos(ListaRequisitos, EstadosAsignaturas).


% CALCULO DE AVANCES
% Generan o validan, dada la lista de EstadosAsignatura
% STARTHERE Refactorizar esto para usar la estructura avance()


valor(estado_asignatura(Codigo, Estado), Valor) :-
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, Cuatrimestre)),
    desbloqueos_transitivos([estado_asignatura(Codigo, Estado)], Desbloqueadas),
    length(Desbloqueadas, N),
    valor_periodo_plan(AnioPlan, Cuatrimestre, M),
    Valor is N*1 + M*0.

valor_periodo_plan(AnioPlan, Cuatrimestre, Valor) :-
    nonvar(Cuatrimestre),
    ultimo_anio_plan(UltimoAnioPlan),
    Valor is (UltimoAnioPlan - AnioPlan)*2 + Cuatrimestre + 1.

valor_periodo_plan(AnioPlan, Cuatrimestre, Valor) :-
    var(Cuatrimestre),
    ultimo_anio_plan(UltimoAnioPlan),
    Valor is (UltimoAnioPlan - AnioPlan)*2 + 1.

desbloqueos_transitivos([], []) :- !.

desbloqueos_transitivos(Lista, Resultado) :-
    expandir_lista(Lista, ExpansionSiguiente),
    desbloqueos_transitivos(ExpansionSiguiente, ResultadoParcial),
    append(Lista, ResultadoParcial, X),
    list_to_set(X, Resultado).

expandir_lista([], []) :- !.

expandir_lista([EstadoAsignatura|Resto], Resultado) :-
    expandir(EstadoAsignatura, Expansion),
    expandir_lista(Resto, RestoExpansion),
    append(Expansion, RestoExpansion, X),
    list_to_set(X, Resultado).

expandir(estado_asignatura(C1, E1), Expansion) :-
    findall(estado_asignatura(C2, E2), requisito(E2, C2, requiere(E1, C1)), Expansion).


% STARTHERE acá hay un problemon de separacion
/*

*/
puede_avanzar(Codigo, NuevoEstado, Cuatrimestre, Carga, EstadosAsignaturas) :-
    asignatura(Codigo, Tipo, _, periodo_plan(_, Cuatrimestre)),
    (
        Tipo = materia, NuevoEstado = cursada;
        Tipo = curso, NuevoEstado = aprobada
    ),
    member(estado_asignatura(Codigo, EstadoActual), EstadosAsignaturas),
    siguiente_estado_tipo_asignatura(Tipo, EstadoActual, NuevoEstado, Carga),
    verificar_requisitos_para(estado_asignatura(Codigo, NuevoEstado), EstadosAsignaturas).

puede_avanzar(Codigo, NuevoEstado, _, Carga, EstadosAsignaturas) :-
    asignatura(Codigo, Tipo, _, _),
    member(estado_asignatura(Codigo, EstadoActual), EstadosAsignaturas),
    siguiente_estado_tipo_asignatura(Tipo, EstadoActual, NuevoEstado, Carga),
    verificar_requisitos_para(estado_asignatura(Codigo, NuevoEstado), EstadosAsignaturas).

puede_avanzar(Codigo, NuevoEstado, Cuatrimestre, Carga, EstadosAsignaturas) :-
    asignatura(Codigo, Tipo, _, periodo_plan(_, Cuatrimestre)),
    \+ (member(estado_asignatura(Codigo, _), EstadosAsignaturas)),
    siguiente_estado_tipo_asignatura(Tipo, sin_iniciar, NuevoEstado, Carga),
    verificar_requisitos_para(estado_asignatura(Codigo, NuevoEstado), EstadosAsignaturas).

avances_posibles(
    estado(EstadosAsignaturas, proximo_periodo_calendario(_, Cuatrimestre)),
    AvancesAsignaturasPosibles
) :-
    findall(avance(estado_asignatura(Codigo, NuevoEstado), Valor, Carga), 
    (
        puede_avanzar(Codigo, NuevoEstado, Cuatrimestre, Carga, EstadosAsignaturas),
        valor(estado_asignatura(Codigo, NuevoEstado), Valor)
    ), AvancesAsignaturasPosibles).




% =========== ALGORITMO DE BÚSQUEDA ================


% UTILIDADES
reemplazar_estados(Original, Reemplazos, Resultado) :-
    foldl(reemplazar_estado, Reemplazos, Original, Resultado).
reemplazar_estado(estado_asignatura(Codigo, NuevoEstado), Lista, Resultado) :-
    select(estado_asignatura(Codigo, _), Lista, Resto),
    !,
    Resultado = [estado_asignatura(Codigo, NuevoEstado)|Resto].
reemplazar_estado(Estado, Lista, [Estado|Lista]).

% 1. Caso base
ordenar_avances([], []).

% 2. Caso recursivo
ordenar_avances([X|Xs], Ordenada) :-
    ordenar_avances(Xs, RestoOrdenado),
    insertar(X, RestoOrdenado, Ordenada).

% --- Lógica de inserción limpia ---
insertar(X, [], [X]).

% Si el valor es mayor o igual, va primero
insertar(avance(IdX, ValX, CX), [avance(IdY, ValY, CY)|Resto], [avance(IdX, ValX, CX), avance(IdY, ValY, CY)|Resto]) :-
    ValX >= ValY.

% Si es menor, saltamos al siguiente elemento
insertar(avance(IdX, ValX, CX), [avance(IdY, ValY, CY)|Resto], [avance(IdY, ValY, CY)|Resultado]) :-
    ValX < ValY,
    insertar(avance(IdX, ValX, CX), Resto, Resultado).

seleccionar_avances([], _, []).
seleccionar_avances([avance(X, Valor, Carga)|RestoAvances], CargaMaxima, [avance(X, Valor, Carga)|Seleccionados]) :-
    Carga =< CargaMaxima,
    NuevaCargaMaxima is CargaMaxima - Carga,
    seleccionar_avances(RestoAvances, NuevaCargaMaxima, Seleccionados).
seleccionar_avances([avance(_, _, Carga)|RestoAvances], CargaMaxima, Seleccionados) :-
    Carga > CargaMaxima,
    seleccionar_avances(RestoAvances, CargaMaxima, Seleccionados).


% ALGORITMO DE BÚSQUEDA
% Esto debe venir del input del usuario
estado_inicial(estado([], proximo_periodo_calendario(2023, 1))).

estado(estado(EstadosAsignaturas, proximo_periodo_calendario(_, _))) :-
    forall(member(estado_asignatura(Codigo, Estado), EstadosAsignaturas), (
        asignatura(Codigo, Tipo, _, _),
        estado_tipo_asignatura(Tipo, Estado),
        verificar_requisitos_para(estado_asignatura(Codigo, Estado), EstadosAsignaturas))
    ).

estado_final(estado(EstadosAsignaturas, proximo_periodo_calendario(_, _))) :-
    findall(estado_asignatura(Codigo, aprobada), asignatura(Codigo, _, _, _), EstadosAsignaturas).

transicion(
    estado(EstadosAsignaturasA, proximo_periodo_calendario(AnioA, CuatrimestreA)),
    CapacidadCarga,
    AvancesElegidos,
    estado(EstadosAsignaturasB, proximo_periodo_calendario(AnioB, CuatrimestreB))
) :-
    % Elegir los mejores avances posibles dentro de la capacidad de carga del alumno
    avances_posibles(
        estado(EstadosAsignaturasA, proximo_periodo_calendario(AnioA, CuatrimestreA)),
        AvancesPosibles
    ),
    %mostrar_avances(AvancesPosibles),
    ordenar_avances(AvancesPosibles, AvancesPosiblesOrdenados),
    seleccionar_avances(AvancesPosiblesOrdenados, CapacidadCarga, AvancesElegidos),

    % Generar el nuevo estado
    findall(Estado, member(avance(Estado, _, _), AvancesElegidos), NuevosEstadosAsignaturas),
    reemplazar_estados(EstadosAsignaturasA, NuevosEstadosAsignaturas, EstadosAsignaturasB),
    siguiente_periodo_calendario(AnioA, CuatrimestreA, AnioB, CuatrimestreB).


depth_limited_search(Profundidad) :-
    estado_inicial(EstadoInicial),
    %mostrar_estado(EstadoInicial),
    depth_limited_search([], [], EstadoInicial, Profundidad, SolucionEstados, SolucionAvances),
    length(SolucionAvances, Contador).
    %mostrar_solucion(SolucionAvances, SolucionEstados, Contador).

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, _, [EstadoOrigen|EstadosCamino], AvancesCamino) :- 
    EstadoOrigen = estado(EstadosAsignaturasOrigen, _),
    estado_final(estado(EstadosAsignaturasFinal, _)),
    mismos_elementos(EstadosAsignaturasOrigen, EstadosAsignaturasFinal).

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, Profundidad, SolucionEstados, SolucionAvances) :-
    Profundidad > 0,
    transicion(EstadoOrigen, 25, AvancesElegidos, EstadoDestino),
    \+ member(EstadoDestino, EstadosCamino),
    ProfundidadNueva is Profundidad - 1,
    %mostrar_avances(AvancesElegidos),
    %mostrar_estado(EstadoDestino),
    depth_limited_search([EstadoOrigen|EstadosCamino], [AvancesElegidos|AvancesCamino], EstadoDestino, ProfundidadNueva, SolucionEstados, SolucionAvances).


% --- Predicados auxiliares eficientes ---
mismos_elementos(Lista1, Lista2) :-
    length(Lista1, Largo),
    length(Lista2, Largo), % Tienen que medir lo mismo
    todos_miembros(Lista1, Lista2).

% Verifica que cada elemento de la primera lista esté en la segunda
todos_miembros([], _).
todos_miembros([X|Xs], Lista2) :-
    member(X, Lista2),
    todos_miembros(Xs, Lista2).
/*
mostrar_solucion([AvancesElegidos|RestoAvances], [Estado|RestoEstados], Contador) :-
    NuevoContador is Contador - 1,
    mostrar_solucion(RestoAvances, RestoEstados, NuevoContador),
    mostrar_avances(AvancesElegidos),
    writeln(''),
    format('  ESTADO N.° ~w ~n', [Contador]),
    writeln('|---------------------------------|'),
    mostrar_estado(Estado),
    writeln('|---------------------------------|'),
    writeln('').
*/
/*
mostrar_avances(AvancesElegidos) :-
    write('Avance:\n'),
    forall(member(avance(estado_asignatura(Codigo, Estado), Valor, Carga), AvancesElegidos), (
        asignatura(Codigo, _, Nombre, _),
        format('[~w](~dp, ~dc) ~w      ~w        ~n', [Codigo, Valor, Carga, Estado, Nombre])
    )).

mostrar_estado(estado(EstadosAsignaturas, proximo_periodo_calendario(AnioCalendario, Cuatrimestre))) :-
    write('Estado:\n'),
    forall(member(estado_asignatura(Codigo, Estado), EstadosAsignaturas), (
        asignatura(Codigo, _, Nombre, _),
        format('[~w] ~w      ~w ~n', [Codigo, Estado, Nombre])
    )),
    format('Próximo periodo: ~d ~d° cuatrimestre~n~n', [AnioCalendario, Cuatrimestre]).
*/



/*

transicion(
    estado([
        estado_asignatura('MA045', aprobada), 
        estado_asignatura('MA046', aprobada),
        estado_asignatura('MA008', aprobada),
        estado_asignatura('IF001', aprobada),
        estado_asignatura('IF002', aprobada),
        estado_asignatura('IF003', aprobada),
        estado_asignatura('FA007', aprobada)
    ], proximo_periodo_calendario(2024, 1)),
    10,
    AvancesElegidos,
    estado(EstadosAsignaturasB, proximo_periodo_calendario(AnioB, CuatrimestreB))
).

% el algoritmo seria un depth limited? cual seria el estado final si lo hago parametrizable?
% si la entrada es el estado actual + parametros que limitan las transiciones, 

*/
