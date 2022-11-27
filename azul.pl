:-dynamic
    jugador_inicial/1,
    bolsa/1,
    numero_de_fabricas/1,
    tapa/1,
    filas_completas/2,
    columnas_completas/2,
    cant_de_ronda/1,
    ronda_acabada/1,
    puntuacion_optima/1,
    muro/3,
    jugada_optima/3,
    area_de_preparacion/4,
    puntuacion/2,
    fabrica/2,
    centro/1,
    cant_de_jugadores/1,
    suelo/2,
    jugador_actual/1,
    partida_acabada/1,
    posible_jugada/4,
    min_area/1.

%definicion de los azulejos
color(-1,none).
color(0,negro).
color(1,azul).
color(2,amarillo).
color(3,rojo).
color(4,celeste).

%cantidad de fabricas por jugadores
cant_fabricas(2,5).
cant_fabricas(3,7).
cant_fabricas(4,9).

%definicion de vectores de movimiento
vX([-1,1,0,0]). %coordenada X para movimiento horizontal y vertical
vY([0,0,-1,1]). %coordenada Y para movimiento horizontal y vertical

%el color en el muro para fila y columna
color_muro(1, 0, 0):-!.
color_muro(2, 0, 1):-!.
color_muro(3, 0, 2):-!.
color_muro(0, 0, 3):-!.
color_muro(4, 0, 4):-!.
color_muro(Color, Fila, Columna):-
    color_muro(Color, 0, Columna0),!,
    Posicion is Columna0 + Fila, Columna is mod(Posicion, 5).

%inicializando variables dinamicas
inicializa(C):-
    random(0,C,R),
    asserta(jugador_inicial(R)),
    asserta(cant_de_jugadores(C)),
    asserta(jugador_actual(R)),
    %inicilizando bolsa
    asserta(bolsa([20,20,20,20,20])),
    %inicializando tapa
    asserta(tapa([0,0,0,0,0])),
    %inicializando centro
    asserta(centro([0,0,0,0,0])),
    asserta(puntuacion_optima(-15)),
    asserta(jugada_optima(-1,-1,-1)),
    asserta(cant_de_ronda(0)),
    asserta(min_area(100)),
    asserta(partida_acabada(0)),
    asserta(ronda_acabada(0)),
    %inicializando tablero
    C1 is C - 1,
    inicializar_tablero_jugadores(C1),
    cant_fabricas(C,F),
    asserta(numero_de_fabricas(F)),
    %inicializando fabricas
    inicializar_fabrica(F),!.

%rellenar muros
inicializar_tablero_jugadores(-1):-!.
inicializar_tablero_jugadores(J):-
    %inicializando suelos
    asserta(suelo(J,0)),
    %inicializando puntuacion
    asserta(puntuacion(J,0)),
    %inicializando cantidad de columnas y de filas completadas por cada jugador
    asserta(filas_completas(J,0)),
    asserta(columnas_completas(J,0)),
    rellenar_por_fila(J, 4),
    J1 is J - 1,
    inicializar_tablero_jugadores(J1),!.

rellenar_por_fila(_,-1):-!.
rellenar_por_fila(J,F):-
    %inicializando muros
    asserta(muro(J,F,[-1,-1,-1,-1,-1])),
    %inicializando area de preparacion
    %Jugador, Fila, Cantidad, AzulejoPuesto
    asserta(area_de_preparacion(J,F,0,-1)),
    F1 is F - 1,
    rellenar_por_fila(J, F1),!.

%inicializando fabricas
inicializar_fabrica(0):-!.
inicializar_fabrica(N):-
    N1 is N - 1,
    asserta(fabrica(N1,[0,0,0,0,0])),
    inicializar_fabrica(N1).

rellenar_fabricas(0):-!.
rellenar_fabricas(C):-
    N is C-1,
    rellena_fabrica(N,4),
    rellenar_fabricas(N).

rellena_fabrica(_,0):-!.
rellena_fabrica(I,C):-
    obtener_ficha(-1,Ficha),
    actualiza_bolsa(Ficha,-1),
    actualiza_fabrica(I,Ficha,1),
    N is C-1,
    rellena_fabrica(I,N).

obtener_ficha(R,Ficha):- R>=0,bolsa(B),nth0(R,B,Z),Z>0,Ficha is R,!.
obtener_ficha(_,Ficha):- random(0,5,P),obtener_ficha(P,Ficha).

%preparar ronda
preparar_ronda(Stream):-
    numero_de_fabricas(Cant_f),
    bolsa(Z),
    cant_de_azulejos(Z,Total),
    rellenar_bolsa(Total),
    write(Stream,"Accion: Bolsa Rellenada\n"),
    rellenar_fabricas(Cant_f),
    write(Stream,"Accion: Fabricas Rellenadas\n"),
    print_fabricas_y_centro(Stream),
    jugador_inicial(J),
    retract(jugador_actual(_)),
    asserta(jugador_actual(J)),
    retract(jugador_inicial(_)),
    asserta(jugador_inicial(-1)),
    write(Stream,"Jugador Inicial: "),write(Stream,J),
    write(Stream,"\n"),write(Stream,"\n"),
    cant_de_jugadores(CJ),
    write_tablero_iterador(CJ,Stream),
    retract(ronda_acabada(_)),
    asserta(ronda_acabada(0)).

print_fabricas_y_centro(Stream):-
    numero_de_fabricas(Cantf),
    print_fabricas_y_centro_pv(Cantf,Stream).
print_fabricas_y_centro_pv(0,Stream):-
    centro(C),
    write(Stream,"Centro "), writeColor(C,Stream),write(Stream,"\n"),!.
print_fabricas_y_centro_pv(CantF,Stream):-
    F is CantF - 1, fabrica(F,F0),
    write(Stream,"Fabrica "), write(Stream,CantF), write(Stream,": "), writeColor(F0,Stream),
    write(Stream,"\n"),print_fabricas_y_centro_pv(F,Stream).

