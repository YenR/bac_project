w(250).     // waiting time between adjustments in ms
d(0.025).   // delta for movement value, gets deducted every adjustment
l(30).      // limit to trigger lie down

m(0).       // starting movement value


// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

// === GOALS ===
!start.

// === PLANS ===

+!start : true
    <-  .wait(250);
        //switchToLive;
        ?actorposition(ACTOR,X,Y,Z);
        +lastposition(X,Z);
        !!checkMovement.


+!checkMovement : (sleeping | falling_asleep) & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z)
    <-  -+lastposition(X,Z);
        ?w(W);
        .wait(W);
        !!checkMovement.

+!checkMovement : (not (sleeping | falling_asleep)) & lastposition(LX,LZ) & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z)
    <-  ?m(M);
        .print("m: ", M);
        if(LX > X)
        {
            -+m(M+(LX-X));
        }
        else
        {
            -+m(M+(X-LX));
        }
        ?m(M2);
        ?d(D);
        if(LZ > Z)
        {
            -+m(M2+(LZ-Z) - D);
        }
        else
        {
            -+m(M2+(Z-LZ) - D);
        }
        -+lastposition(X,Z);
        ?w(W);
        .wait(W);
        !!checkMovement.

+m(M) : M < 0
    <-  -+m(0).

+m(M) : l(L) & M > L & not sleeping & not falling_asleep & not agent_sleeping
    <-  +falling_asleep;
        .broadcast(tell, agent_sleeping);
        playanimation(lie_down, 1);
        queueanimation(sleep_loop, 1, 1, 1);
        .wait(3000);
        -+m(0);
        +sleeping;
        -falling_asleep.

+actorstate(ACTOR, waistlow) : sleeping & not my_actor(ACTOR) & agentposition(AGENT, X, _, _) & not my_agent(AGENT)
    & my_agent(AGENT2) & agentposition(AGENT2, X2, _, _) & distance_under(X, X2, 0.8)
    <-  -sleeping;
        .broadcast(untell, agent_sleeping);
        playanimation(deep_get_up, 1);
        !waitForIdle(1000,1000);
        switchToLive.

+actorstate(ACTOR, waistlow) : sleeping & not my_actor(ACTOR) & not ( agentposition(AGENT, X, _, _) & not my_agent(AGENT)
    & my_agent(AGENT2) & agentposition(AGENT2, X2, _, _) & distance_under(X, X2, 0.8))
    <-  .print("not close enough?").


// === NOT AGENT SPECIFIC PLANS ===

+!lookIntoCamera : camerapos(CX,CZ) & my_actor(ACTOR)
    <-  ?agentposition(AGENT, X, Y, Z);
        moveTo(X,Z, CX,CZ);
        !waitForIdle(1000,500).

+!lookIntoCamera : not camerapos(_, _) & my_actor(ACTOR)
    <-  ?agentposition(AGENT, X, Y, Z);
        moveTo(X,Z, 0,-3);
        !waitForIdle(1000,500).

// default waitForIdle = wait 1/2 second, then wait until agent is idle, then wait another 1/4 second
+!waitForIdle : true
                    <-  .wait(500);
                        if(my_agent(AGENT) & not agentstate(AGENT, idle))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, idle));
                        }
                        .wait(250).

+!waitForIdle(N,M) : true
                    <-  .wait(N);
                        if(my_agent(AGENT) & not agentstate(AGENT, idle))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, idle));
                        }
                        .wait(M).
