

% =========== INPUT: HECHOS SOBRE EL ALUMNO ================

:- dynamic estado_inicial/1.
:- dynamic optativa_elegida_i/1.
:- dynamic optativa_elegida_ii/1.

% =========== INPUT: PLAN DE ESTUDIOS ================

% PERIODOS
:- dynamic ultimo_anio_plan/1. % ulitmo_anio_plan(AnioPlan).
:- dynamic estado_tipo_asignatura/2. % estado_tipo_asignatura(TipoAsignatura, EstadoAsignatura).
:- dynamic siguiente_estado_tipo_asignatura/4. % siguiente_estado_tipo_asignatura(Tipo, EstadoInicial, EstadoSiguiente, Carga).
:- dynamic asignatura/4. % asignatura(Codigo, Tipo, Nombre, periodo_plan(AnioPlan, Cuatrimestre)).
:- dynamic requisito/2. % requisito(EstadoAsignatura, requiere(Requisito)).
:- dynamic cumple_requisito/2. 


% =========== INFERENCIAS ================

% HEURÍSTICA
valor_heuristico_total(estado_asignatura(Codigo, Estado), ValorHeuristico) :-
    asignatura(Codigo, _, _, periodo_plan(AnioPlan, Cuatrimestre)),
    valor_heuristico(estado_asignatura(Codigo, Estado), X),
    valor_heuristico(periodo_plan(AnioPlan, Cuatrimestre), Y),
    ValorHeuristico is X*1 + Y*1.

valor_heuristico(estado_asignatura(Codigo, Estado), ValorHeuristico) :-
    desbloquea_estados_asignaturas_recursivo([estado_asignatura(Codigo, Estado)], EstadosAsignaturas),
    length(EstadosAsignaturas, ValorHeuristico).

valor_heuristico(periodo_plan(AnioPlan, Cuatrimestre), ValorHeuristico) :-
    nonvar(Cuatrimestre),
    ultimo_anio_plan(UltimoAnioPlan),
    ValorMaximo is UltimoAnioPlan * 2,
    ValorHeuristico is ValorMaximo - (AnioPlan - 1) * 2 - (Cuatrimestre - 1).

valor_heuristico(periodo_plan(AnioPlan, Cuatrimestre), ValorHeuristico) :-
    var(Cuatrimestre),
    ultimo_anio_plan(UltimoAnioPlan),
    ValorMaximo is UltimoAnioPlan * 2,
    ValorHeuristico is ValorMaximo - (AnioPlan - 1) * 2.

desbloquea_estados_asignaturas_recursivo([], []) :- !.

desbloquea_estados_asignaturas_recursivo(Lista, Resultado) :-
    desbloquea_estados_asignaturas(Lista, DesbloqueosSiguientes),
    desbloquea_estados_asignaturas_recursivo(DesbloqueosSiguientes, ResultadoParcial),
    append(Lista, ResultadoParcial, X),
    list_to_set(X, Resultado).

desbloquea_estados_asignaturas(estado_asignatura(C1, E1), Desbloqueos) :-
    findall(estado_asignatura(C2, E2), requisito(estado_asignatura(C2, E2), requiere(estado_asignatura(C1, E1))), Desbloqueos).

desbloquea_estados_asignaturas([], []) :- !.

desbloquea_estados_asignaturas([EstadoAsignatura|Resto], Resultado) :-
    desbloquea_estados_asignaturas(EstadoAsignatura, Desbloqueos),
    desbloquea_estados_asignaturas(Resto, RestoExpansion),
    append(Desbloqueos, RestoExpansion, X),
    list_to_set(X, Resultado).




% CUMPLIMIENTO DE REQUISITOS
% Solo validan, no son generativos
cumple_requisitos(_, []).
cumple_requisitos(EstadosAsignaturas, [Requisito|RestoRequisitos]) :-
    cumple_requisito(EstadosAsignaturas, Requisito),
    cumple_requisitos(EstadosAsignaturas, RestoRequisitos).

