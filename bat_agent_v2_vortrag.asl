// === INITIAL BELIEFS ===

phase(1).
animating(nothing).

// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

// === INITIAL GOALS ===

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).


+!phase(1) : true
        <-  .wait(2000);
            switchToIdle;
            !waitForIdle(500,0);
            switchToCeiling;
            !waitForIdle(500,0);
            switchToLive.

+!phase(3) : true
        <-  -animating(nothing).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0
        <-  -phase(1);
            +phase(3).

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating(_) & phase(3) & STATE == armsforward
    <-  +animating(armsforward);
        switchToIdle;
        !waitForIdle(500,0);
        switchToGround;
        !waitForIdle(2000,500);
        ?actorposition(actor0, X, Y, Z);
           if(camerapos(CX,CZ))
           {
               moveTo(X,Z+0.5,CX,CZ);
           }
           else
           {
               moveTo(X,Z+0.5,0,-3);
           }
        !waitForIdle(1000,0);
        //playanimation(hug, 1);
        playanimation(fall_over, 1);
        !waitForIdle(3000,0);
        switchToCeiling;
        !waitForIdle(2000,0);
        switchToLive;
        .wait(5000);
        -animating(armsforward).

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating(_) & phase(3) & STATE == handstogether
    <-  +animating(handstogether);
        .wait(600);
        if(actorstate(ACTOR, STATE))
        {
            !fall;
        }
        else
        {
            -animating(handstogether);
        }
        .

+!fall : true
    <-  .random(RANDOM);
        if(RANDOM > 0.66)
        {
            playanimation(fall, 1);
            .wait(1000);
        }
        else
        {
        if(RANDOM > 0.33)
        {
            playanimation(fall, 1);
            .wait(1000);
        }
        else
        {
            playanimation(fall, 2);
            .wait(10000);
        }
        }
        //!waitForIdle(2000,0);     // TODO: testin
        !fall.

-actorstate(ACTOR, STATE) : my_actor(ACTOR) & phase(3) & animating(handstogether) & STATE == handstogether
    <-  .drop_desire(fall);
        switchToLive;
        .wait(5000);
        -animating(handstogether).

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating(_) & phase(3) & STATE == backtoscreen
    <-  +animating(backtoscreen);
        .wait(600);
        if(actorstate(ACTOR, STATE))
        {
            !sail;
        }
        else
        {
            -animating(backtoscreen);
        }
        .

-actorstate(ACTOR, STATE) : my_actor(ACTOR) & animating(backtoscreen) & phase(3) & STATE == backtoscreen
    <-  .drop_desire(sail);
        switchToLive;
        .wait(5000);
        -animating(backtoscreen).

+!sail : true
    <-  .random(RANDOM);
        if(RANDOM > 0.66)
        {
            playanimation(sail, 1);
        }
        else
        {
        if(RANDOM > 0.33)
        {
            playanimation(sail, 2);
        }
        else
        {
            playanimation(sail, 2);
        }
        }
        !waitForIdle(2000,0);
        !sail.


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