writeColor([C1,C2,C3,C4,C5],Stream):-
    color(0,CC1), write(Stream,CC1), write(Stream,":"), write(Stream,C1), write(Stream," "),
    color(1,CC2), write(Stream,CC2), write(Stream,":"), write(Stream,C2), write(Stream," "),
    color(2,CC3), write(Stream,CC3), write(Stream,":"), write(Stream,C3), write(Stream," "),
    color(3,CC4), write(Stream,CC4), write(Stream,":"), write(Stream,C4), write(Stream," "),
    color(4,CC5), write(Stream,CC5), write(Stream,":"), write(Stream,C5).

%si la cantidad de fichas en la bolsa es menor que las necesarias para rellenar las
%fabricas pasa todas las fichas de la tapa de la caja para la bolsa
rellenar_bolsa(Cant_en_bolsa):-
    numero_de_fabricas(Z),
    R is Z*4,
    Cant_en_bolsa < R,
    vaciar_tapa(0),!.
rellenar_bolsa(_):-!.

%pasar los azulejos de la tapa a la bolsa
vaciar_tapa(5):-!.
vaciar_tapa(Azulejo):-
    tapa(Z),
    nth0(Azulejo,Z,Cant),
    actualiza_bolsa(Azulejo,Cant),
    CantNuevo is Cant * (-1),
    actualiza_tapa(Azulejo,CantNuevo),
    N is Azulejo + 1,
    vaciar_tapa(N).

%cantidad de azulejos en la bolsa
cant_de_azulejos([],0):-!.
cant_de_azulejos([X|Y],Total):-
    cant_de_azulejos(Y,N),
    Total is X+N.

%indexando en un muro
indexer(Jugador,I,J,Azulejo):-
    muro(Jugador,I,Fila),
    nth0(J,Fila,Azulejo).

%actualizando jugador actual
actualiza_jugador_actual(P):-
    jugador_actual(Z),
    retract(jugador_actual(Z)),
    cant_de_jugadores(N),
    P is (Z+1) mod N,
    asserta(jugador_actual(P)).

%actualizando muro
actualiza_muro(P,I,0,C):- retract(muro(P,I,[_|Y])),asserta(muro(P,I,[C|Y])),!.
actualiza_muro(P,I,1,C):- retract(muro(P,I,[X1,_|Y])),asserta(muro(P,I,[X1,C|Y])),!.
actualiza_muro(P,I,2,C):- retract(muro(P,I,[X1,X2,_|Y])),asserta(muro(P,I,[X1,X2,C|Y])),!.
actualiza_muro(P,I,3,C):- retract(muro(P,I,[X1,X2,X3,_|Y])),asserta(muro(P,I,[X1,X2,X3,C|Y])),!.
actualiza_muro(P,I,4,C):- retract(muro(P,I,[X1,X2,X3,X4,_])),asserta(muro(P,I,[X1,X2,X3,X4,C])),!.

%dada una posicion I,J determina cual es la puntuacion que se le debe
%sumar al jugador si coloca un azulejo en dicha posicion
puntuacion(Jugador,I,J,Puntuacion,Right,Down,Up,Left):-
    linea(Jugador,I,J,0,Up),
    linea(Jugador,I,J,3,Right),
    linea(Jugador,I,J,1,Down),
    linea(Jugador,I,J,2,Left),
    suma_final(Up,Right,Down,Left,N),
    Puntuacion is Up+Right+Down+Left+N.

%determina la cantidad de azulejos adyacentes que hay en el muro de un
%jugador en una direccion determinada, comenzando desde una casilla especificada (I,J)
linea(Jugador,I,J,_,-1):-
    (not(in_range(I,J));indexer(Jugador,I,J,-1)),!.
linea(Jugador,I,J,Direccion,R):-
    vX(Z),nth0(Direccion,Z,L1),
    vY(W),nth0(Direccion,W,L2),
    X1 is I+L1,
    Y1 is J+L2,
    linea(Jugador,X1,Y1,Direccion,P),
    R is P+1.

%determina la puntuacion que se le debe de sumar a un jugador al colocar un azulejo
%en la casilla (I,J) de su muro, dependiendo de las direcciones adyacentes a esta casilla en que haya azulejos
suma_final(U,R,D,L,1):- U=:=0,R=:=0,D=:=0,L=:=0,!.
suma_final(U,R,D,L,2):- (U>0;D>0),(R>0;L>0),!.
suma_final(U,R,D,L,1):- U>0;R>0;D>0;L>0.

%verifica si se completo una fila o una columna en el muro
actualiza_filas_completas(Jugador,Right,Left):-
    Right+Left=:=4,
    retract(filas_completas(Jugador,Current)),
    New is Current+1,
    asserta(filas_completas(Jugador,New)),!.
actualiza_filas_completas(_,_,_).

actualiza_columnas_completas(Jugador,Down,Up):-
    Down+Up=:=4,
    retract(columnas_completas(Jugador,Current)),
    New is Current+1,
    asserta(columnas_completas(Jugador,New)),!.
actualiza_columnas_completas(_,_,_).

%verifica si la fila I del area de preparacion esta completa
fila_completa(Jugador,I):-
    area_de_preparacion(Jugador,I,Cant,_),
    Cant=:=I+1.

%actualiza el valor que se le debe restar a la puntuacion de un jugador al final de la ronda
restar_suelo(0,0).
restar_suelo(1,-1).
restar_suelo(2,-2).
restar_suelo(3,-4).
restar_suelo(4,-6).
restar_suelo(5,-8).
restar_suelo(6,-11).
restar_suelo(7,-14).

%verifica si una posicion I,J esta en el rango de la matriz que
%representa el muro
in_range(I,J):-
    I>(-1),J>(-1),
    I<5,J<5.

