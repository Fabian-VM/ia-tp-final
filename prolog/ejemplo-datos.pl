
% ESTE ARCHIVO MUESTRA UN EJEMPLO DE CÓMO LA INFORMACIÓN DEL 
% ALUMNO DEBERÍA SER CARGADO A PROLOG

estado_inicial(estado_alumno(
    [
        estado_asignatura('IF001',cursada),
        estado_asignatura('IF002',cursada),
        estado_asignatura('FA007',aprobada)
    ],
    proximo_periodo_calendario(2023, 1),
    capacidad_carga(25)
)).

optativa_elegida_i('IF024').
optativa_elegida_ii('IF028').
