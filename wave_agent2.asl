// === INITIAL BELIEFS ===

wavesFromA(0).                      // counts the number of perceived waves from agent A
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

// plan for phase 1: go live for ~60 sec, then tell agent A that I'm ready. the rest is reactive.
+!phase(1) : true
                    <-  -+wavesFromA(0);
                        !liveFor(5,2);     // DEBUG: 5+2 instead of 50+20 seconds
                        .send(wave_agent1, tell, agentB_ready).

// plan for phase 2: (completely controlled by agent 1, agent 2 only has to react)
+!phase(2) : true
                    <-  .print("Entered phase 2.");
                        .drop_desire(react);
                        .drop_desire(wave_back).

// if not in a phase, and actorscaling is finished, enter phase 1
+actorscaling(ACTOR,VALUE) : my_actor(ACTOR) & VALUE == 1 & not phase(_)
                    <-  +phase(1).

// whenever agent A waves at me (agent B), increase the counter (phase1 only)
+wave(A,B) : my_agent(B) & other_agent(A) & phase(1)
                    <-  ?wavesFromA(COUNT);
                        -+wavesFromA(COUNT + 1).

// if the counter is less then 2, do nothing
+wavesFromA(COUNT) : COUNT < 2
                    <-  .print("Agent A waved at me ", COUNT, " times.").

// if the counter equals 2, look at the other agent
+wavesFromA(COUNT) : COUNT == 2
                    <-  .print("Agent A waved at me ", COUNT, " times. (looking)");
                        !react.
+!react : phase(1)
                    <-  ?other_agent(AGENTA);
                        ?agentposition(AGENTA, XA, YA, ZA);
                        ?my_agent(AGENTB);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        lookAt(XA, YA * 2, ZA, true);
                        moveTo(XB, ZB, XA, ZA);
                        !waitForIdle(500,1000);
                        playanimation(headscratch,1);
                        !waitForIdle(500,500);
                        switchToLive.

// if the counter is 3 or more, wave back at agent A
+wavesFromA(COUNT) : COUNT >= 3
                    <-  .print("Agent A waved at me ", COUNT, " times. (waving back)");
                        !waveBack.

+!waveBack : phase(1)
                    <-  lookAt(0,0,0,false);
                        ?other_agent(AGENTA);
                        ?agentposition(AGENTA, X, Y, Z);
                        !waveTo(AGENTA);
                        !waitForIdle(500,500);
                        switchToLive.

// tries to perform a waving animation towards the other agent.
// if the agents are too close together on the screen and 3 seconds pass without them separating,
// the agent decides to move away from the other agent and perform the waving animation afterwards.
+!waveTo(TARGET) :  other_agent(TARGET) &
                    my_agent(AGENT) &
                    agentposition(AGENT, XA, YA, ZA) &
                    agentposition(TARGET, XB, YB, ZB) &
                    not distance_under(XA,XB,1.1)
                    <-  -wave_try(_);
                        moveTo(XA, ZA, XB, ZB); // turn towards the other agent
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
                            moveTo(XA+1, ZA);     // move away from other agent
                        }
                        else
                        {
                            moveTo(XA+(XA-XB), ZA);     // move away from other agent
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

+!initphase(2) : not phase(2)
                    <-  +phase(2);
                        -phase(1).

+!initphase(2): phase(2)
                    <-  .print("Agent A wants me to init phase 2, but I am already in phase 2 ???").

+!celebrate : true
                    <-  .print("yaay");
                        -+attitude(happy);
                        playanimation(cheer,1);
                        !waitForIdle;
                        switchToLive;
                        !waitForLive.

+!clap : true
                    <-  playanimation(clap,1);
                        !waitForIdle;
                        switchToLive.

+!sad : true
                    <-  .print("I'm sad now. They dont wave back at us...");
                        -+attitude(sad);
                        fade;               // TODO: ?
                        -phase(2).

+!waveToCamera(ID) : true
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
                        !waitForIdle;
                        playanimation(wave,ID);
                        !waitForIdle;
                        switchToLive.

+!lookAtA : true
                    <-  ?my_agent(AGENTB);
                        ?other_agent(AGENTA);
                        ?agentposition(AGENTA, XA, YA, ZA);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        moveTo(XB,ZB, XA,ZA).

+!talkToA : true
                    <-  ?my_agent(AGENTB);
                        ?other_agent(AGENTA);
                        ?agentposition(AGENTA, XA, YA, ZA);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        moveTo(XB,ZB, XA,ZA);
                        !waitForIdle(1500,500);
                        playanimation(talk, 1).

+!teachToWave : true
                    <-  ?my_agent(AGENTB);
                        ?other_agent(AGENTA);
                        ?agentposition(AGENTA, XA, YA, ZA);
                        ?agentposition(AGENTB, XB, YB, ZB);
                        moveTo(XB,ZB, XA,ZA);
                        !waitForIdle(1500,500);
                        playanimation(teachToWave, 1).


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