%actualizando centro
actualiza_centro(0,C):-retract(centro([X1|Y])),N is X1+C, asserta(centro([N|Y])),!.
actualiza_centro(1,C):-retract(centro([X1,X2|Y])),N is X2+C, asserta(centro([X1,N|Y])),!.
actualiza_centro(2,C):-retract(centro([X1,X2,X3|Y])),N is X3+C, asserta(centro([X1,X2,N|Y])),!.
actualiza_centro(3,C):-retract(centro([X1,X2,X3,X4|Y])),N is X4+C, asserta(centro([X1,X2,X3,N|Y])),!.
actualiza_centro(4,C):-retract(centro([X1,X2,X3,X4,X5|Y])),N is X5+C, asserta(centro([X1,X2,X3,X4,N|Y])),!.

%actualizando tapa
actualiza_tapa(0,C):-retract(tapa([X1|Y])),N is X1+C, asserta(tapa([N|Y])),!.
actualiza_tapa(1,C):-retract(tapa([X1,X2|Y])),N is X2+C, asserta(tapa([X1,N|Y])),!.
actualiza_tapa(2,C):-retract(tapa([X1,X2,X3|Y])),N is X3+C, asserta(tapa([X1,X2,N|Y])),!.
actualiza_tapa(3,C):-retract(tapa([X1,X2,X3,X4|Y])),N is X4+C, asserta(tapa([X1,X2,X3,N|Y])),!.
actualiza_tapa(4,C):-retract(tapa([X1,X2,X3,X4,X5|Y])),N is X5+C, asserta(tapa([X1,X2,X3,X4,N|Y])),!.

%actualizando fabricas
actualiza_fabrica(I,0,C):-retract(fabrica(I,[X1|Y])),N is X1+C, asserta(fabrica(I,[N|Y])),!.
actualiza_fabrica(I,1,C):-retract(fabrica(I,[X1,X2|Y])),N is X2+C, asserta(fabrica(I,[X1,N|Y])),!.
actualiza_fabrica(I,2,C):-retract(fabrica(I,[X1,X2,X3|Y])),N is X3+C, asserta(fabrica(I,[X1,X2,N|Y])),!.
actualiza_fabrica(I,3,C):-retract(fabrica(I,[X1,X2,X3,X4|Y])),N is X4+C, asserta(fabrica(I,[X1,X2,X3,N|Y])),!.
actualiza_fabrica(I,4,C):-retract(fabrica(I,[X1,X2,X3,X4,X5|Y])),N is X5+C, asserta(fabrica(I,[X1,X2,X3,X4,N|Y])),!.

%actualizando bolsa
actualiza_bolsa(0,C):-retract(bolsa([X1|Y])),N is X1+C, asserta(bolsa([N|Y])),!.
actualiza_bolsa(1,C):-retract(bolsa([X1,X2|Y])),N is X2+C, asserta(bolsa([X1,N|Y])),!.
actualiza_bolsa(2,C):-retract(bolsa([X1,X2,X3|Y])),N is X3+C, asserta(bolsa([X1,X2,N|Y])),!.
actualiza_bolsa(3,C):-retract(bolsa([X1,X2,X3,X4|Y])),N is X4+C, asserta(bolsa([X1,X2,X3,N|Y])),!.
actualiza_bolsa(4,C):-retract(bolsa([X1,X2,X3,X4,X5|Y])),N is X5+C, asserta(bolsa([X1,X2,X3,X4,N|Y])),!.

%actualizando Suelo
agregar_al_suelo(Jugador,Cant):-
    suelo(Jugador,Cant_actual),
    Cant_actual<7,
    retract(suelo(Jugador,Cant_actual)),
    Current is Cant + Cant_actual,
    asserta(suelo(Jugador,Current)).
agregar_al_suelo(_,_):-!.

%actualizando areas de preparacion
actualiza_area_de_preparacion(I,J,C,A):-
    area_de_preparacion(I,J,X,Y),
    retract(area_de_preparacion(I,J,X,Y)),
    N is X+C,
    asserta(area_de_preparacion(I,J,N,A)).

%actualizando puntuacion
actualiza_puntuacion(I,C):-
    puntuacion(I,Z),
    retract(puntuacion(I,Z)),
    N is Z+C,
    asserta(puntuacion(I,N)).

%alicatado
alicatado():-
    cant_de_jugadores(N),
    alicatado(N).
alicatado(0):-!.
alicatado(Jugador):-
    N is Jugador-1,
    alicatado(N,0),
    alicatado(N),!.

alicatado(Jugador,5):-
    suelo(Jugador, Suelo),
    restar_suelo(Suelo, RSuelo),
    actualiza_puntuacion(Jugador,RSuelo),
    puntuacion(Jugador,N),
    Current is max(0,N),
    retract(puntuacion(Jugador,_)),
    asserta(puntuacion(Jugador,Current)),
    retract(suelo(Jugador,_)),
    asserta(suelo(Jugador,0)),!.

alicatado(Jugador,Fila):-
    area_de_preparacion(Jugador,Fila,_,Azulejo),
    Azulejo>=0,
    color_muro(Azulejo,Fila,Columna),
    fila_completa(Jugador,Fila),
    actualiza_muro(Jugador,Fila,Columna,Azulejo),
    actualiza_tapa(Azulejo,Fila),
    puntuacion(Jugador,Fila,Columna,Puntuacion,Right,Down,Up,Left),
    actualiza_puntuacion(Jugador,Puntuacion),
    actualiza_filas_completas(Jugador,Right,Left),
    actualiza_columnas_completas(Jugador,Down,Up),
    retract(area_de_preparacion(Jugador,Fila,_,_)),
    asserta(area_de_preparacion(Jugador,Fila,0,-1)),
    Next is Fila+1,
    alicatado(Jugador,Next),
    partida_finalizada(Jugador),!.

