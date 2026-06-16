

% =========== INPUT: HECHOS SOBRE EL ALUMNO ================

:- dynamic capacidad_carga_alumno/1.
:- dynamic proximo_periodo_calendario_alumno/2.
:- dynamic estados_asignaturas_alumno/1.
:- dynamic optativa_elegida_i/1.
:- dynamic optativa_elegida_ii/1.

% =========== INPUT: PLAN DE ESTUDIOS ================

% PERIODOS
:- dynamic anio_plan/1. % anio_plan(AnioPlan).
:- dynamic tipo_asignatura/1.        % tipo_asignatura(TipoAsignatura).
:- dynamic estado_tipo_asignatura/2. % estado_tipo_asignatura(TipoAsignatura, EstadoAsignatura).
:- dynamic siguiente_estado_tipo_asignatura/4. % siguiente_estado_tipo_asignatura(Tipo, EstadoInicial, EstadoSiguiente, Carga).
:- dynamic asignatura/4. % asignatura(Codigo, Tipo, Nombre, periodo_plan(AnioPlan, Cuatrimestre)).
:- dynamic requisito/3. % requisito(Codigo, EstadoAsignatura, requiere(Requisito)).
:- dynamic cumple_este_requisito/2. % cumple_este_requisito(Requisito, EstadosAsignaturas).


% =========== INFERENCIAS ================


% CUMPLIMIENTO DE REQUISITOS

% HEURÍSTICA
ultimo_anio_plan(5).
valor_heuristica(estado_asignatura(Codigo, Estado), Valor) :-
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
% STARTHERE acá hay un problemon de separacion
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
        valor_heuristica(estado_asignatura(Codigo, NuevoEstado), Valor)
    ), AvancesAsignaturasPosibles).



% UTILIDADES
siguiente_periodo_calendario(AnioCalendario, 1, AnioCalendario, 2).
siguiente_periodo_calendario(AnioCalendario, 2, AnioCalendarioSiguiente, 1) :-
    AnioCalendarioSiguiente is AnioCalendario + 1.

reemplazar_estados(Original, Reemplazos, Resultado) :-
    foldl(reemplazar_estado, Reemplazos, Original, Resultado).
reemplazar_estado(estado_asignatura(Codigo, NuevoEstado), Lista, Resultado) :-
    select(estado_asignatura(Codigo, _), Lista, Resto),
    !,
    Resultado = [estado_asignatura(Codigo, NuevoEstado)|Resto].
reemplazar_estado(Estado, Lista, [Estado|Lista]).

ordenar_avances_por_heuristica([], []).
ordenar_avances_por_heuristica([X|Xs], Ordenada) :-
    ordenar_avances_por_heuristica(Xs, RestoOrdenado),
    insertar(X, RestoOrdenado, Ordenada).

insertar(X, [], [X]).
insertar(avance(IdX, ValX, CX), [avance(IdY, ValY, CY)|Resto], [avance(IdX, ValX, CX), avance(IdY, ValY, CY)|Resto]) :-
    ValX >= ValY.
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
estado_inicial(estado(EstadosAsignaturas, proximo_periodo_calendario(AnioCalendario, Cuatrimestre))) :-
    proximo_periodo_calendario_alumno(AnioCalendario, Cuatrimestre),
    estados_asignaturas_alumno(EstadosAsignaturas).

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
    ordenar_avances_por_heuristica(AvancesPosibles, AvancesPosiblesOrdenados),
    seleccionar_avances(AvancesPosiblesOrdenados, CapacidadCarga, AvancesElegidos),

    % Generar el nuevo estado
    findall(Estado, member(avance(Estado, _, _), AvancesElegidos), NuevosEstadosAsignaturas),
    reemplazar_estados(EstadosAsignaturasA, NuevosEstadosAsignaturas, EstadosAsignaturasB),
    siguiente_periodo_calendario(AnioA, CuatrimestreA, AnioB, CuatrimestreB).

iterative_deepening(SolucionAvances) :-
    % Empezamos buscando desde profundidad 0
    iterative_deepening(0, SolucionAvances).

iterative_deepening(Profundidad, SolucionAvances) :-
    depth_limited_search(Profundidad, _, SolucionAvances).

iterative_deepening(Profundidad, SolucionAvances) :-
    NuevaProfundidad is Profundidad + 1,
    iterative_deepening(NuevaProfundidad, SolucionAvances).

depth_limited_search(Profundidad, SolucionEstados, SolucionAvances) :-
    estado_inicial(EstadoInicial),
    %mostrar_estado(EstadoInicial),
    depth_limited_search([], [], EstadoInicial, Profundidad, SolucionEstados, SolucionAvances).
    %length(SolucionAvances, Contador).
    %mostrar_solucion(SolucionAvances, SolucionEstados, Contador).

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, _, [EstadoOrigen|EstadosCamino], AvancesCamino) :- 
    EstadoOrigen = estado(EstadosAsignaturasOrigen, _),
    estado_final(estado(EstadosAsignaturasFinal, _)),
    sort(EstadosAsignaturasOrigen, A),
    sort(EstadosAsignaturasFinal, B),
    A = B.

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, Profundidad, SolucionEstados, SolucionAvances) :-
    Profundidad > 0,
    capacidad_carga_alumno(CapacidadCarga),
    transicion(EstadoOrigen, CapacidadCarga, AvancesElegidos, EstadoDestino),
    \+ member(EstadoDestino, EstadosCamino),
    ProfundidadNueva is Profundidad - 1,
    %mostrar_avances(AvancesElegidos),
    %mostrar_estado(EstadoDestino),
    depth_limited_search([EstadoOrigen|EstadosCamino], [AvancesElegidos|AvancesCamino], EstadoDestino, ProfundidadNueva, SolucionEstados, SolucionAvances).
