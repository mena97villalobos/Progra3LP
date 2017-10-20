-module(progra3).
-export([main/1]).

main(FileName) ->
    {ok, Binary} = file:read_file(FileName),
     Lines = [binary_to_list(Bin) || Bin <- binary:split(Binary, <<"\r","\n">>, [global]), Bin =/= << >>],
	 [H | T] = Lines,
	 [Tmp1, Tmp2, Tmp3, Tmp4, Tmp5, Tmp6, Tmp7] = string:tokens(H, " "), %Valores de quantum y eso
	 {Num, _} = string:to_integer(Tmp1),
	 {Asignar, _} = string:to_integer(Tmp2),
	 {Salida, _} = string:to_integer(Tmp3),
	 {Acquire, _} = string:to_integer(Tmp4),
	 {Release, _} = string:to_integer(Tmp5),
	 {FinProg, _} = string:to_integer(Tmp6),
	 {Quantum, _} = string:to_integer(Tmp7),
	 Valores = [Asignar, Salida, Acquire, Release, FinProg, Quantum],
	 Programas = separarProgramas(T, [], [], 1),
	 correr(Programas, Valores, 0, 0, [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).

correr([], _, _, _, _) -> io:fwrite("Fin~n");
correr([ProgramaActual|T], [Asignar, Salida, Acquire, Release, FinProg, Quantum], QuantumActual, Bloqueo, Variables) ->
	[Instruccion|Cola] = ProgramaActual,
	InstruccionAux = re:replace(Instruccion, " ", "", [global,{return,list}]),
	Write = string:slice(Instruccion, 0, 5),
	Binding = string:slice(InstruccionAux, 1, 1),
	if
		Instruccion == "stop" andalso QuantumActual+FinProg =< Quantum -> 
			correr(T,  [Asignar, Salida, Acquire, Release, FinProg, Quantum], 0, Bloqueo, Variables);
		Instruccion == "acquire" andalso QuantumActual+Acquire =< Quantum andalso Bloqueo == 0 ->
			correr([Cola|T], [Asignar, Salida, Acquire, Release, FinProg, Quantum], QuantumActual+Acquire, 1, Variables);
		Instruccion == "acquire" andalso QuantumActual+Acquire =< Quantum andalso Bloqueo == 1 ->
			correr(lists:append(T,[ProgramaActual]), [Asignar, Salida, Acquire, Release, FinProg, Quantum], 0, 1, Variables);
		Instruccion == "release" andalso QuantumActual + Release =< Quantum ->
			correr(lists:append(T,[Cola]), [Asignar, Salida, Acquire, Release, FinProg, Quantum], 0, 0, Variables);
		Write == "write" andalso QuantumActual+Salida =< Quantum ->
			Index = hd(string:slice(InstruccionAux, 5, 6)) - 97,
			Var = getList(Index, Variables, 0),
			Id = lists:nthtail(length(ProgramaActual)-1, ProgramaActual),
			io:fwrite("~w:~w~n",[Id, Var]),
			correr([Cola|T], [Asignar, Salida, Acquire, Release, FinProg, Quantum], Quantum+Salida, Bloqueo, Variables);
		Binding == "=" andalso QuantumActual+Asignar =< Quantum->
			Index = hd(string:slice(InstruccionAux, 0, 1)) - 97,
			{Valor, _} = string:to_integer(string:slice(InstruccionAux, 2, string:len(InstruccionAux))),
			correr([Cola|T], [Asignar, Salida, Acquire, Release, FinProg, Quantum], Quantum+Salida, Bloqueo, modificarLista(Variables, Valor, Index, 0, []));
		true ->
			correr(lists:append(T,[ProgramaActual]), [Asignar, Salida, Acquire, Release, FinProg, Quantum], 0, Bloqueo, Variables)
	end.

separarProgramas([], Total, Acc, Id) -> Total;
separarProgramas([H | T], Total, Acc, Id) ->
	if H == "stop" -> 
		NewAcc = Acc ++ [H, Id],
		NTotal = Total ++ [NewAcc],
		separarProgramas(T, NTotal, [], Id+1);
	true -> 
		NewAcc = Acc ++ [H],
		separarProgramas(T, Total, NewAcc, Id)
	end.

getList(Index, [H|T], Acc) ->
	if
		Index == Acc ->
			H;
		Index > Acc ->
			getList(Index, T, Acc+1);
		true ->
			-1
	end.

modificarLista([], Valor, Index, Acc, AccLista) -> AccLista;
modificarLista([H|T], Valor, Index, Acc, AccLista)->
	if
		Acc == Index ->
			modificarLista(T, Valor, Index, Acc+1, AccLista++[Valor]);
		true ->
			modificarLista(T, Valor, Index, Acc+1, AccLista++[H])
		end.