alicatado(Jugador,Fila):-
    Next is Fila+1,
    alicatado(Jugador,Next).

partida_finalizada(Jugador):-
    filas_completas(Jugador,F),
    F>0,
    retract(partida_acabada(_)),
    asserta(partida_acabada(1)),!.
partida_finalizada(_):-!.

%ejecutando rondas
ejecuta_ronda(Stream):-
    partida_acabada(1),
    cant_de_jugadores(J),
    write(Stream,"ESTADO FINAL\n"),
    write_tablero_iterador(J,Stream),
    write(Stream,"Partida Finalizada!!\n"),
    calcular_puntos_adicionales(),
    write(Stream,"PUNTUACION ADICIONAL\n"),
    write_puntuacion(J,Stream),
    determinar_ganadores(Ganadores),
    escribe_ganadores(Ganadores,Stream),
    limpia_simulacion(),
    close(Stream),!.
ejecuta_ronda(Stream):-
    cant_de_ronda(R),
    RN is R + 1,
    retract(cant_de_ronda(_)),
    asserta(cant_de_ronda(RN)),
    write(Stream,"Ronda: "),write(Stream,RN),write(Stream,"\n"),
    preparar_ronda(Stream),
    jugador_actual(Jugador),
    proxima_jugada(Jugador,Stream),
    ejecuta_ronda(Stream),
    !.
write_puntuacion(0,_):-!.
write_puntuacion(J,Stream):-
    NJugador is J - 1,
    write(Stream,"Puntuacion de Jugador "), write(Stream,NJugador),
    write(Stream," es "), puntuacion(NJugador,P),write(Stream,P),write(Stream,"\n"),
    write_puntuacion(NJugador,Stream),!.
% una vez finalizada la partida hay que realizar el conteo de puntos adicionales
calcular_puntos_adicionales():-
    cant_de_jugadores(CantJugadores),
    NJugador is CantJugadores - 1,
    calcular_puntos_adicionales_pv(NJugador).
calcular_puntos_adicionales_pv(-1):-!.
calcular_puntos_adicionales_pv(Jugador):-
    puntuacion_adicional(Jugador, PuntuacionAdicional),
    actualiza_puntuacion(Jugador, PuntuacionAdicional),
    JugadorN is Jugador - 1,
    calcular_puntos_adicionales_pv(JugadorN).
actualizar_puntuacion_adicional(Jugador, PuntuacionAdicional):-
    puntuacion(Jugador, PuntuacionActual),
    Puntuacion is PuntuacionActual + PuntuacionAdicional,
    retract(puntuacion(Jugador, PuntuacionActual)),
    asserta(puntuacion(Jugador, Puntuacion)).
puntuacion_adicional(Jugador, PuntuacionAdicional):-
    filas_completas(Jugador,PH),
    PuntosHorizontales is PH*2,
    columnas_completas(Jugador,PV),
    PuntosVerticales is PV*7,
    colores_completos(Jugador, PC),
    PuntosColores is PC*10,
    PuntuacionAdicional is PuntosHorizontales + PuntosVerticales + PuntosColores,!.
colores_completos(Jugador, Puntos):-
    colores_iguales_muro(Jugador,0, 0, Color0), comprobar_color_completado(Color0, P0),
    colores_iguales_muro(Jugador,0, 1, Color1), comprobar_color_completado(Color1, P1),
    colores_iguales_muro(Jugador,0, 2, Color2), comprobar_color_completado(Color2, P2),
    colores_iguales_muro(Jugador,0, 3, Color3), comprobar_color_completado(Color3, P3),
    colores_iguales_muro(Jugador,0, 4, Color4), comprobar_color_completado(Color4, P4),
    Puntos is P0 + P1 + P2 + P3 + P4,!.
% establece los valores del muro segun los colores iguales correspondientes
colores_iguales_muro(Jug, I0, J0, [V0, V1, V2, V3, V4]):-
    indexer(Jug, I0, J0, V0), I1 is mod(I0+1,5), J1 is mod(J0+1,5),
    indexer(Jug, I1, J1, V1), I2 is mod(I1+1,5), J2 is mod(J1+1,5),
    indexer(Jug, I2, J2, V2), I3 is mod(I2+1,5), J3 is mod(J2+1,5),
    indexer(Jug, I3, J3, V3), I4 is mod(I3+1,5), J4 is mod(J3+1,5),
    indexer(Jug, I4, J4, V4),!.
% si la lista de los valores del color i tienen todo en 1, esta completa y suma 10 ptos
comprobar_color_completado(Colores, 0):- member(-1, Colores),!.
comprobar_color_completado(_, 1):-!.
% determina el/los ganadores una vez finalizada la partida
determinar_ganadores(Ganadores):-
    cant_de_jugadores(CantJugadores),
    comprobar_puntuaciones(CantJugadores, Ganadores),!.
% para dos jugadores y un solo ganador de puntuacion maxima
comprobar_puntuaciones(2, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2),
    PuntuacionMaxima is max(P1, P2),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax1, Ganadores),
    length(Ganadores, 1),!.
% si ambos tienen las mismas puntuaciones entonces quien tenga mas filas completadas
comprobar_puntuaciones(2, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2),
    PuntuacionMaxima is max(P1, P2),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax1, JugadorPuntMaxima),
    filas_completas(1, PF1),
    filas_completas(0, PF2),
    PuntuacionFinalMaxima is max(PF1, PF2),
    actualizar_jugadores_filas_completas(1, PuntuacionFinalMaxima, JugadorPuntMaxima, [], G1),
    actualizar_jugadores_filas_completas(0, PuntuacionFinalMaxima, JugadorPuntMaxima, G1, Ganadores),
    length(Ganadores, L), L < 3,!.
