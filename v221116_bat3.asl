// === INITIAL BELIEFS ===

phase(1).

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0 & initiated
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0 & not initiated   // failsafe
        <-  .wait(3000);
            -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE >= 1 & initiated
        <-  -phase(2);
            +phase(3).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE >= 1 & not initiated   // failsafe
        <-  .wait(3000);
            -phase(2);
            +phase(3).

+!phase(1) : true
        <-  switchToIdle;
            !waitForIdle(250,0);
            switchToCeiling;
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
        <-  switchToLive.

+actordistancetoscreen(ACTOR, DISTANCE) : my_actor(ACTOR) & DISTANCE < 50 & not clf & phase(3)
    <-  +clf;
        switchToCamera(CameraLeftForeArm, 3);
        .wait(60000);
        switchToCamera(CameraFront, 3);
        .wait(10000);
        -clf.

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
