bound_left(-2).             // bounds to the left side (world coordinates)
bound_right(2).             // bounds to the right side (world coordinates)

clapping_cooldown(5000).    // minimum time period between clapping

t_welcome1(3000).
t_thankyou1(2000).
t_welcome2(18000).
t_welcome3(12000).
t_welcome4(7000).
t_random_min(4000).         // time in between spoken sentences (minimum)
t_random_max(12000).        // time in between spoken sentences (maximum)

t_before_emancipation(10000).

prev_actorscaling(0).

checkpoint1(2,2).
checkpoint2(-2,2).
checkpoint3(2,-2).
checkpoint4(-2,-2).

checkpointRadius(0.8).

breakoutRadius(0.6).    // distance to move per second to be considered moving
moveChecksPerSecond(10).

speed_dontex(1).        // general speed for donning textures
t_dontex1(10000).
t_dontex2(10000).
t_dontex3(10000).
t_dontex4(10000).
t_dontex5(10000).
t_dontex6(10000).
t_dontex7(10000).
t_dontex8(10000).
t_dontex9(10000).
t_dontex10(10000).


// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).


// === GOALS ===
!start.

// === PLANS ===

+!start : true
    <-  .wait(250);
        +welcoming;
        !!playWelcomeAudio;
        !!spawnOffset(1001, -0.5, 0);
        !!spawnOffset(1002, 0.5, 0);
        !!spawnOffset(1003, -2, 0);
        !!spawnOffset(1004, 2, 0);
        switchToSwapping;
        .wait(my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE >= 1);
        //!donning;
        //switchToSwapping;
        !goLive;
        //!!walkInOffsets;
        !!walkAroundOffsets;
        ?actorposition(ACTOR,X,Y,Z);
        +lastposition(X,Z);
        +movement(0);
        !!checkMovement;
        ?t_before_emancipation(TBE);
        .wait(TBE);
        !moveAround.

+!playWelcomeAudio : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS >=1
    <-  .print("skipping welcome audio because scaling already finished").

+!playWelcomeAudio : my_actor(ACTOR) & ((actorscaling(ACTOR, AS) & AS < 1) | not actorscaling(ACTOR, _))
    <-  playsound(welcome1);
        ?t_welcome1(T);
        .wait(T);
        playsound(welcome2);
        +lastsound(welcome2);
        ?t_welcome2(T2);
        .wait(T2);
        !waitRandomTime;
        !welcomeAudioLoop.

+!welcomeAudioLoop : welcoming
    <-  .random(RAND);
        !playWelcome(RAND).

+!welcomeAudioLoop : not welcoming.

+!playWelcome(R) : R > 0.6 & not lastsound(welcome4)
    <-  playsound(welcome4);
        -+lastsound(welcome4);
        ?t_welcome4(T);
        .wait(T);
        !waitRandomTime;
        !welcomeAudioLoop.

+!playWelcome(R) : R > 0.3 & not lastsound(welcome3)
    <-  playsound(welcome3);
        -+lastsound(welcome3);
        ?t_welcome3(T);
        .wait(T);
        !waitRandomTime;
        !welcomeAudioLoop.

+!playWelcome(R) : not lastsound(welcome2)
    <-  playsound(welcome1);
        -+lastsound(welcome1);
        ?t_welcome1(T1);
        .wait(T1);
        playsound(welcome2);
        -+lastsound(welcome2);
        ?t_welcome2(T);
        .wait(T);
        !waitRandomTime;
        !welcomeAudioLoop.

+!playWelcome(R) : true
    <-  .wait(100);
        !welcomeAudioLoop.

//+actorscaling(ACTOR, AS) : my_actor(ACTOR) & welcoming & AS > 0
+startintrodonning : welcoming
    <-  -welcoming;
        switchToSwapping;
        !!standbyOffsets;
        //.drop_desire(playWelcomeAudio);
        playsound(thankyou1, 1);
        ?t_thankyou1(T);
        .wait(T);
        //playsound(advise1);
        +donning;
        !new_donning.