% analogo para 3 jugadores
comprobar_puntuaciones(3, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2), puntuacion(2, P3),
    PuntuacionMaxima1 is max(P1, P2),
    PuntuacionMaxima is max(PuntuacionMaxima1, P3),
    actualizar_jugadores_puntuacion(2, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, JugadorPuntMax1, JugadorPuntMax2),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax2, Ganadores),
    length(Ganadores, 1),!.
comprobar_puntuaciones(3, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2), puntuacion(2, P3),
    PuntuacionMaxima1 is max(P1, P2),
    PuntuacionMaxima is max(PuntuacionMaxima1, P3),
    actualizar_jugadores_puntuacion(2, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, JugadorPuntMax1, JugadorPuntMax2),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax2, JugadorPuntMax),
    filas_completas(0, PF1),
    filas_completas(1, PF2),
    filas_completas(2, PF3),
    PuntuacionFinalMaxima1 is max(PF1, PF2),
    PuntuacionFinalMaxima is max(PuntuacionFinalMaxima1, PF3),
    actualizar_jugadores_filas_completas(2, PuntuacionFinalMaxima, JugadorPuntMax, [], G1),
    actualizar_jugadores_filas_completas(1, PuntuacionFinalMaxima, JugadorPuntMax, G1, G2),
    actualizar_jugadores_filas_completas(0, PuntuacionFinalMaxima, JugadorPuntMax, G2, Ganadores),
    length(Ganadores, L), L < 4,!.
% analogo para 4 jugadores
comprobar_puntuaciones(4, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2),
    puntuacion(2, P3), puntuacion(3, P4),
    PuntuacionMaxima1 is max(P1, P2),
    PuntuacionMaxima2 is max(PuntuacionMaxima1, P3),
    PuntuacionMaxima is max(PuntuacionMaxima2, P4),
    actualizar_jugadores_puntuacion(3, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(2, PuntuacionMaxima, JugadorPuntMax1, JugadorPuntMax2),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, JugadorPuntMax2, JugadorPuntMax3),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax3, Ganadores),
    length(Ganadores, 1),!.
comprobar_puntuaciones(4, Ganadores):-
    puntuacion(0, P1), puntuacion(1, P2),
    puntuacion(2, P3), puntuacion(3, P4),
    PuntuacionMaxima1 is max(P1, P2),
    PuntuacionMaxima2 is max(PuntuacionMaxima1, P3),
    PuntuacionMaxima is max(PuntuacionMaxima2, P4),
    actualizar_jugadores_puntuacion(3, PuntuacionMaxima, [], JugadorPuntMax1),
    actualizar_jugadores_puntuacion(2, PuntuacionMaxima, JugadorPuntMax1, JugadorPuntMax2),
    actualizar_jugadores_puntuacion(1, PuntuacionMaxima, JugadorPuntMax2, JugadorPuntMax3),
    actualizar_jugadores_puntuacion(0, PuntuacionMaxima, JugadorPuntMax3, JugadorPuntMax),
    filas_completas(0, PF1),
    filas_completas(1, PF2),
    filas_completas(2, PF3),
    filas_completas(3, PF4),
    PuntuacionFinalMaxima1 is max(PF1, PF2),
    PuntuacionFinalMaxima2 is max(PuntuacionFinalMaxima1, PF3),
    PuntuacionFinalMaxima is max(PuntuacionFinalMaxima2, PF4),
    actualizar_jugadores_filas_completas(3, PuntuacionFinalMaxima, JugadorPuntMax, [], G1),
    actualizar_jugadores_filas_completas(2, PuntuacionFinalMaxima, JugadorPuntMax, G1, G2),
    actualizar_jugadores_filas_completas(1, PuntuacionFinalMaxima, JugadorPuntMax, G2, G3),
    actualizar_jugadores_filas_completas(0, PuntuacionFinalMaxima, JugadorPuntMax, G3, Ganadores),
    length(Ganadores, L), L < 5,!.
% chequear si la puntuacion maxima coincide con la puntuacion de los jugadores
actualizar_jugadores_puntuacion(Jugador, PuntuacionMaxima, JugadoresPuntMax, [Jugador|JugadoresPuntMax]):-
    puntuacion(Jugador, PuntuacionMaxima),!.
actualizar_jugadores_puntuacion(Jugador, PuntuacionMaxima, JugadoresPuntMax, JugadoresPuntMax):-
    puntuacion(Jugador, P), P \= PuntuacionMaxima,!.
% chequear entre los jugadores empatadas quien tiene la mayor cant. filas completadas
actualizar_jugadores_filas_completas(Jugador, PuntuacionMaxima, JugadoresEmpatados, JugadoresPuntMax, [Jugador|JugadoresPuntMax]):-
    member(Jugador, JugadoresEmpatados), filas_completas(Jugador, PuntuacionMaxima),!.
actualizar_jugadores_filas_completas(Jugador, PuntuacionMaxima, JugadoresEmpatados, JugadoresPuntMax, JugadoresPuntMax):-
    member(Jugador, JugadoresEmpatados), filas_completas(Jugador, P),
    P \= PuntuacionMaxima,!.
actualizar_jugadores_filas_completas(_, _, _, JugadoresPuntMax, JugadoresPuntMax):-!.
% escribe en consola el/los ganadores de la partida
escribe_ganadores([G],Stream):-
    write(Stream,"El Ganador es: "), write(Stream,G), write(Stream,"\n"),!.
escribe_ganadores(G,Stream):-
    write(Stream,"Los Ganadores son: "), write(Stream,G), write(Stream,"\n"),!.

%ejecutando las jugadas de una ronda
proxima_jugada(_,_):-
    ronda_acabada(1),!.
proxima_jugada(Jugador,Stream):-
    juega(Jugador,Stream),
    actualiza_jugador_actual(Next),
    proxima_jugada(Next,Stream).

write_tablero_iterador(0,_):-!.
write_tablero_iterador(J,Stream):-
    JN is J - 1,
    write(Stream,"Tablero del Jugador "), write(Stream,JN),write(Stream,"\n"),
    write_tablero(JN,Stream),write(Stream,"\n"),
    write_tablero_iterador(JN,Stream).
