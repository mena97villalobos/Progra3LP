-module(progra3).
 
 -export([main/1]).

main(FileName) ->
    {ok, Binary} = file:read_file(FileName),
     Lines = [binary_to_list(Bin) || Bin <- binary:split(Binary, <<"\r","\n">>, [global]), Bin =/= << >>],
	 [H | T] = Lines,
	 [Tmp1, Tmp2, Tmp3, Tmp4, Tmp5, Tmp6, Tmp7] = string:tokens(H, " "),
	 {Num, _} = string:to_integer(Tmp1),
	 io:fwrite("~p", [Num]).