+!new_donning : true    // TODO remove hausnummern
    <-  moveTo(10,0);
        //!lookIntoCamera;
        ?speed_dontex(SDT);
        ?t_dontex1(DT1);
        ?t_dontex2(DT2);
        ?t_dontex3(DT3);
        ?t_dontex4(DT4);
        ?t_dontex5(DT5);
        ?t_dontex6(DT6);
        ?t_dontex7(DT7);
        ?t_dontex8(DT8);
        ?t_dontex9(DT9);
        ?t_dontex10(DT10);
        displayTexture(donning01, DT1*SDT/1000);
        .wait(DT1*SDT);
        displayTexture(donning02, DT2*SDT/1000);
        .wait(DT2*SDT);
        displayTexture(donning03, DT3*SDT/1000);
        .wait(DT3*SDT);
        displayTexture(donning04, DT4*SDT/1000);
        .wait(DT4*SDT);
        displayTexture(donning05, DT5*SDT/1000);
        .wait(DT5*SDT);
        displayTexture(donning06, DT6*SDT/1000);
        moveTo(0,0);
        .wait(DT6*SDT);
        playanimation(donning_shadow, 1);
        !waitForIdle(1000,1000);
        moveTo(10,0);
        displayTexture(donning07, DT7*SDT/1000);
        .wait(DT7*SDT);
        displayTexture(donning08, DT8*SDT/1000);
        .wait(DT8*SDT);
        displayTexture(donning09, DT9*SDT/1000);
        .wait(DT9*SDT);
        displayTexture(donning10, DT10*SDT/1000);
        .wait(DT10*SDT);
        // start scaling here
        .



+actorscaling(ACTOR, AS) : my_actor(ACTOR) & donning & AS >= 1
    <-  -donning;
        playsound(thankyou2, 1).

+!donning : my_actor(ACTOR) & (not actorscaling(ACTOR, _) | actorscaling(ACTOR, 0))
            & my_agent(AGENT) & agentstate(AGENT, idle)
    <-  !lookIntoCamera;
        playanimation(prepare_for_sleep, 1);
        .wait(500);
        !donning.

+!donning : my_actor(ACTOR) & (not actorscaling(ACTOR, _) | actorscaling(ACTOR, 0))
            & my_agent(AGENT) & agentstate(AGENT, idle)
    <-  .random(R);
        ?bound_left(BL);
        ?bound_right(BR);
        moveTo(BL + (BR-BL)*R, 0);
        !waitForIdle(1000,500);
        !donning.

+!donning : my_actor(ACTOR) & (not actorscaling(ACTOR, _) | actorscaling(ACTOR, 0))
            & my_agent(AGENT) & agentstate(AGENT, idle)
    <-  .wait(200);
        !donning.

+!donning : my_actor(ACTOR) & (not actorscaling(ACTOR, _) | actorscaling(ACTOR, 0))
            & my_agent(AGENT) & not agentstate(AGENT, idle)
    <-  .wait(500);
        !donning.

+!donning : my_actor(ACTOR) & actorscaling(ACTOR, AS) & prev_actorscaling(PAS) & AS > PAS & not clapCD
    <-  playanimation(clap, 1);
        -+prev_actorscaling(AS);
        +clapCD;
        !!clapCD;
        !waitForIdle;
        !donning.

+!clapCD : true
    <-  ?clapping_cooldown(T);
        .wait(T);
        -clapCD.

+!donning : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS > 0 & AS < 1
        & my_agent(AGENT) & agentstate(AGENT, idle)
    <-  !lookIntoCamera;
        playanimation(donning_shadow, 1);
        .wait(500);
        +playedDonningAnimation;
        -+prev_actorscaling(AS);
        !donning.

+!donning : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS > 0 & AS < 1 & prev_actorscaling(PAS) & PAS == AS
        & my_agent(AGENT) & agentstate(AGENT, idle) & playedDonningAnimation
    <-  !lookIntoCamera;
        playanimation(request_donning, 1);
        playsound(advise2, 1);
        .wait(500);
        -playedDonningAnimation;
        !donning.

+!donning : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS > 0 & AS < 1
        & my_agent(AGENT) & not agentstate(AGENT, idle)
    <-  .wait(500);
        !donning.

+!donning : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS >= 1
    <-  .print("finished donning").

-!donning : my_actor(ACTOR) & (not actorscaling(ACTOR,_) | (actorscaling(ACTOR, AS) & AS < 1))
    <-  .print("scaling not finished, but donning goal dropped. restarting.");
        !start.


+!goLive : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS < 1
   <-  .print("goLive reached, but scaling not finished. restarting.");
       !start.

+!goLive : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS >= 1
    <-  switchToLive.

+!moveAround : movement(M) & M > 0
    <-  .wait(500);
        !moveAround.

@leerlauf[chance(30)]
+!moveAround : movement(M) & M == 0
    <-  .wait(500);
        !moveAround.

@move[chance(1)]
+!moveAround : movement(M) & M == 0
    <-  .random(R);
        ?bound_left(BL);
        ?bound_right(BR);
        moveTo(BL + (BR-BL)*R, 0);
        !waitForIdle(1000,500);
        !keepMoving;
        switchToLive;
        .wait(3000);
        !moveAround.

+!keepMoving : movement(M) & M > 0.

@randomMovement[chance(5)]
+!keepMoving : movement(M) & M == 0
    <-  .random(R);
        ?bound_left(BL);
        ?bound_right(BR);
        moveTo(BL + (BR-BL)*R, 0);
        .random(R2);
        !waitForIdle(1000,1000 + R2 * 3000);
        !keepMoving.

