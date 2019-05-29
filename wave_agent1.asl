// === INITIAL BELIEFS ===

attitude(normal).                   // describes the current mental attitude of the agent,
                                    // eg normal, sad, happy, etc.


// === RULES ===

// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

// === INITIAL GOALS ===

// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

// plan for phase 1: go live for ~60 seconds, then wait for agent B to do the same.
// Then wave 3 times at agent B. (waiting ~20 secs each time).
// Afterwards, proceed to phase 2.
+!phase(1) : true
                    <-  !liveFor(5, 2);     // DEBUG: 5+2 seconds instead of 50+20
                        !waitForAgentB;
                        !exchangeInformation;
                        ?other_agent(OTHER_AGENT);
                        !waveTo(OTHER_AGENT);
                        !waitForIdle;
                        !liveFor(5, 1);     // DEBUG 5+1 instead of 20
                        !waveTo(OTHER_AGENT);
                        !waitForIdle;
                        !liveFor(5, 1);     // DEBUG 5+1 instead of 20
                        !waveTo(OTHER_AGENT);
                        !waitForIdle;
                        switchToLive;
                        !waitForLive;
                        -agentB_ready[_];
                        +phase(2);
                        -phase(1).

// plan for phase 2: go idle for a second, then wave to the camera.
// then wait for a reaction from the actor (see !waitForSingleWave)
+!phase(2) : true
                    <-  .print("Entered phase 2.");
                        .send(wave_agent2, achieve, initphase(2));
                        switchToIdle;
                        !waitForIdle;
                        -+wavesToCamera(0);
                        !waveToCamera(1);
                        !waitForIdle;
                        !waitForSingleWave.

// wave into the camera (position assumed to be at 0,0,-3) using the given wave animation id
+!waveToCamera(ID) : true
                    <-  ?wavesToCamera(N);
                        -+wavesToCamera(N+1);
                        ?my_agent(AGENT);
                        ?agentposition(AGENT, X, Y, Z);
                        if(camerapos(CX,CZ))
                        {
                           moveTo(X,Z,CX,CZ);              // look into camera
                        }
                        else
                        {
                            moveTo(X,Z,0,-3);              // look into camera
                        }
                        !waitForIdle(500,500);
                        playanimation(wave,ID).


// if an actor waves back -> clap to acknowledge success, then let both agents wave into the camera
// and wait for both actors to wave back (!waitForDoubleWave)
+!waitForSingleWave : actorWaved(_, _)
                    <-  playanimation(clap,1);
                        .send(wave_agent2, achieve, clap);
                        !waitForIdle(500,1000);
                        .send(wave_agent2, achieve, waveToCamera(1));
                        -+wavesToCamera(0);
                        !waveToCamera(1);
                        !waitForIdle;
                        !waitForDoubleWave.

// if the waiting time reaches 5 seconds (50 * 100 ms), talk to b, teach to wave and then try again
+!waitForSingleWave : timeout_sw(T) & T > 50 & wavesToCamera(N) & N <=3
                    <-  !talkToB;
                        !waitForIdle(500,1000);
                        !teachToWave;
                        !waitForIdle(500,1000);
                        !waveToCamera(1);
                        !waitForIdle;
                        -timeout_sw(_);
                        !waitForSingleWave.

// waiting process for a reaction from an actor
+!waitForSingleWave : timeout_sw(T) & wavesToCamera(N) & N <=3
                    <-  -+timeout_sw(T+1);
                        .wait(100);
                        !waitForSingleWave.

+!waitForSingleWave : wavesToCamera(N) & N <= 3 & not timeout_sw(_) & wavesToCamera(N) & N <=3
                    <-  +timeout_sw(1);
                        .wait(100);
                        !waitForSingleWave.

// if the agent gets no reactions after the 4th wave, he gets sad and stops trying
+!waitForSingleWave : wavesToCamera(N) & N > 3
                    <-  .print("I'm sad now. No one waves back to me...");
                        -+attitude(sad);
                        switchToIdle;
                        !waitForIdle;
                        fade;               // TODO: ?
                        -phase(2).

// if both actors wave back -> success (phase 2 complete)
+!waitForDoubleWave : my_actor(ACTOR) & other_actor(ACTORB) &
                        actorWaved(ACTOR, _) & actorWaved(ACTORB, _)
                    <-  .print("finished phase 2");
                        !celebrate;
                        -phase(2).

// if the waiting time reaches 5 seconds (50 * 100 ms), wave angrier
+!waitForDoubleWave : timeout_dw(T) & T > 50 & wavesToCamera(N) & N <=3
                    <-  .send(wave_agent2, achieve, waveToCamera(2));
                        !waveToCamera(2);
                        !waitForIdle;
                        -timeout_dw(_);
                        !waitForDoubleWave.

