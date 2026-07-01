
% ESTE ARCHIVO REPRESENTA LA INFORMACIÓN QUE INGRESARÁ EL ALUMNO

% Validaciones a agregar durante el cargado de lo del alumno
% - Lo que está cursando debe estar acorde al cuatrimestre actual, y se debe normalizar a "cursada" 
%   en el estado inicial, y el cuatrimestre +1 para siguiente cuatrimestre


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