write_tablero(J,Stream):-
    write(Stream,"Estado del Tablero del Jugador\n"),
    puntuacion(J,P0), write(Stream,"PUNTUACION: "), write(Stream,P0),write(Stream,"\n"),
    write(Stream,"============================================"),write(Stream,"\n"),
    write(Stream,"PATRONES"),write(Stream,"\n"),
    area_de_preparacion(J,0,Cant0,Color0), write(Stream,"Fila 1 "), color(Color0,Col0), write(Stream,Col0), write(Stream,":"), write(Stream,Cant0),write(Stream,"\n"),
    area_de_preparacion(J,1,Cant1,Color1), write(Stream,"Fila 2 "), color(Color1,Col1), write(Stream,Col1), write(Stream,":"), write(Stream,Cant1),write(Stream,"\n"),
    area_de_preparacion(J,2,Cant2,Color2), write(Stream,"Fila 3 "), color(Color2,Col2), write(Stream,Col2), write(Stream,":"), write(Stream,Cant2),write(Stream,"\n"),
    area_de_preparacion(J,3,Cant3,Color3), write(Stream,"Fila 4 "), color(Color3,Col3), write(Stream,Col3), write(Stream,":"), write(Stream,Cant3),write(Stream,"\n"),
    area_de_preparacion(J,4,Cant4,Color4), write(Stream,"Fila 5 "), color(Color4,Col4), write(Stream,Col4), write(Stream,":"), write(Stream,Cant4),write(Stream,"\n"),
    write(Stream,"============================================"),write(Stream,"\n"),
    write(Stream,"MURO"),write(Stream,"\n"),
    muro(J,0,M0), write(Stream,"Fila 1 "), writeColor_pv(M0,Stream),write(Stream,"\n"),
    muro(J,1,M1), write(Stream,"Fila 2 "), writeColor_pv(M1,Stream),write(Stream,"\n"),
    muro(J,2,M2), write(Stream,"Fila 3 "), writeColor_pv(M2,Stream),write(Stream,"\n"),
    muro(J,3,M3), write(Stream,"Fila 4 "), writeColor_pv(M3,Stream),write(Stream,"\n"),
    muro(J,4,M4), write(Stream,"Fila 5 "), writeColor_pv(M4,Stream),write(Stream,"\n"),
    write(Stream,"============================================"),write(Stream,"\n"),
    suelo(J,S0), write(Stream,"SUELO: "), write(Stream,S0),write(Stream,"\n"),!.

writeColor_pv([M0,M1,M2,M3,M4],Stream):-
    color(M0,C0), write(Stream,C0), write(Stream," "),
    color(M1,C1), write(Stream,C1), write(Stream," "),
    color(M2,C2), write(Stream,C2), write(Stream," "),
    color(M3,C3), write(Stream,C3), write(Stream," "),
    color(M4,C4), write(Stream,C4),!.

write_accion(Jugador,Area,Azulejo,Fila,Stream):-
    numero_de_fabricas(F), Area=:=F,Fila<5,write(Stream,"El Jugador "),write(Stream,Jugador),
    write(Stream," juega del Centro el azulejo "),color(Azulejo,Color),
    write(Stream,Color), write(Stream," al patron en la fila "), F0 is Fila+1, write(Stream,F0).
write_accion(Jugador,Area,Azulejo,Fila,Stream):-
    numero_de_fabricas(F), Area=<F,Fila<5,write(Stream,"El Jugador "),write(Stream,Jugador),
    write(Stream," juega de la Fabrica "),A is Area + 1,write(Stream,A),
    write(Stream," el azulejo "),color(Azulejo,Color),write(Stream,Color),
    write(Stream," al patron en la fila "), F0 is Fila+1, write(Stream,F0).
write_accion(Jugador,Area,Azulejo,Fila,Stream):-
    numero_de_fabricas(F), Area=:=F,Fila=:=5,write(Stream,"El Jugador "),write(Stream,Jugador),
    write(Stream," juega del Centro el azulejo "),color(Azulejo,Color),
    write(Stream,Color), write(Stream," al suelo").
write_accion(Jugador,Area,Azulejo,Fila,Stream):-
    numero_de_fabricas(F), Area=<F,Fila=:=5,write(Stream,"El Jugador "),write(Stream,Jugador),
    write(Stream," juega de la Fabrica "),A is Area + 1,write(Stream,A),
    write(Stream," el azulejo "),color(Azulejo,Color),
    write(Stream,Color),write(Stream," al suelo").

%============================== SIMULACION =================================
%simulacion del juego
simula(Num_de_jugadores):-
    open("./output.txt",write,Stream),
    write(Stream, "Inicia Simulacion\n"),
    inicializa(Num_de_jugadores),
    ejecuta_ronda(Stream).
%un jugador realiza su jugada
juega(Jugador,Stream):-
    retractall(posible_jugada(_,_,_,_)),
    retractall(jugada_optima(_,_,_)),
    retractall(puntuacion_optima(_)),
    asserta(puntuacion_optima(-15)),
    asserta(jugada_optima(-1,-1,-1)),
    genera_jugadas(Jugador),
    jugada_optima(Area,Azulejo, Fila),
    ejecuta_jugada(Jugador,Area,Azulejo, Fila,Cantidad),
    write(Stream,"Accion: Juega el Jugador "),write(Stream,Jugador),write(Stream,"\n"),
    write_accion(Jugador,Area,Azulejo,Fila,Stream),write(Stream,"\n"),
    area_de_preparacion(Jugador,Fila,Cant_en_fila,_),
    Disponible is (Fila+1)-Cant_en_fila,
    Agregar is min(Disponible,Cantidad),
    actualiza_area_de_preparacion(Jugador,Fila,Agregar,Azulejo),
    suelo(Jugador,Cant_en_suelo),
    Suelo_disponible is 7-Cant_en_suelo,
    Va_a_la_tapa is Cantidad-Agregar,
    Va_al_suelo is min(Suelo_disponible,Va_a_la_tapa),
    agregar_al_suelo(Jugador,Va_al_suelo),
    actualiza_tapa(Azulejo,Va_a_la_tapa),
    print_fabricas_y_centro(Stream),write(Stream,"\n"),
    write_tablero(Jugador,Stream),write(Stream,"\n"),write(Stream,"\n"),
    ronda_finalizada()
    ,!.