// waiting process for a reaction from both actors
+!waitForDoubleWave : timeout_dw(T) & wavesToCamera(N) & N <=3
                    <-  -+timeout_dw(T+1);
                        .wait(100);
                        !waitForDoubleWave.

+!waitForDoubleWave : wavesToCamera(N) & N <= 3 & not timeout_dw(_) & wavesToCamera(N) & N <=3
                    <-  +timeout_dw(1);
                        .wait(100);
                        !waitForDoubleWave.

// if the agent gets no reactions after the 4th wave, he gets sad and stops trying
+!waitForDoubleWave : wavesToCamera(N) & N > 3
                    <-  .print("I'm sad now. They dont wave back at us...");
                        -+attitude(sad);
                        .send(wave_agent2, achieve, sad);
                        fade;               // TODO: ?
                        -phase(2).

+!talkToB : true
                    <-  .send(wave_agent2, achieve, talkToA);
                        ?my_agent(AGENT);
                        ?other_agent(AGENTB);
                        ?agentposition(AGENT, X, Y, Z);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        moveTo(X,Z, XB,ZB);
                        !waitForIdle;
                        playanimation(talk, 1).

+!teachToWave : true
                    <-  .send(wave_agent2, achieve, lookAtA);
                        ?my_agent(AGENT);
                        ?other_agent(AGENTB);
                        ?agentposition(AGENT, X, Y, Z);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        moveTo(X,Z, XB,ZB);
                        !waitForIdle;
                        playanimation(teachToWave, 1);
                        .wait(2000);        // displacement between animations of agents = 2 sec
                        .send(wave_agent2, achieve, teachToWave).

// exchanges information about actors and agents with the other wave_agent
+!exchangeInformation : my_actor(ACTOR) & my_agent(AGENT)
                    <-  .send(wave_agent2, tell, other_actor(ACTOR));
                        .send(wave_agent2, tell, other_agent(AGENT));
                        .send(wave_agent2, askOne, my_agent(_), AgentB);
                        +agentb(AgentB);
                        ?agentb(my_agent(OTHER_AGENT));
                        +other_agent(OTHER_AGENT);
                        -agentb(_);
                        .send(wave_agent2, askOne, my_actor(_), ActorB);
                        +actorb(ActorB);
                        ?actorb(my_actor(OTHER_ACTOR));
                        +other_actor(OTHER_ACTOR);
                        -actorb(_).

// waits for Agent B until belief agentB_ready is achieved (when Agent B has been live for ~60 sec)
+!waitForAgentB : not agentB_ready
                    <-  .wait(250);
                        !waitForAgentB.

+!waitForAgentB : agentB_ready .

// tries to perform a waving animation towards the other agent.
// if the agents are too close together on the screen and 3 seconds pass without them separating,
// the agent decides to move away from the other agent and perform the waving animation afterwards.
+!waveTo(TARGET) :  other_agent(TARGET) &
                    my_agent(AGENT) &
                    agentposition(AGENT, XA, YA, ZA) &
                    agentposition(TARGET, XB, YB, ZB) &
                    not distance_under(XA,XB,1.1)
                    <-  -wave_try(_);
                        moveTo(XA, ZA, XB, ZB);
                        !waitForIdle(2000,1000);
                        waveTo(TARGET, 1).

+!waveTo(TARGET) :  other_agent(TARGET) & wave_try(N) & N >= 3
                    <-  -+wave_try(N+1);
                        ?agentposition(TARGET, XB, YB, ZB);
                        .print("Im moving away...");
                        ?my_agent(AGENT);
                        ?agentposition(AGENT, XA, YA, ZA);
                        if(XA == XB)
                        {
                            if(cameraborder(CB1, CB2) & XA+2 >= CB2-0.5)
                            {
                                moveTo(XA-2, ZA);     // move away from other agent
                            }
                            else
                            {
                                moveTo(XA+2, ZA);     // move away from other agent
                            }
                        }
                        else
                        {
                            if(cameraborder(CB1, CB2) & (XA+(XA-XB) >= CB2-0.5 | XA+(XA-XB) <= CB1+0.5))
                            {
                                moveTo(XA-(XA-XB), ZA);     // move away from other agent
                            }
                            else
                            {
                                moveTo(XA+(XA-XB), ZA);     // move away from other agent
                            }
                        }
                        !waitForIdle(2000,1000);
                        !waveTo(TARGET).

+!waveTo(TARGET) :  other_agent(TARGET) & wave_try(N) & N < 3
                    <-  -+wave_try(N+1);
                        .wait(1000);
                        !waveTo(TARGET).

