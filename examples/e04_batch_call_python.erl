%% For this demo please make sure that `make pynode` is running in a separate
%% console tab.

-module(e04_batch_call_python).

%% API
-export([start/0]).

start() ->
    %% Create an empty batch and begin adding calls to it
    S0 = py:batch_new(),
    {S1, Mod} = py:batch_import(S0, datetime),
    {S2, R2} = py:batch_call(S1, [Mod, "datetime", now], []),
    {S3, R3} = py:batch_call(S2, [Mod, datetime, <<"now">>], [], #{}),
    %% Subtract two datetimes
    {S4, Diff} = py:batch_call(S3, [R3, '__sub__'], [R2], #{}),

    %% Call Diff.total_seconds() and retrieve the value without storing it
    %% in remote history.
    {S5, _R5} = py:batch_call(S4, [Diff, <<"total_seconds">>], []),
    io:format("EXAMPLE4: Batch created:~n~120p~n", [S5]),

    %% Create a remote notebook object (context) on Python side
    io:format("EXAMPLE4: Connecting to py@127.0.0.1~n"),
    Ctx  = py:new_context('py@127.0.0.1'),

    io:format("jso, ~p~n", [S5]),
    %% will retrieve because immediate=true by default
    Result = py:batch_run(Ctx, S5),
    io:format("EXAMPLE4: Result1 (immediate) = ~p~n", [Result]),

    Result2Ref = py:batch_run(Ctx, S5, #{immediate => false}),
    Result2 = py:retrieve(Ctx, Result2Ref),
    io:format("EXAMPLE4: Result2 (retrieved) = ~p~n", [Result2]),
    io:format("NOTE: Result2 will be different from Result1 because the batch "
                ++ "was executed twice!~n"),

    %% Done with the remote context. Remote notebook object will be dropped.
    py:destroy(Ctx),
    io:format("Finished~n"),
    init:stop().
