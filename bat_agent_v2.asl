// === INITIAL BELIEFS ===

attitude(normal).
weight(1).
phase(1).
offsets(0).
animating(nothing).
last_animation(nothing, 0).

// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

// === INITIAL GOALS ===

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).


+!phase(1) : true
        <-  .print("init phase 1 (waiting for visitor)");
            .create_agent(shadow_agent10, "shadowAgent.asl");
            .send(shadow_agent10, achieve, phase(1));
            switchToCeiling;
            !waitForIdle(1000,500);
            if(camerapos(CX,CZ))
            {
               moveTo(-1,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(-1,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,500);
            !waitForVisitor.

+!phase(2) : true
        <-  .print("init phase 2 (donning)");
            .send(shadow_agent10, achieve, phase(2));
            //printSprite(exclam_mark, 5, head, 0.55, 0.45);
            //printText("I will show you how to put on the skeleton.", 80, screen, 0.75, 0.75);
            //.wait(2000);
            !waitForVisitor.
            /*
            switchToIdle;
            !waitForIdle;
            switchToGround;
            !waitForIdle(5000,1000);
            ?actorposition(actor0, X, Y, Z);
            if(camerapos(CX,CZ))
            {
                moveTo(X,Z+0.5,CX,CZ);
            }
            else
            {
                moveTo(X,Z+0.5,0,-3);
            }
            !waitForIdle;
            !donning.*/

+!phase(3) : true
        <-  .print("init phase 3 (live)");
            .send(shadow_agent10, achieve, die);
            switchToLive;
            .wait(3000);
            -animating(nothing).
            /*
            printText( _, 0.001, screen, 0.75, 0.75).    // cheap way to remove text left over from donning phase
            if(onCeiling)
            {
                .wait(2500);
                switchToIdle;
                !waitForIdle;
                switchToCeiling;
                !waitForIdle;
                switchToLive;
            } .*/

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE == 1
        <-  -phase(2);
            +phase(3).

+my_actor(ACTOR) : my_agent(AGENT)
        <-  .my_name(NAME);
            .print("Hi I am ", NAME, ". I watch ",  ACTOR, " and control ", AGENT, ".").


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
                        playanimation(hanging_cocoon, 1);   // TODO change ID to 2
                    }
                }
                else
                {
                    -+last_animation(hanging_cocoon2, 1);
                    playanimation(hanging_cocoon, 1);  // TODO change ID to 2
                }
            }
            else
            {
                if(last_animation(NAME, TIMES) & NAME == hanging_cocoon3)
                {
                    if(TIMES < 2)
                    {
                        -+last_animation(hanging_cocoon3, TIMES+1);
                        playanimation(hanging_cocoon, 1);   // TODO change ID to 3
                    }
                }
                else
                {
                    -+last_animation(hanging_cocoon3, 1);
                    playanimation(hanging_cocoon, 1);  // TODO change ID to 3
                }
            }
            }
            .wait(15000);
            !waitForVisitor.

+!donning : true
        <-  !waitForIdle;
            playanimation(donning_shadow, 1);
            printText("Please imitate my actions.", 200, screen, 0.25, 0.75);
            !donning.

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == headtoshoulder
    <-  printSprite(happy, 5, screen, 0.5, 0.5).

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
        playanimation(hug, 1);
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