+!waveTo(TARGET) :  other_agent(TARGET)
                    <-  .print("I'm too close to wave at ", TARGET);
                        +wave_try(1);
                        .wait(1000);
                        !waveTo(TARGET).

// if not in a phase, and actorscaling is finished, enter phase 1
+actorscaling(ACTOR,VALUE) : my_actor(ACTOR) & VALUE == 1 & not phase(_)
                    <-  +phase(1).

// if the other actor starts waving while in phase 1, celebrate and skip to phase 2.
+actorstate(ACTOR, STATE) : other_actor(ACTOR) & STATE == wave & agentB_ready & phase(1)
                    <- 	!celebrate;
                        -phase(1);
                        +phase(2);
                        .drop_desire(phase(1)).

// logs waves received from actors for 3 seconds (in actorWaved(actorname)), phase 2 only
+actorstate(ACTOR, STATE) : STATE == wave & phase(2)
                    <-  .drop_desire(countDownActorWaved(ACTOR));
                        +actorWaved(ACTOR);
                        !!countDownActorWaved(ACTOR).

+!countDownActorWaved(ACTOR) : true
                    <-  .wait(3000);
                        -actorWaved(ACTOR).

// change attitude to happy, play a celebration animation and tell agent B to do the same
+!celebrate : true
                    <-  .print("yaay");
                        -+attitude(happy);
                        .send(wave_agent2, achieve, celebrate);
                        playanimation(cheer,1);
                        !waitForIdle;
                        switchToLive;
                        !waitForLive.


// === NOT AGENT SPECIFIC PLANS ===

// introduces the agent (AI) at the start or after an actor change
+my_actor(ACTOR) : my_agent(AGENT)
					<- 	.my_name(NAME);
						.print("I am ", NAME, ", I watch ", ACTOR, " and I control ", AGENT, ".").

// documents attitude changes
+attitude(A) : true
                    <-  .print("New attitude: ", A, ".").

-attitude(A) : true
                    <-  .print("Lost attitude: ", A, ".").

// goes into live state for at least TIME (parameter) 10 seconds; does not switch back after finish
+!liveFor(TIME) : true
                    <-  switchToLive;
                        !waitForLive;
                        .wait(TIME * 1000);
                        .print("was live for ", TIME, " seconds").

// goes into live state for TIME (parameter) + up to EXTRA (parameter) seconds; does not switch back after finish
+!liveFor(TIME, EXTRA) : true
                    <-  switchToLive;
                        !waitForLive;
                        .random(RAND);
                        .wait((TIME + RAND * EXTRA) * 1000);
                        .print("was live for ", (TIME + RAND * EXTRA), " seconds").


// default waitForIdle = wait 1/4 second, then wait until agent is idle, then wait another 1/4 second
+!waitForIdle : true
                    <-  .wait(250);
                        if(my_agent(AGENT) & not agentstate(AGENT, idle))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, idle));
                        }
                        .wait(250).

// waitForIdle with 1 parameter = wait for N miliseconds, then wait until agent is idle, then wait another 1/4 second
+!waitForIdle(N) : true
                    <-  .wait(N);
                        if(my_agent(AGENT) & not agentstate(AGENT, idle))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, idle));
                        }
                        .wait(250).

// waitForIdle with 2 parameters = wait for N miliseconds, then wait until agent is idle
// then wait another M miliseconds
+!waitForIdle(N,M) : true
                    <-  .wait(N);
                        if(my_agent(AGENT) & not agentstate(AGENT, idle))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, idle));
                        }
                        .wait(M).

// default waitForLive = wait 1/4 second, then wait until agent is live, then wait another 1/4 second
+!waitForLive : true
                    <-  .wait(250);
                        if(my_agent(AGENT) & not agentstate(AGENT, live))
                        {
                            .wait(my_agent(AGENT) & agentstate(AGENT, live));
                        }
                        .wait(250).

/*
// DEPRECATED

// waits for the own agent to be idle, waits 100 ms and then tries again (~agent has to be idle for more than 100 ms)
+!waitForIdle : true
                    <-  !waitForIdle_short;
                        .wait(100);
                        !waitForIdle_short.

// waits for the own agent to be put into idle state
+!waitForIdle_short : my_agent(AGENT) & not agentstate(AGENT, idle)
                    <-  .print("waiting for agent ", AGENT, " to go idle ... [zzz]");
                        .wait(500);
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
                        .wait(500);
                        !waitForLive_short.

+!waitForLive_short : my_agent(AGENT) & agentstate(AGENT, live) .

*/