verificar_requisitos(EstadosAsignaturas, estado_asignatura(Codigo, EstadoDeseado)) :-
    findall(Requisito, requisito(estado_asignatura(Codigo, EstadoDeseado), requiere(Requisito)), ListaRequisitos),
    cumple_requisitos(EstadosAsignaturas, ListaRequisitos).


% CALCULO DE AVANCES
% Auxiliar para generar un avance para una asignatura
avance_asignatura_aux(EstadosAsignaturas, Codigo, Tipo, EstadoActual, avance_asignatura(estado_asignatura(Codigo, NuevoEstado), ValorHeuristico, Carga)) :-
    siguiente_estado_tipo_asignatura(Tipo, EstadoActual, NuevoEstado, Carga),
    verificar_requisitos(EstadosAsignaturas, estado_asignatura(Codigo, NuevoEstado)),
    valor_heuristico_total(estado_asignatura(Codigo, NuevoEstado), ValorHeuristico).

% Genera el avance posible para una asignatura en base a la lista de estados de asignaturas
% El cuatrimestre importa o no dependiendo del tipo de asignatura y el estado a lograr
avance_asignatura_posible(EstadosAsignaturas, _, AvanceAsignatura) :-
    asignatura(Codigo, Tipo, _, _),
    member(estado_asignatura(Codigo, EstadoActual), EstadosAsignaturas),
    avance_asignatura_aux(EstadosAsignaturas, Codigo, Tipo, EstadoActual, AvanceAsignatura).

avance_asignatura_posible(EstadosAsignaturas, _, AvanceAsignatura) :-
    asignatura(Codigo, Tipo, _, _),
    \+ (member(estado_asignatura(Codigo, _), EstadosAsignaturas)),
    Tipo = tesina,
    avance_asignatura_aux(EstadosAsignaturas, Codigo, Tipo, sin_iniciar, AvanceAsignatura).

avance_asignatura_posible(EstadosAsignaturas, Cuatrimestre, AvanceAsignatura) :-
    asignatura(Codigo, Tipo, _, periodo_plan(_, Cuatrimestre)),
    \+ (member(estado_asignatura(Codigo, _), EstadosAsignaturas)),
    Tipo \= tesina,
    avance_asignatura_aux(EstadosAsignaturas, Codigo, Tipo, sin_iniciar, AvanceAsignatura).

avance_periodo_posible(
    estado_alumno(EstadosAsignaturas, proximo_periodo_calendario(_, Cuatrimestre), _),
    avance_periodo(AvancesAsignaturasPosibles, periodo_calendario(_, Cuatrimestre))
) :-
    findall(
        AvanceAsignatura, 
        avance_asignatura_posible(EstadosAsignaturas, Cuatrimestre, AvanceAsignatura), 
        AvancesAsignaturasPosibles
    ).



% UTILIDADES PARA ALGORITMO DE BÚSQUEDA
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
insertar(avance_asignatura(IdX, ValX, CX), [avance_asignatura(IdY, ValY, CY)|Resto], [avance_asignatura(IdX, ValX, CX), avance_asignatura(IdY, ValY, CY)|Resto]) :-
    ValX >= ValY.
insertar(avance_asignatura(IdX, ValX, CX), [avance_asignatura(IdY, ValY, CY)|Resto], [avance_asignatura(IdY, ValY, CY)|Resultado]) :-
    ValX < ValY,
    insertar(avance_asignatura(IdX, ValX, CX), Resto, Resultado).

seleccionar_avances([], _, []).
seleccionar_avances([avance_asignatura(X, ValorHeuristico, Carga)|RestoAvances], CargaMaxima, [avance_asignatura(X, ValorHeuristico, Carga)|Seleccionados]) :-
    Carga =< CargaMaxima,
    NuevaCargaMaxima is CargaMaxima - Carga,
    seleccionar_avances(RestoAvances, NuevaCargaMaxima, Seleccionados).