@lookIntoCam[chance(1)]
+!keepMoving : movement(M) & M == 0
    <-  !lookIntoCamera;
        .random(R2);
        !waitForIdle(1000,1000 + R2 * 3000);
        !keepMoving.

+!checkMovement : lastposition(LX,LZ) & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & breakoutRadius(R)
        & moveChecksPerSecond(CPS) & (not distance_under(LX, X, R/CPS) | not distance_under(LZ, Z, R/CPS))
    <-  ?movement(M);
        -+movement(M+1);
        -+lastposition(X,Z);
        .wait(1000/CPS);
        !!checkMovement.

+!checkMovement : lastposition(LX,LZ) & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & breakoutRadius(R)
        & moveChecksPerSecond(CPS) & distance_under(LX, X, R/CPS) & distance_under(LZ, Z, R/CPS)
    <-  ?movement(M);
        -+movement(M/2 - 1);
        -+lastposition(X,Z);
        .wait(1000/CPS);
        !!checkMovement.

+movement(M) : M < 0
    <-  -+movement(0).

+!waitRandomTime : true
    <-  ?t_random_min(TRMIN);
        ?t_random_max(TRMAX);
        .random(RAND);
        .print("waiting: ", TRMIN + (TRMAX-TRMIN)*RAND, " ms.");
        .wait(TRMIN + (TRMAX-TRMIN)*RAND).


+actorposition(ACTOR, X, _, Y) : not check1 & my_actor(ACTOR) &  checkpointRadius(R) &
        checkpoint1(C1X,C1Y) & distance_under(X,C1X,R) & distance_under(Y,C1Y,R)
    <-  +check1;
        .print("checkpoint 1 reached").

+actorposition(ACTOR, X, _, Y) : not check2 & my_actor(ACTOR) &  checkpointRadius(R) &
        checkpoint1(C2X,C2Y) & distance_under(X,C2X,R) & distance_under(Y,C2Y,R)
    <-  +check2;
        .print("checkpoint 2 reached").

+actorposition(ACTOR, X, _, Y) : not check3 & my_actor(ACTOR) &  checkpointRadius(R) &
        checkpoint1(C3X,C3Y) & distance_under(X,C3X,R) & distance_under(Y,C3Y,R)
    <-  +check3;
        .print("checkpoint 3 reached").

+actorposition(ACTOR, X, _, Y) : not check4 & my_actor(ACTOR) &  checkpointRadius(R) &
        checkpoint1(C4X,C4Y) & distance_under(X,C4X,R) & distance_under(Y,C4Y,R)
    <-  +check4;
        .print("checkpoint 4 reached").


+!spawnOffset(NR, X, Y) : true
        <-  ?my_agent(AGENT);
            spawnOffset(NR, X, Y, 1);
            .concat("sleeperOffset", NR, AGNAME);
            +active_agent(AGNAME);
            .create_agent(AGNAME, "170307_sleeperOffset.asl");
            .send(AGNAME, achieve, run);
            .print("created agent: ", AGNAME).

+!killOffsets : active_agent(AGNAME)
    <-  .send(AGNAME, achieve, walkOut);
        -active_agent(AGNAME);
        !!killOffsets;
        .wait(10000);
        .send(AGNAME, achieve, die).

+!killOffsets : not active_agent(_).

+!standbyOffsets : active_agent(AGNAME) & not standby_agent(AGNAME)
    <-  .send(AGNAME, achieve, walkOut);
        +standby_agent(AGNAME);
        !!standbyOffsets.

+!standbyOffsets : not (active_agent(AGNAME) & not standby_agent(AGNAME)).

+!walkInOffsets : active_agent(AGNAME) & standby_agent(AGNAME)
    <-  .send(AGNAME, achieve, walkIn);
        -standby_agent(AGNAME);
        !!walkInOffsets.

+!walkInOffsets : not (active_agent(AGNAME) & standby_agent(AGNAME)).

+!walkAroundOffsets : active_agent(AGNAME) & not walking_agent(AGNAME)
    <-  .send(AGNAME, achieve, walkAround);
        +walking_agent(AGNAME);
        !!walkAroundOffsets.

+!walkAroundOffsets : not (active_agent(AGNAME) & not walking_agent(AGNAME)).


// === NOT AGENT SPECIFIC PLANS ===

+!lookIntoCamera : camerapos(CX,CZ) & my_actor(ACTOR)
    <-  ?agentposition(AGENT, X, Y, Z);
        moveTo(X,Z, CX,CZ);
        !waitForIdle(1000,500).

+!lookIntoCamera : not camerapos(_, _) & my_actor(ACTOR)
    <-  ?agentposition(AGENT, X, Y, Z);
        moveTo(X,Z, 0,-3);
        !waitForIdle(1000,500).

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
