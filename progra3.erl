-module(progra3).
 
 -export([main/1]).

%lists:nthtail(length(L)-1, L). Last item of list

 
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
	 correr(Programas, Valores, Quantum).
	 
 correr([], Valores, Quantum) -> io:fwrite("Fin");
 correr([Actual | Cola], [A, B, C, D, E, F], Quantum) ->
	io:fwrite(Actual),
	io:fwrite("\n"),
	[H|T] = Actual,
	Aux = string:slice(H, 0, 5),
	if 
		H == "stop" ->
			%io:fwrite("Fin\n"),
			correr(Cola, [A, B, C, D, E, F], 0);
			
		H == "acquire" ->
			%io:fwrite("Acquire\n"),
			if Quantum+C == F ->
				correr([Cola|T], [A, B, C, D, E, F], 0);
			true ->
				correr([T|Cola], [A, B, C, D, E, F], Quantum+C)
			end;
			
		H == "release" ->
			%io:fwrite("Release\n"),
			if Quantum+C == F ->
				correr([Cola|T], [A, B, C, D, E, F], 0);
			true ->
				correr([T|Cola], [A, B, C, D, E, F], Quantum+D)
			end;
			
		Aux == "write"  ->
			%io:fwrite("Write\n"),
			if Quantum+B >= F ->
				correr([Cola|T], [A, B, C, D, E, F], 0);
			true ->
				correr([T|Cola], [A, B, C, D, E, F], Quantum+B)
			end;
			
		true ->
			%io:fwrite("Asignar\n"),
			if Quantum+C == F ->
				correr([Cola|T], [A, B, C, D, E, F], 0);
			true ->
				correr([T|Cola], [A, B, C, D, E, F], Quantum+A)
			end
	end.
 
separarProgramas([], Total, Acc, Id) -> Total;
separarProgramas([H | T], Total, Acc, Id) ->
	if H == "stop" -> 
		NewAcc = Acc ++ [H, Id],
		NTotal = Total ++ [NewAcc],
		separarProgramas(T, NTotal, [], Id+1);
	true -> 
		%io:fwrite("false"),
		NewAcc = Acc ++ [H],
		separarProgramas(T, Total, NewAcc, Id)
	end.
	 
for(Inicio, Fin, Acc) when Inicio >= Fin+1 -> Acc;
	 
for(Inicio, Fin, Acc) -> 
	List = Acc ++ [Inicio],
	for(Inicio+1, Fin, List).
	
