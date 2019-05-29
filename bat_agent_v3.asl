// === INITIAL BELIEFS ===

phase(1).
animating.

// === INITIAL GOALS ===

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0 & VALUE < 1 & initiated
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE == 1
        <-  -phase(2);
            +phase(3).

+!phase(1) : true
        <-  .print("init phase 1 (waiting for visitor)");
            .create_agent(shadow_agent10, "shadowAgent.asl");
            .send(shadow_agent10, achieve, phase(1));
            if(camerapos(CX,CZ))
            {
               moveTo(-1,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(-1,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,100);
            +initiated;
            !!waitForVisitor.

+!phase(2) : true
        <-  .print("init phase 2 (donning)");
            .send(shadow_agent10, achieve, phase(2)).

+!phase(3) : true
        <-  .drop_desire(waitForVisitor);
            .print("init phase 3 (live)");
            .send(shadow_agent10, achieve, die);
            switchToIdle;
            !waitForIdle(1000,250);
            switchToLive;
            -animating.


// Print black holes on arms and feet, scaling with distance to screen
+actordistancetoscreen(ACTOR, DISTANCE) : my_actor(ACTOR) & phase(3)
    <-  //printSprite(black1, 100, righthand, 0.5, 0.5, DISTANCE/300);
            printSprite(black1, 100, lefthand, 0.5, 0.5, DISTANCE/400).


// Handstogether causes the bat to come down to the ground. it will stay there for a maximum of 30 seconds or until hands are put together again.
// after going to the ground, it will ignore the command to go down again for 30 seconds
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating & phase(3) & STATE == handstogether & not onGround & not stayOnCeiling
    <-  +animating;
        +onGround;
        switchToIdle;
        !waitForIdle(250,0);
        switchToGround;
        !waitForIdle(2000,0);
        switchToCamera(CameraLeftForeArm, 3);
        .wait(3000);
        switchToLive;
        -animating;
        +stayOnCeiling;
        !!getBackToCeiling(30).

// handstogether while on ground causes bat to go back to ceiling
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating & phase(3) & STATE == handstogether & onGround
    <-  +animating;
        -onGround;
        switchToIdle;
        !waitForIdle(250,0);
        switchToCeiling;
        !waitForIdle(2000,0);
        switchToCamera(CameraFront, 3);
        .wait(3000);
        switchToLive;
        -animating.

// causes the bat to go back to ceiling after TIME seconds
+!getBackToCeiling(TIME) : true
    <-  .wait(TIME * 1000);
        if(not animating & onGround)
        {
            +animating;
            -onGround;
            switchToIdle;
            !waitForIdle(250,0);
            switchToCeiling;
            !waitForIdle(2000,500);
            switchToCamera(CameraFront, 3);
            .wait(3000);
            switchToLive;
            -animating;
        } .

// after coming down, the bat will not react to commands to come down for 60 seconds
+stayOnCeiling : true
    <-  .wait(60000);
        -stayOnCeiling.

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

/*
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating & phase(3) & STATE == armsforward
    <-  +animating;
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
        playanimation(bow, 1);
        !waitForIdle(3000, 250);
        switchToCeiling;
        !waitForIdle(2000, 250);
        switchToLive;
        .wait(5000);
        -animating.

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating & phase(3) & STATE == sitsdown
    <-  +animating;
    	+falling;
	    !!fall.

-actorstate(ACTOR, STATE) : my_actor(ACTOR) & phase(3) & animating & falling & STATE == sitsdown
    <-  .drop_desire(fall);
        switchToLive;
        .wait(5000);
	    -falling;
        -animating.

+!fall : true		// TODO: pseudo-rng and actual animations
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
        !!fall.

+actorstate(ACTOR, STATE) : my_actor(ACTOR) & not animating & phase(3) & STATE == backtoscreen
    <-  +animating;
	+sailing;
	!!sail.

-actorstate(ACTOR, STATE) : my_actor(ACTOR) & animating & sailing & phase(3) & STATE == backtoscreen
    <-  .drop_desire(sail);
        switchToLive;
        .wait(5000);
	    -sailing;
        -animating.

+!sail : true			// TODO: numbers, prng
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
        !!sail.
*/



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
