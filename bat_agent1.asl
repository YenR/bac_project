// === INITIAL BELIEFS ===

attitude(normal).
weight(1).
phase(1).
offsets(0).

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
            switchToCeiling;
            !waitForIdle(1000,500);
            !waitForVisitor.

+!phase(2) : true
        <-  .print("init phase 2 (donning)");
            !donning.

+!phase(3) : true
        <-  +animating;
            .print("init phase 3 (interaction)");
            //offsets_toIdle;
            switchToIdle;
            !waitForIdle;
            if(onGround)
            {
                switchToCeiling;
                -onGround;
            }
            !waitForIdle(1000,500);
            switchToLive;
            .wait(2000);
            -animating.

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1)
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE == 1
        <-  -phase(2);
            +phase(3).

+my_actor(ACTOR) : my_agent(AGENT)
        <-  .my_name(NAME);
            .print("Hi I am ", NAME, ". I watch ",  ACTOR, " and control ", AGENT, ".").

+animating : true
        <-  !stopMaskingCD.

-animating : true
        <-  !startMaskingCD.

+!stopMaskingCD : true
        <-  .drop_desire(startMaskingCD);
            -masking.

+!startMaskingCD : true
        <-  .wait(60000);   // = 1 min
            .print("Starting masking");
            +masking.

// activate masking, interruptable by actor actions
+masking : true
        <-  !startMasking.

-masking : true
        <-  drop_desire(startMasking).

+!startMasking : true
        <-  !turnToScreen;
            playanimation(mask, 1);
            !waitForIdle(1000, 1000);
            fade.

+cooldown(X) : true
        <-  .wait(6000);    // TODO 6 sec default cd?
            -cooldown(X).

+!waitForVisitor : true
        <-  .random(RANDOM);
            if(RANDOM > 0.66)
            {
                playanimation(hanging, 1);
            }
            else
            {
            if(RANDOM > 0.33)
            {
                playanimation(hanging, 2);
            }
            else
            {
                playanimation(hanging, 3);
            }
            }
            !waitForIdle(2000,250);
            !waitForVisitor.

+!donning : true
        <-  switchToIdle;
            !waitForIdle;
            playanimation(donning, 1);
            !waitForIdle(1000,250);
            .random(RAND);
            !spawnOffset(RAND * 4 + 1);
            !waitForIdle(1000,500);
            playanimation(donning, 2);
            !waitForIdle(2000,500);
            .random(RAND2);
            !spawnOffset(RAND2 * 4 + 1);
            !waitForIdle(1000,500);
            switchToGround;
            +onGround;
            !waitForIdle(1000,250);
            playanimation(donning, 2);
            !waitForIdle(2000,500);
            switchToCeiling;
            -onGround;
            !waitForIdle(1000,1000);
            !donning.

// back to screen -> bat moves to side
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == backtoscreen & phase(3) & not animating
        <-  +animating;
            switchToIdle;
            !waitForIdle;
            //playanimation(move_side);
            .random(RAND);
            !spawnOffset(RAND * 4 + 1);
            .wait(1000);
            switchToLive;
            .wait(2000);
            -animating.

// leans forward -> bat sails
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == leansforward & phase(3) & not animating
        <-  +animating;
            switchToIdle;
            !waitForIdle;
            !turnToScreen;
            playanimation(sail, 1);
            .wait(9000);            // TODO: hardcoded wait because waiting for idle is probably bad
            ?actorposition(ACTOR, ACX, ACY, ACZ);
            ?my_agent(AGENT);
            ?agentposition(AGENT, AGX, AGY, AGZ);
            if(distance_under(AGX, ACX, 1) & distance_under(AGZ, ACZ, 1))   // if bat is withing 1 meter of visitor (= above)
            {
                playanimation(sail, 2);
            }
            else
            {
                playanimation(land, 1);
            }
            !waitForIdle(1000,500);
            switchToCeiling;
            !waitForIdle(1000,500);
            //playanimation(move_side, 1);
            //!waitForIdle(1000,500);
            switchToLive;
            .wait(2000);
            -animating.

// arms to side -> bat falls
+actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == armstoside & phase(3) & not animating & not cooldown(fall)
        <-  +animating;
            switchToIdle;
            !waitForIdle;
            !turnToScreen;
            playanimation(fall, 1);
            .wait(2000);            // TODO: hardcoded wait because waiting for idle is probably bad
            ?actorposition(ACTOR, ACX, ACY, ACZ);
            ?my_agent(AGENT);
            ?agentposition(AGENT, AGX, AGY, AGZ);
            if(distance_under(AGX, ACX, 1) & distance_under(AGZ, ACZ, 1))   // if bat is withing 1 meter of visitor (= above)
            {
                playanimation(hit_visitor, 1);
                !waitForIdle(1000,500);
                switchToCeiling;    // TODO ?
                //!waitForIdle;
                //playanimation(move_side, 1);
            }
            else
            {
                playanimation(fall, 2);
            }
            !waitForIdle(1000,500);
            switchToLive;
            .wait(2000);
            +cooldown(fall);
            -animating.

// actor close to screen -> bat reaches out
+actordistancetoscreen(ACTOR, DISTANCE) : my_actor(ACTOR) & DISTANCE < 50 & phase(3) & not animating
        <-  +animating;
            switchToIdle;
            !waitForIdle;
            !turnToScreen;
            playanimation(reach, 1);
            !waitForIdle(1000,250);
            if(actorstate(ACTOR, reachup))
            {
                playanimation(reach, 2);
                !waitForIdle;
                playanimation(hug, 1);
                //!waitForIdle(1000,500);
                //playanimation(move_side, 1);
            }
            else
            {
                playanimation(reach, 3);
            }
            !waitForIdle(1000,500);
            switchToLive;
            .wait(2000);
            -animating.

+!turnToScreen : true
        <-  ?my_agent(AGENT);
            ?agentposition(AGENT, X, Y, Z);
            if(camerapos(CX,CZ))
            {
               moveTo(X,Z,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(X,Z,0,-3);              // look into camera
            }
            !waitForIdle(1000,500).

+!spawnOffset(N) : true
        <-  for( .range(I, 1, N) )
            {
                !spawnOffset;
            } .

+!spawnOffset : true
        <-  ?offsets(COUNT);
            -+offsets(COUNT+1);
            ?my_agent(AGENT);
            ?agentposition(AGENT, X, Y, Z);
            .random(RAND);
            .random(RAND2);
            .random(RAND3);
            spawnOffset(1001 + COUNT, X + (RAND*4 - 2), Z + RAND2 * 10, RAND3 * 0.5 + 0.5);
            .concat("offset_agent", 1001+COUNT, AGNAME);
            +active_agent(1001 + COUNT, AGNAME);
            .create_agent(AGNAME, "offsetAgent.asl");
            .my_name(MYNAME);
            .send(AGNAME, tell, master(MYNAME));
            .wait(250);
            .send(AGNAME, tell, timeout(30000));
            .send(AGNAME, achieve, run);
            .print("created agent: ", AGNAME);
            .wait(250).

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
