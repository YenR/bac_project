// === INITIAL BELIEFS ===

phase(1).
timidity(50).

// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

inblurzone
    :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & (X < -2 | X > 2 | Z < -2 | Z > 2).

handsresting
    :- my_actor(ACTOR) & not actorstate(ACTOR, righthandup) & not actorstate(ACTOR, lefthandup).

// === INITIAL GOALS ===

!updateTimidity.

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

+timidity(N) : N > 50
    <-  //printSprite(threatening, 600, screen, 0.5, 0.5, 5, (N-50)/50 + 0.1);
        printSprite(threatening_linear_vertical, 600, screen, 0.5, 0.5, 5, (N-50)/50 + 0.1);
        printText(N, 600, screen, 0.8, 0.8).

+timidity(N) : N <= 50
    <-  //printSprite(happy, 600, screen, 0.5, 0.5, 5, 1 - N/50 + 0.1);
        printSprite(comfortable_linear_vertical, 600, screen, 0.5, 0.5, 5, 1 - N/50 + 0.1);
        printText(N, 600, screen, 0.8, 0.8).


+!updateTimidity : phase(1) & timidity(N) & N >= 2
    <-  -+timidity(N-2);
        .wait(1000);
        !!updateTimidity.

+!updateTimidity : phase(2) & inblurzone & timidity(N)
    <-  if(handsresting)
        {
            if(N > 4)
            {
                -+timidity(N-5);
                //printText("Very Comfortable", 1, screen, 0.8, 0.9);
            }
        }
        else
        {
            if(N < 99)
            {
                -+timidity(N+2);
                //printText("Uncomfortable", 1, screen, 0.8, 0.9);
            }
        }
        .wait(1000);
        !!updateTimidity.


+!updateTimidity : phase(2) & not inblurzone & timidity(N)
    <-  if(handsresting)
        {
            if(N > 0)
            {
                -+timidity(N-1);
                //printText("Comfortable", 1, screen, 0.8, 0.9);
            }
        }
        else
        {
            if(N < 91)
            {
                -+timidity(N+10);
                //printText("Very Uncomfortable", 1, screen, 0.8, 0.9);
            }
        }
        .wait(1000);
        !!updateTimidity.


// default
+!updateTimidity : true
    <-  .wait(1000);
        !!updateTimidity.

-!updateTimidity : true
    <-  .print("UpdateTimitidy failed!");
        .wait(1000);
        !!updateTimidity.

+actordistancetoscreen(ACTOR, DISTANCE) : my_actor(ACTOR) & DISTANCE < 80 & not cd(actordistancetoscreen)
    <-  +cd(actordistancetoscreen);
        //printSprite(exclam_mark, 1.5, head, 0.55, 0.45, 2);
        //printSprite(exclam_mark, 1.5, head, 0.6, 0.46);
        -+timidity(100).

+cd(actordistancetoscreen) : true
    <-  !!cd.

+!cd : true
    <-  .wait(5000);
        -cd(actordistancetoscreen).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE >= 1 & initiated
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE >= 1 & not initiated   // failsafe
        <-  .wait(3000);
            -phase(1);
            +phase(2).

+!phase(1) : true
        <-  switchToIdle;
            !waitForIdle(250,0);
            //switchToCeiling;
            switchToGround;
            .print("init phase 1 (waiting for visitor)");
            !waitForIdle(1000,250);
            if(camerapos(CX,CZ))
            {
               moveTo(-1,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(-1,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,0);
            +initiated;
            !!waitForVisitor.

+!phase(2) : true
        <-  .drop_desire(waitForVisitor);
            .print("init phase 2 (live)");
            switchToGround;
            !waitForIdle(1000,0);
            switchToLive;
            ?my_actor(ACTOR);
            ?actorposition(ACTOR, X, Y, Z);
            +lastpos(X, Z).

+lastpos(OLDX, OLDZ) : true
    <-  .wait(1000);
        ?my_actor(ACTOR);
        ?actorposition(ACTOR, X, Y, Z);
        if(not distance_under(OLDX, X, 0.8) | not distance_under(OLDZ, Z, 0.8))
        {
            //printSprite(exclam_mark, 0.6, head, 0.55, 0.45);
            ?timidity(N);
            if(N < 91)
            {
                -+timidity(N+10);
                //printText("You are too fast!", 3, screen, 0.8, 0.7);
            }
        }
        -+lastpos(X, Z).


// plays waiting animations ("sleeping cocoon") in pseudo random order (no same animation 3 times in a row)
+!waitForVisitor : true
        <-  .random(RANDOM);
            if(RANDOM > 0.66)
            {
                if(last_animation(NAME, TIMES) & NAME == hanging_cocoon1)
                {
                    if(TIMES < 2)
                    {
                        -+last_animation(hanging_cocoon1, TIMES+1);
                        playanimation(hanging_cocoon, 1);
                    }
                }
                else
                {
                    -+last_animation(hanging_cocoon1, 1);
                    playanimation(hanging_cocoon, 1);
                }
            }
            else
            {
            if(RANDOM > 0.33)
            {
                if(last_animation(NAME, TIMES) & NAME == hanging_cocoon2)
                {
                    if(TIMES < 2)
                    {
                        -+last_animation(hanging_cocoon2, TIMES+1);
                        playanimation(hanging, 2);   // TODO change to hanging cocoon 2
                    }
                }
                else
                {
                    -+last_animation(hanging_cocoon2, 1);
                    playanimation(hanging, 2);   // TODO change to hanging cocoon 2
                }
            }
            else
            {
                if(last_animation(NAME, TIMES) & NAME == hanging_cocoon3)
                {
                    if(TIMES < 2)
                    {
                        -+last_animation(hanging_cocoon3, TIMES+1);
                        playanimation(hanging, 3);   // TODO change to hanging cocoon 3
                    }
                }
                else
                {
                    -+last_animation(hanging_cocoon3, 1);
                    playanimation(hanging, 3);   // TODO change to hanging cocoon 3
                }
            }
            }
            .wait(11000);       // TODO magic number
            !waitForVisitor.

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
