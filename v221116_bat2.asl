// === INITIAL BELIEFS ===

phase(1).
animating(nothing).

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
        <-  switchToLive;
            -animating(nothing).

// cancel animation and switch to live
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & phase(3) & STATE == righthandup
    <-  -animating(_);
        switchToLive;
        .drop_all_desires.

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
