// === INITIAL BELIEFS ===

phase(1).

// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

inblurzone
    :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & (X < -2 | X > 2 | Z < -2 | Z > 2).

handsresting
    :- my_actor(ACTOR) & not actorstate(ACTOR, righthandup) & not actorstate(ACTOR, lefthandup).

// === INITIAL GOALS ===

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE >= 1 & initiated
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE >= 1 & not initiated   // failsafe
        <-  .wait(3000);
            -phase(1);
            +phase(2).

+!checkPhase3 : my_actor(ACTOR)
    <-  if(not actorstate(ACTOR, headdown) & not actorstate(ACTOR, waistdown))
        {
            -phase(2);
            +phase(3);
        }
        .

+!checkPhase4 : my_actor(ACTOR)
    <-  if(actorstate(ACTOR, waistdown))
        {
            -phase(3);
            +phase(4);
        }
        else
        {
            .wait(1000);
            !!checkPhase4;
        }
        .

+!checkPhase5 : my_actor(ACTOR)
    <-  if(not actorstate(ACTOR, waistdown) & not actorstate(ACTOR, headdown))
        {
            -phase(4);
            +phase(5);
        }
        else
        {
            .wait(1000);
            !!checkPhase5;
        }
        .

+!phase(1) : true
        <-  switchToIdle;
            !waitForIdle(250,0);
            switchToGround;
            !waitForIdle(1000,250);
            if(camerapos(CX,CZ))
            {
               moveTo(0,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(0,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,0);
            +initiated.

+!phase(2) : true
        <-  switchToLive;
            switchZebraMaterial;
            .wait(240000);
            playanimation(octopus, 1);
            .wait(4000);
            !loopoctopus.

+!loopoctopus : true
    <-  playanimation(octopus, 2);
        .wait(1000);
        !!checkPhase3;
        !loopoctopus.

+!phase(3) : true
    <-  playanimation(octopus, 3);
        !waitForIdle(500,0);
        switchToLive;
        switchZebraMaterial;
        .wait(10000);
        switchToSwapping;
        !!checkPhase4.

+!phase(4) : true
    <-  switchToSwapping;
        .wait(2000);
        switchToIdle;
        switchToFloor;
        !waitForIdle(500,0);
        switchToLive;
        .wait(2000);
        switchToCamera(CameraLeftForeArm, 5);
        .wait(30000);
        !!checkPhase5.

+!phase(5) : true
    <-  switchToCamera(CameraFront, 5);
        .create_agent(bat_agent00, "bat_agent_v2_vortrag.asl");
        .send(bat_agent00, tell, my_agent(agent0));
        .send(bat_agent00, tell, my_actor(actor0)).


// === NOT AGENT SPECIFIC PLANS ===

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
