// === INITIAL BELIEFS ===

// === RULES ===

// === INITIAL GOALS ===

!introduce.

// === PLANS ===

+!introduce : true
        <-  .print("Hi i am a testing agent.").


+actorstate(ACTOR, STATE) : STATE == handstogether
        <-  .print("initiating playback 1");
            !playback1.

+!playback1 : not playing
        <-  +playing;
            switchToIdle;       // start idle
            !waitForIdle;
            .wait(1000);
            moveTo(1,1,0,0);    // move to 1,1 turn to 0,0
            !waitForIdle;
            .wait(1000);
            switchToLive;       // go live
            !waitForLive;
            .wait(2000);
            switchToIdle;       // go idle
            !waitForIdle;
            lookAt(0,0,0,true); // look at 0,0,0 if possible
            .wait(1000);
            moveTo(2,2);        // move to 2,2
            !waitForIdle;
            moveTo(3,0);        // move to 3,0
            !waitForIdle;
            wave(1);            // play animations - wave, cheer, headscratch
            .wait(1000);
            cheer(1);
            !waitForIdle;
            headscratch(i);
            !waitForIdle;
            moveTo(3,0,1,1);    // turn toward 1,1
            !waitForIdle;
            moveTo(3,0,-1,-1);  // turn toward -1,-1
            !waitForIdle;
            switchToLive;
            lookAt(0,0,0,false);// turn off lookat
            -playing.

+!playback1 : playing
        <-  .print("already playing").




// waits for the own agent to be idle, waits 100 ms and then tries again (~agent has to be idle for more than 100 ms)
+!waitForIdle : true
                    <-  !waitForIdle_short;
                        .wait(100);
                        !waitForIdle_short.

// waits for the own agent to be put into idle state
+!waitForIdle_short : my_agent(AGENT) & not agentstate(AGENT, idle)
                    <-  .print("waiting for agent ", AGENT, " to go idle ... [zzz]");
                        .wait(500);             // TODO: set fitting sleep interval
                        !waitForIdle_short.

+!waitForIdle_short : my_agent(AGENT) & agentstate(AGENT, idle) .


// waits for the own agent to be live, waits 100 ms and then tries again (~agent has to be live for more than 100 ms)
+!waitForLive : true
                    <-  !waitForLive_short;
                        .wait(100);
                        !waitForLive_short.

// waits for the agent to be put into live state
+!waitForLive_short : my_agent(AGENT) & not agentstate(AGENT, live)
                    <-  .print("waiting for agent ", AGENT, " to go live ... [zzz]");
                        .wait(500);             // TODO: set fitting sleep interval
                        !waitForLive_short.

+!waitForLive_short : my_agent(AGENT) & agentstate(AGENT, live) .



/*
// handstogether above head -> go live (mirror)
+actorstate(ACTOR, STATE) : STATE == handstogether & actorstate(ACTOR, righthandaboveheadheight) & actorstate(ACTOR, lefthandaboveheadheight)
        <-  .print("got handstogether above head; switching to live");
            switchToLive.

// handstogether below head -> go idle (stand still)
+actorstate(ACTOR, STATE) : STATE == handstogether & not actorstate(ACTOR, righthandaboveheadheight) & not actorstate(ACTOR, lefthandaboveheadheight)
        <-  .print("got handstogether below head; switching to idle");
            switchToIdle.

// pointing left -> move actor to your position (expected afterwards: idle)
+actorstate(ACTOR, STATE) : STATE == pointingleft & not actorstate(ACTOR, pointingright)
        <-  .print("got pointing left; moving agent to your position");
            ?actorposition(ACTOR, X, Y, Z);
            moveTo(X,Z).

// pointing right -> move actor to 0,0 (expected afterwards: idle)
+actorstate(ACTOR, STATE) : STATE == pointingright & not actorstate(ACTOR, pointingleft)
        <-  .print("got pointing right; moving agent to 0,0");
            moveTo(0,0).

// right hand raised -> toggle lookat your position
+actorstate(ACTOR, STATE) : STATE == righthandaboveheadheight & not actorstate(ACTOR, lefthandaboveheadheight) & not looking
        <-  .print("got right hand raised; agent is looking at you.");
            ?actorposition(ACTOR, X, Y, Z);
            lookAt(X,Y,Z,true);
            +looking.

+actorstate(ACTOR, STATE) : STATE == righthandaboveheadheight & not actorstate(ACTOR, lefthandaboveheadheight) & looking
        <-  .print("got right hand raised; agent stopped looking at you.");
            lookAt(0,0,0,false);
            -looking.

// left hand raised -> agent turns toward you
+actorstate(ACTOR, STATE) : STATE == lefthandaboveheadheight & not actorstate(ACTOR, righthandaboveheadheight)
        <-  .print("got left hand raised; agent is turning toward you.");
            ?actorposition(ACTOR, X, Y, Z);
            ?agentposition(agent0, X2, Y2, Z2);        //NOTE: agent0 = hardcode
            moveTo(X2, Z2, X, Z).

// bow -> agent play animation (waving)
+actorstate(ACTOR, STATE) : STATE == bow
        <-  .print("got bow; agent is waving.");
            wave(1).
*/