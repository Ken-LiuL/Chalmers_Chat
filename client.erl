-module(client).
-export([loop/2, initial_state/2]).

-include_lib("./defs.hrl").

%%%%%%%%%%%%%%%
%%%% Connect
%%%%%%%%%%%%%%%
loop(St, {connect, Server}) ->
	Ref =  make_ref(),
    list_to_atom(Server) ! {request,self(),Ref,{connect,St}},
	receive
		{result,_,ok} ->
			{ok,St#cl_st{status=connected}} ;
		{result,_,error} ->
			{{error,user_already_connected,"user_already_connected"},St} 
		  
	end;

%%%%%%%%%%%%%%%
%%%% Disconnect
%%%%%%%%%%%%%%%
loop(St, disconnect) ->
     {ok, St} ;

%%%%%%%%%%%%%%
%%% Join
%%%%%%%%%%%%%%
loop(St,{join,_Channel}) ->
    {ok, St} ;

%%%%%%%%%%%%%%%
%%%% Leave
%%%%%%%%%%%%%%%
loop(St, {leave, _Channel}) ->
     {ok, St} ;

%%%%%%%%%%%%%%%%%%%%%
%%% Sending messages
%%%%%%%%%%%%%%%%%%%%%
loop(St, {msg_from_GUI, _Channel, _Msg}) ->
     {ok, St} ;


%%%%%%%%%%%%%%
%%% WhoIam
%%%%%%%%%%%%%%
loop(St, whoiam) ->
    {St#cl_st.nickname, St} ;

%%%%%%%%%%
%%% Nick
%%%%%%%%%%
loop(St,{nick,Nick}) ->
	{ok, St#cl_st{nickname = Nick}} ;

%%%%%%%%%%%%%
%%% Debug
%%%%%%%%%%%%%
loop(St, debug) ->
    {St, St} ;

%%%%%%%%%%%%%%%%%%%%%
%%%% Incoming message
%%%%%%%%%%%%%%%%%%%%%
loop(St = #cl_st { gui = GUIName }, _MsgFromClient) ->
    {Channel, Name, Msg} = decompose_msg(_MsgFromClient),
    gen_server:call(list_to_atom(GUIName), {msg_to_GUI, Channel, Name++"> "++Msg}),
    {ok, St}.


% This function will take a message from the client and
% decomposed in the parts needed to tell the GUI to display
% it in the right chat room.
decompose_msg(_MsgFromClient) ->
    {"", "", ""}.


initial_state(Nick, GUIName) ->
    #cl_st { gui = GUIName,
		  nickname = Nick,
		  chatroom = none,
		  status = unconnected}.