juega(Jugador,Stream):-
    retractall(min_area(_)),
    asserta(min_area(100)),
    numero_de_fabricas(N),
    itera_area(N),
    jugada_optima(Area,Azulejo,Fila),
    encuentra_ficha(Area,Azulejo,Cant),
    actualiza_tapa(Azulejo,Cant),
    ejecuta_jugada(Jugador,Area,Azulejo,_,Cant),
    write(Stream,"Accion: Juega el Jugador "),write(Stream,Jugador),write(Stream,"\n"),
    write_accion(Jugador,Area,Azulejo,Fila,Stream),write(Stream,"\n"),
    suelo(Jugador,Cant_en_suelo),
    Suelo_disponible is 7-Cant_en_suelo,
    Va_al_suelo is min(Suelo_disponible,Cant),
    agregar_al_suelo(Jugador,Va_al_suelo),
    print_fabricas_y_centro(Stream),write(Stream,"\n"),
    write_tablero(Jugador,Stream),write(Stream,"\n"),write(Stream,"\n"),
    ronda_finalizada(),!.

encuentra_ficha(Area,Azulejo,Cant):-
    numero_de_fabricas(N),
    Area=:=N,
    centro(Centro),
    nth0(Azulejo,Centro,Cant).
encuentra_ficha(Area,Azulejo,Cant):-
    numero_de_fabricas(N),
    Area<N,
    fabrica(Area, Fabrica),
    nth0(Azulejo,Fabrica,Cant).

itera_area(-1):-!.
itera_area(Area):-
    itera_azulejos(Area, 4),
    NAr is Area -1,
    itera_area(NAr),!.

itera_azulejos(_,-1):-!.
itera_azulejos(Area,Azulejo):-
    numero_de_fabricas(N),
    Area=:=N,
    centro(Centro),
    cant_de_azulejos(Centro,Total),
    Total>0,
    nth0(Azulejo,Centro,Cant),
    Cant>0,
    min_area(MA),
    Cant<MA,
    retractall(jugada_optima(_, _, _)),
    asserta(jugada_optima(Area, Azulejo, 5)),
    retract(min_area(_)),
    asserta(min_area(Cant)),
    NAz is Azulejo -1,
    itera_azulejos(Area, NAz),!.
itera_azulejos(Area,Azulejo):-
    numero_de_fabricas(N),
    Area<N,
    fabrica(Area, Fabrica),
    cant_de_azulejos(Fabrica,Total),
    Total>0,
    nth0(Azulejo,Fabrica,Cant),
    Cant>0,
    min_area(MA),
    Cant<MA,
    retractall(jugada_optima(_, _, _)),
    asserta(jugada_optima(Area, Azulejo, 5)),
    retract(min_area(_)),
    asserta(min_area(Cant)),
    NAz is Azulejo -1,
    itera_azulejos(Area, NAz),!.
itera_azulejos(Area,Azulejo):-
    NAz is Azulejo -1,
    itera_azulejos(Area, NAz),!.

ejecuta_jugada(Jugador,Area,Azulejo, _,Cantidad):-
    numero_de_fabricas(Cant),
    Area=:=Cant,
    centro(Centro),
    nth0(Azulejo,Centro,Cantidad),
    Current is Cantidad*(-1),
    actualiza_centro(Azulejo,Current),
    actualizar_jugador_inicial(Jugador).
ejecuta_jugada(_,Area,Azulejo, _,Cantidad):-
    numero_de_fabricas(Cant),
    Area<Cant,
    fabrica(Area,Fabrica),
    nth0(Azulejo,Fabrica,Cantidad),
    Current is Cantidad*(-1),
    actualiza_fabrica(Area,Azulejo,Current),
    itera_fabrica(Area,4).
itera_fabrica(_,-1):-!.
itera_fabrica(Area,Azulejo):-
    fabrica(Area,Fabrica),
    nth0(Azulejo,Fabrica,Cantidad),
    Current is Cantidad*(-1),
    actualiza_fabrica(Area,Azulejo,Current),
    actualiza_centro(Azulejo,Cantidad),
    NAzulejo is Azulejo - 1,
    itera_fabrica(Area,NAzulejo).

actualizar_jugador_inicial(Jugador):-
    jugador_inicial(-1),
    retract(jugador_inicial(-1)),
    asserta(jugador_inicial(Jugador)),
    agregar_al_suelo(Jugador,1).
actualizar_jugador_inicial(_):-!.

ronda_finalizada():-
    centro(Centro),
    cant_de_azulejos(Centro,0),
    numero_de_fabricas(C),
    Fabrica is C-1,
    fabricas_agotadas(Fabrica),
    retract(ronda_acabada(_)),
    asserta(ronda_acabada(1)),
    alicatado().
ronda_finalizada():-!.

fabricas_agotadas(-1):-!.
fabricas_agotadas(Fabrica):-
    fabrica(Fabrica,F),
    cant_de_azulejos(F,0),
    N is Fabrica-1,
    fabricas_agotadas(N).

% generar jugadas posibles
genera_jugadas(Jugador):-
    numero_de_fabricas(N),
    R is N+1,
    posibles_jugadas(Jugador,R).

