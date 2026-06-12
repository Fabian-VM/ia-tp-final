% Validaciones a agregar durante el cargado de lo del alumno
% - Lo que está cursando debe estar acorde al cuatrimestre actual, y se debe normalizar a "cursada" 
%   en el estado inicial, y el cuatrimestre +1 para siguiente cuatrimestre

capacidad_carga_alumno(25).
proximo_periodo_plan_alumno(2023, 1).
estados_asignaturas_alumno([
    estado_asignatura('IF001',cursada),
    estado_asignatura('IF002',cursada),
    estado_asignatura('FA007',aprobada)
]).
optativa_elegida_i('IF024').
optativa_elegida_ii('IF028').
