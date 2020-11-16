%Se utilizaron predicados dinámicos ya que la definición del predicado puede cambiar durante la ejecución.

:-dynamic(propiedad/3).
:-dynamic(caracteristica/2).
:-dynamic(categoria/2).
:-dynamic(caract_deseadas/1).
:-dynamic(caract_no_deseadas/1).

%Se abren los archivos que tienen almacenada la base de hechos que utiliza el sistema.
abrir_base_conocimiento:-
        %Se utiliza retractall para evitar conflictos con cualquier declaración anterior de los mismos hechos.
        retractall(propiedad(_,_,_)),
        retractall(caracteristica(_,_)),
        retractall(categoria(_,_)),
        retractall(caract_deseadas(_)),
        retractall(caract_no_deseadas(_)),
        consult("C:/Users/Bruno/Documents/Programacion/Prolog/sistema-experto-IA-2020/propiedades.txt"),
        consult("C:/Users/Bruno/Documents/Programacion/Prolog/sistema-experto-IA-2020/caracteristicas.txt"),
        consult("C:/Users/Bruno/Documents/Programacion/Prolog/sistema-experto-IA-2020/categorias.txt").

expertProp:-
        abrir_base_conocimiento,
        writeln('Bienvenido a ExperProp, aqui comienza el camino hacia el hogar de sus suenios.'),
        writeln('Quiere comenzar ahora? (s/n)'),
        read(Respuesta),
        inicio(Respuesta).

inicio('s'):-
        %Se obtiene la categoría de propiedades que busca el usuario (venta o alquiler).
        preguntarCategoria(IdCategoria),
        %Se obtiene la primer propiedad de la BD que cumpla con la categoria elegida, para luego enviar en la regla siguiente el listado
        %de sus características.
        propiedad(IdCategoria,Caracteristicas,Nombre),
        %Se envía el listado de categorías obtenido del hecho anterior como puntapié inicial para comenzar a realizar preguntas al usuario.
        buscarPropiedad(IdCategoria,Caracteristicas,Nombre).

%Esta definición de la regla se ejecuta cuando la anterior da como resultado false.
inicio('s'):-
        writeln('Por favor vuelva a intentarlo si quiere modificar alguna caracteristica ingresada, no encuentro el lugar de sus suenios aun.').

%En caso de que la anterior también falle, se ejecutará esta última definición de la regla inicio.
inicio(_):-
        writeln('Espero haberlo ayudado, Saludos').

preguntarCategoria(IdCategoria):-
        writeln('¿Desea alquilar o comprar?:
        1:Compra
        2:Alquiler'),
        read(IdCategoria).

%La regla buscarPropiedad se evalua pasando como argumento una lista de las caracteristicas, que se recorrerá aplicando esta regla de 
% manera iterativa. Se declara una condicion de salida, cuando el listado que se está recorriendo queda vacío, ya que se recorre evaluando 
% la cabeza del arreglo, y pasando como argumento la cola restante a la regla. Al terminar, se muestra el resultado alcanzado.
buscarPropiedad(_,[],Nombre):-
        %Cuando la condición de salida se cumple, se muestra el resultado de la encontrado.
        writeln('Encontre el lugar perfecto para usted, la direccion es: '),
        mostrarPropiedad(Nombre),
        expertProp.

%Si la lista aún tiene elementos, se le realiza otra pregunta al usuario y se vuelve a evlauar la regla de forma recursiva con la nueva info.
%En caso de no haber encontrado una propiedad para la selección del usuario.

buscarPropiedad(IdCategoria,[H|T],Nombre):-
        %Se llama a esta regla para realizar una pregunta al usuario acerca de la siguiente característica en la lista,
        %es decir, la cabeza de la lista de Caracteristicas.
        nuevaPregunta(H, IdCategoria),
        !,
        buscarPropiedad(IdCategoria, T,Nombre).

nuevaPregunta(Caracteristica, _):-
        %Se evalua si una característica ya está incluída en la base de hechos de caract_deseadas.
        caract_deseadas(Caracteristica).

nuevaPregunta(Caracteristica, _):-
        %Se evalua si una característica ya está incluída en la base de hechos de caract_no_deseadas, y en tal
        %caso se finaliza la busqueda.
        caract_no_deseadas(Caracteristica),
        !,
        fail.

nuevaPregunta(Caracteristica, IdCategoria):-
        %Si la característica no está en ninguna de las dos listas, entonces se llama a la regla pregunta para realizar
        %la consulta al usuario y así poder clasificarla.
        pregunta(Caracteristica, IdCategoria).

%Se le realiza una consulta al usuario acerca de una característica para saber si es deseada o no deseada.
pregunta(CodigoCaracteristica, IdCategoria):-
        caracteristica(CodigoCaracteristica, Caracteristica),
        write('Desea que su hogar ideal para usted '),
        write(Caracteristica),
        writeln('?(s/n)'),
        read(Respuesta),
        validar(Respuesta, CodigoCaracteristica, IdCategoria).

%Añade un hecho de caract_deseadas a la base de hechos con la característica que recibe como parámetro.
listaDeseadas(Caracteristica):-
        %El asserta nos permite añadir hechos de manera dinámica al principio de la BD.
        %Al estar al comienzo, se le da prioridad máxima al hecho agregado.

        asserta(caract_deseadas(Caracteristica)).
        
        %Al recorrer la lista de caracteristicas, el sistema le pregunta al usuario si desea las caracteristicas que 
        %tiene la primera propiedad, en orden. Si el usuario dice que no para una de ellas, el sistema evita repreguntar las 
        %anteriores a las que ya respondio que si, utilizando el asserta para introducir la nueva característica al comienzo de la bd.

%Añade un hecho de caract_no_deseadas a la base de hechos con la característica que recibe como parámetro.
listaNoDeseadas(Caracteristica):-
        %Al igual que en el caso anterior, el asserta nos permite añadir hechos de manera dinámica al principio de la BD.
        %Al estar al comienzo, se le da prioridad máxima al hecho agregado.
        asserta(caract_no_deseadas(Caracteristica)).

%Llama a la regla que añade a la característica a las características deseadas, mediante un hecho de caract_deseadas.
validar('s',IdCaracteristica ,_):-
        listaDeseadas(IdCaracteristica).

%En caso de que el usuario haya respondido con otro caracter, se le vuelve a realizar la pregunta.     
validar(Respuesta, IdCaracteristica, IdCategoria):-
        Respuesta \= 'n', writeln('Responda s/n'),
        read(Respuesta),
        validar(Respuesta,IdCaracteristica, IdCategoria).

%Llama a la regla que añade a la característica a las características no deseadas, mediante un hecho de caract_no_deseadas.
validar('n', IdCaracteristica, _):-
        listaNoDeseadas(IdCaracteristica),
        fail.

%Muestra el nombre de la propiedas recomendada.
mostrarPropiedad(Nombre):-
        writeln(Nombre),
        writeln('Consulte a nuestro agente inmobiliario por esta propiedad, vivir su suenio depende de usted.').