posibles_jugadas(_,0):-!.
posibles_jugadas(Jugador,Area):-
    N is Area-1,
    posibles_jugadas(Jugador,N,5),
    posibles_jugadas(Jugador,N).

posibles_jugadas(_,_,0):-!.
posibles_jugadas(Jugador,Area,Azulejo):-
    numero_de_fabricas(Cant),
    Area < Cant,
    fabrica(Area,Fabrica),
    N is Azulejo-1,
    nth0(N,Fabrica,Cant_de_Fichas),
    Cant_de_Fichas=:=0,
    posibles_jugadas(Jugador,Area,N),!.
posibles_jugadas(Jugador,Area,Azulejo):-
    numero_de_fabricas(Cant),
    Area=:=Cant,
    centro(Centro),
    N is Azulejo-1,
    nth0(N,Centro,Cant_de_Fichas),
    Cant_de_Fichas=:=0,
    posibles_jugadas(Jugador,Area,N),!.
posibles_jugadas(Jugador,Area,Azulejo):-
    N is Azulejo-1,
    posibles_jugadas_pv(Jugador,Area,N,5),
    posibles_jugadas(Jugador,Area,N).

posibles_jugadas_pv(_,_,_,0):-!.
posibles_jugadas_pv(Jugador,Area,Azulejo,Fila):-
    N is Fila-1,
    asserta(posible_jugada(Jugador,Area,Azulejo,N)),
    check_posibles_jugadas(Jugador,Area,Azulejo,N),
    posibles_jugadas_pv(Jugador,Area,Azulejo,N).

check_posibles_jugadas(Jugador,Area,Azulejo,Fila):-
    not(fila_completa(Jugador,Fila)),
    color_muro(Azulejo,Fila,Columna),
    indexer(Jugador,Fila,Columna,-1),
    (area_de_preparacion(Jugador,Fila,_,Azulejo);area_de_preparacion(Jugador,Fila,_,-1)),
    elegir_jugada(Jugador,Area,Azulejo,Fila),!.

check_posibles_jugadas(Jugador,Area,Azulejo,Fila):-
    retract(posible_jugada(Jugador,Area,Azulejo,Fila)).

elegir_jugada(Jugador,Area,Azulejo,Fila):-
    califica_jugada(Jugador,Area,Azulejo,Fila,Puntuacion),
    puntuacion_optima(P),
    Puntuacion > P,
    retract(puntuacion_optima(P)),
    asserta(puntuacion_optima(Puntuacion)),
    retract(jugada_optima(_,_,_)),
    asserta(jugada_optima(Area,Azulejo,Fila)).

califica_jugada(Jugador,Area,Azulejo,Fila,P):-
    completa_fila(Jugador,Area,Azulejo,Fila,Cantidad),
    color_muro(Azulejo,Fila,Columna),
    actualiza_muro(Jugador,Fila,Columna,Azulejo),
    suelo(Jugador,Cant_en_suelo),
    Suelo_disponible is 7-Cant_en_suelo,
    resta_ficha_inicial(Area,Jugador,Ficha_inicial),
    NCant is Cantidad + Ficha_inicial,
    Va_al_suelo is min(Suelo_disponible,NCant),
    puntuacion(Jugador,Fila,Columna,Puntuacion,_,_,_,_),
    C is Cant_en_suelo+Va_al_suelo,
    restar_suelo(C,Total),
    restar_suelo(Cant_en_suelo,Parcial),
    P is (Total-Parcial)+Puntuacion,
    actualiza_muro(Jugador,Fila,Columna,-1),
    !.
califica_jugada(Jugador,Area,_,_,P):-
    suelo(Jugador,Cant_en_suelo),
    Suelo_disponible is 7-Cant_en_suelo,
    resta_ficha_inicial(Area,Jugador,Ficha_inicial),
    Va_al_suelo is min(Suelo_disponible,Ficha_inicial),
    C is Cant_en_suelo+Va_al_suelo,
    restar_suelo(C,Total),
    restar_suelo(Cant_en_suelo,Parcial),
    P is (Total-Parcial),
    !.

completa_fila(Jugador,Area,Azulejo,Fila,Cantidad):-
    numero_de_fabricas(N),
    Area<N,
    fabrica(Area,F),
    nth0(Azulejo,F,Cant),
    area_de_preparacion(Jugador,Fila,C,_),
    Cantidad is  Cant+C-(Fila+1),
    Cantidad>=0.
completa_fila(Jugador,Area,Azulejo,Fila,Cantidad):-
    numero_de_fabricas(N),
    Area=:=N,
    centro(Centro),
    nth0(Azulejo,Centro,Cant),
    area_de_preparacion(Jugador,Fila,C,_),
    Cantidad is  Cant+C-(Fila+1),
    Cantidad>=0.
resta_ficha_inicial(Area,Jugador,1):-
    jugador_inicial(-1),
    suelo(Jugador,Suelo),
    Suelo<7,
    numero_de_fabricas(N),
    Area=:=N,!.
resta_ficha_inicial(_,_,0).
% limpiando la simulacion una vez finalizado
limpia_simulacion():-
    retract(cant_de_jugadores(_)),
    retract(numero_de_fabricas(_)),
    retract(jugador_inicial(_)),
    retract(jugador_actual(_)),
    retractall(puntuacion(_,_)),
    retractall(area_de_preparacion(_,_,_,_)),
    retractall(muro(_,_,_)),
    retractall(suelo(_,_)),
    retractall(fabrica(_,_)),
    retract(centro(_)),
    retract(tapa(_)),
    retract(bolsa(_)),
    retractall(filas_completas(_,_)),
    retractall(columnas_completas(_,_)),
    retractall(ronda_acabada(_)),
    retractall(posible_jugada(_,_,_,_)),
    retract(cant_de_ronda(_)),
    retract(puntuacion_optima(_)),
    retractall(jugada_optima(_,_,_)),
    retract(partida_acabada(_)),
    retract(min_area(_)),!.