seleccionar_avances([avance_asignatura(_, _, Carga)|RestoAvances], CargaMaxima, Seleccionados) :-
    Carga > CargaMaxima,
    seleccionar_avances(RestoAvances, CargaMaxima, Seleccionados).




% ALGORITMO DE BÚSQUEDA
% el estado_inicial(Estado) se obtiene de la información que ingrese el alumno

estado_intermedio(estado_alumno(EstadosAsignaturas, _, _)) :-
    forall(member(estado_asignatura(Codigo, Estado), EstadosAsignaturas), (
        asignatura(Codigo, Tipo, _, _),
        estado_tipo_asignatura(Tipo, Estado),
        verificar_requisitos(estado_asignatura(Codigo, Estado), EstadosAsignaturas))
    ).

estado_final(estado_alumno(EstadosAsignaturas, _, _)) :-
    findall(estado_asignatura(Codigo, aprobada), asignatura(Codigo, _, _, _), EstadosAsignaturas).

transicion(
    estado_alumno(EstadosAsignaturasA, proximo_periodo_calendario(AnioA, CuatrimestreA), capacidad_carga(CapacidadCarga)),
    avance_periodo(AvancesAsignaturasElegidos, periodo_calendario(AnioA, CuatrimestreA)),
    estado_alumno(EstadosAsignaturasB, proximo_periodo_calendario(AnioB, CuatrimestreB), capacidad_carga(CapacidadCarga))
) :-
    % Elegir los mejores avances posibles dentro de la capacidad de carga del alumno
    avance_periodo_posible(
        estado_alumno(EstadosAsignaturasA, proximo_periodo_calendario(AnioA, CuatrimestreA), _),
        avance_periodo(AvancesAsignaturasPosibles, periodo_calendario(AnioA, CuatrimestreA))
    ),
    ordenar_avances_por_heuristica(AvancesAsignaturasPosibles, AvancesAsignaturasPosiblesOrdenados),
    seleccionar_avances(AvancesAsignaturasPosiblesOrdenados, CapacidadCarga, AvancesAsignaturasElegidos),

    % Generar el nuevo estado
    findall(EstadoAsignatura, member(avance_asignatura(EstadoAsignatura, _, _), AvancesAsignaturasElegidos), NuevosEstadosAsignaturas),
    reemplazar_estados(EstadosAsignaturasA, NuevosEstadosAsignaturas, EstadosAsignaturasB),
    siguiente_periodo_calendario(AnioA, CuatrimestreA, AnioB, CuatrimestreB).

iterative_deepening(SolucionAvances) :-
    iterative_deepening(0, SolucionAvances).

iterative_deepening(Profundidad, SolucionAvances) :-
    depth_limited_search(Profundidad, _, SolucionAvances).

iterative_deepening(Profundidad, SolucionAvances) :-
    NuevaProfundidad is Profundidad + 1,
    iterative_deepening(NuevaProfundidad, SolucionAvances).

depth_limited_search(Profundidad, SolucionEstados, SolucionAvances) :-
    estado_inicial(EstadoInicial),
    depth_limited_search([], [], EstadoInicial, Profundidad, SolucionEstados, SolucionAvances).

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, _, [EstadoOrigen|EstadosCamino], AvancesCamino) :- 
    EstadoOrigen = estado_alumno(EstadosAsignaturasOrigen, _, _),
    estado_final(estado_alumno(EstadosAsignaturasFinal, _, _)),
    sort(EstadosAsignaturasOrigen, A),
    sort(EstadosAsignaturasFinal, B),
    A = B.

depth_limited_search(EstadosCamino, AvancesCamino, EstadoOrigen, Profundidad, SolucionEstados, SolucionAvances) :-
    Profundidad > 0,
    transicion(EstadoOrigen, AvancesElegidos, EstadoDestino),
    \+ member(EstadoDestino, EstadosCamino),
    ProfundidadNueva is Profundidad - 1,
    depth_limited_search([EstadoOrigen|EstadosCamino], [AvancesElegidos|AvancesCamino], EstadoDestino, ProfundidadNueva, SolucionEstados, SolucionAvances).
