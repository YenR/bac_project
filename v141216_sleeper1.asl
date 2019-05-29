// === INITIAL BELIEFS ===

phase(1).
/*
phase 1 = no visitor                            =   swapping
phase 2 = visitor detected (0 < scaling < 100)  =   swapping
phase 3 = scaling finished                      =   live, lay down
phase 4 = user lied down with agent             =   lying, live
phase f = user failed to lie down (sympathy=0)  =   distancing
*/

sympathy(50).
/*
    0       =   hateful         =   agent seeks distance from visitor
    1-49    =   antipathetic    =   agent turns away from visitor
    50      =   neutral         =
    51-99   =   sympathetic     =   agent turns towards visitor, zoom in
    100     =   loving          =   dream sequence while lying down

    ++  by lying down with agent while agent is sleeping
    ++  by being close to the screen or putting hands up when agent is distancing
    --  by not lying down with the agent while agent is sleeping
*/


// === PLANS ===

+phase(X) : true <- !phase(X).
-phase(X) : true <- .drop_desire(phase(X)).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0 & initiated
        <-  -phase(1);
            +phase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE >= 1 & initiated
        <-  -phase(2);
            +phase(3).

+!switchToPhase2 : true
        <-  .print("ready for phase 2 detected");
            -phase(_);
            +phase(2).

+!switchToPhase3 : true
        <-  .print("ready for phase 3 detected");
            -phase(_);
            +phase(3).

+!switchToPhase4 : true
    <-  -phase(_);
        -sleeping;
        .drop_desire(loopoctopus);
        setXRotation(0,100);
        playanimation(octopus, 3);  //TODO ??
        !waitForIdle(500,250);
        +phase(4).

+!switchtophasef : true
        <-  -phase(_);
            +phase(f).

+!phase(1) : true
        <-  switchToIdle;
            !waitForIdle(100,0);
            switchToGround;
            !waitForIdle(500,250);
            if(camerapos(CX,CZ))
            {
               moveTo(0,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(0,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,0);
            +initiated;
            if(my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE > 0)
            {
                !!switchToPhase2;
            }
            else
            {
                playanimation(walkupdown, 1);
                +swapping;
                !!walkupdown;
                switchToSwapping;
            }
            .

+!walkupdown : true
    <-  .wait(60000);
        if(camerapos(CX,CZ))
        {
           moveTo(0,0,CX,CZ);              // look into camera
        }
        else
        {
            moveTo(0,0,0,-3);              // look into camera
        }
        !waitForIdle(1000,0);
        playanimation(walkupdown, 1);
        !!walkupdown.

+!phase(2) : true
        <-  .print("phase 2 entered");
             if(my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE >= 1)
             {
                !!switchToPhase3;
             }
             .

+!phase(3) : true
        <-  switchToIdle;
            if(swapping)
            {
                .drop_desire(walkupdown);
                switchToSwapping;
                -swapping;
            }
            switchToLive;
            .wait(8000);
            if(my_actor(ACTOR) & actorstate(ACTOR, waistdown))
            {

            }
            else
            {
                 ?my_actor(ACTOR);
                 ?actorposition(ACTOR,X,Y,Z);
                 if(camerapos(CX,CZ))
                 {
                    moveTo(X,Z,CX,CZ);              // look into camera
                 }
                 else
                 {
                     moveTo(X,Z,0,-3);              // look into camera
                 }
                 !waitForIdle(1000,500);
                playanimation(octopus, 1);
                .wait(4200);
            }
            +sleeping;
            setXRotation(-90, 30);
            playanimation(octopus, 2, 0.25, 1);
            !!loopoctopus.

+!phase(4) : true
        <-  setXRotation(-90, 30);
            if(my_actor(ACTOR) & actorstate(ACTOR, waistdown))
            {

            }
            else
            {
                playanimation(octopus, 1);
                .wait(4200);
            }
            +sleeping;
            playanimation(octopus, 2, 0.25, 1);
            !!loopoctopus2.

+!phase(f) : true
    <-  .drop_desire(loopoctopus);
        -sleeping;
        setXRotation(0, 100);
        playanimation(octopus, 3);
        !waitForIdle(500,250);
        if(camerapos(CX,CZ))
        {
           moveTo(0,0,CX,-CZ);
        }
        else
        {
            moveTo(0,0,0, -3);
        }
        !waitForIdle(1000,500);
        //+onceiling;
        //switchToCeiling;
        //!waitForIdle(1000,250);
        if(camerapos(CX,CZ) & screenwidth(W))
        {
            moveTo(CX - W/2 + 1, 0, CX, -CZ);
        }
        else
        {
            moveTo(-1.5, 0, 0, -3);
        }
        !waitForIdle(1000,500);
        setXRotation(-90, 30);
        if(my_actor(ACTOR) & actorstate(ACTOR, waistdown))
        {

        }
        else
        {
            playanimation(octopus, 1);
            .wait(4200);
        }
        +sleeping;
        playanimation(octopus, 2, 0.25, 1);
        !!loopoctopus.

+!loopoctopus : true
    <-  .wait(200);
        ?sympathy(S);
        if(phase(f))
        {
            //.random(RANDOM);
            -+sympathy(S-1);//*RANDOM);
        }
        else
        {
            ?my_actor(ACTOR);
            ?actordistancetoscreen(ACTOR, DISTANCE);
            if(S < 35 & DISTANCE < 200)
            {
                //.random(RANDOM);
                -+sympathy(S+0.5);//*RANDOM);
            }
            else
            {
                if(DISTANCE < 300)
                {
                    //.random(RANDOM);
                    //-+sympathy(S-0.5*RANDOM);
                }
                else
                {
                    //.random(RANDOM);
                    -+sympathy(S-1);//*RANDOM);
                }
            }
        }
        !loopoctopus.

+!loopoctopus2 : true
    <-  .wait(200);
        //.random(RANDOM);
        ?sympathy(S);
        -+sympathy(S+0.1+1);//*RANDOM);
        if(S > 60 & not snoring & not dreaming & sleeping)
        {
            +snoring;
            playsound(snoring);
        }
        !loopoctopus2.

+actorstate(ACTOR, STATE) : sleeping & phase(3) & my_actor(ACTOR) & STATE == waistdown
    <-  .wait(1000);
        if(actorstate(ACTOR,STATE) & sleeping)
        {
            !!switchToPhase4;
        }
        .

-actorstate(ACTOR, STATE) : sleeping & phase(4) & my_actor(ACTOR) & STATE == waistdown
    <-  .wait(500);
        if(not actorstate(ACTOR, STATE))
        {
            -sleeping;
            ?sympathy(S);
            -+sympathy(S-10);
            if(dreaming)
            {
                .drop_desire(enddream);
                playsound(null);
                -dreaming;
            }
            if(snoring)
            {
                playsound(null);
                -snoring;
            }
            .wait(1000);
            .drop_desire(loopoctopus2);
            setXRotation(0,100);
             playanimation(octopus, 3);
            !waitForIdle(500,250);
            switchToLive;
            .random(RANDOM);
            .wait((10+RANDOM*30)*1000);
            !!switchToPhase3;
        }
        .


+actorstate(ACTOR, STATE) : phase(f) & my_actor(ACTOR) & STATE == waistdown & sleeping
    <-  .wait(3000);
        if(actorstate(ACTOR,STATE))
        {
            -+sympathy(20);
            !!switchToPhase4;
        }
        .

+actordistancetoscreen(ACTOR, DIST) : phase(f) & my_actor(ACTOR) & DIST < 200 & not distcd & sleeping & sympathy(SYM) & SYM < 20
    <-  +distcd;
        ?sympathy(S);
        if(S < -50)
        {
            -+sympathy(-20);
        }
        else
        {
            -+sympathy(S+(100-DIST)/10);
        }
        ?sympathy(S2);
        if(S2 > 20)
        {
            .drop_desire(loopoctopus);
            -+sympathy(50);
            setXRotation(0,100);
            setZoom(0);
            playanimation(octopus, 3);
            !waitForIdle(500,250);
            switchToIdle;
            !waitForIdle(100,0);
            if(camerapos(CX,CZ))
            {
               moveTo(0,0,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(0,0,0,-3);              // look into camera
            }
            !waitForIdle(1000,0);
            if(onceiling)
            {
                -onceiling;
                switchToGround;
                !waitForIdle(1000,250);
            }
            !!switchToPhase3;
        }
        .

+distcd : true
    <-  !!dist_cd.

+!dist_cd : true
    <-  .wait(1000);
        -distcd.

+sympathy(S) : S <= 0
    <-  if(phase(f))
        {
            setTimedZoom( S / 10 , 0.2);
        }
        else
        {
            .print("0 sympathy reached, start (walkaway into) zoomout.");
            !!switchtophasef;
        }
        .

+sympathy(S) : S >= 100 & not dreaming
    <-  +dreaming;
        .print("100 sympathy reached, start dream sequence");
        -snoring;
        playsound(dream);
        !!enddream.

+!enddream : dreaming
    <-  .wait(63000);   // timer for audio file
        playsound(null);
        -dreaming;
        -sleeping;
        .wait(1000);
        .drop_desire(loopoctopus2);
        setXRotation(0,100);
         playanimation(octopus, 3);
        !waitForIdle(500,250);
        switchToLive;
        .random(RANDOM);
        .wait((10+RANDOM*30)*1000);
        !!switchToPhase3.


+sympathy(S) : S >= 100 & dreaming .


+sympathy(S) : S < 50 & sleeping
    <-  setXRotation(S/50 * 90 - 180, 10).

+sympathy(S) : S == 50 & sleeping
    <-  setXRotation(-90, 1000).

+sympathy(S) : S > 50 & sleeping
    <-  setXRotation(S/50 * 90 - 180, 10);
        setTimedZoom( (S-50) / 100 , 0.2).


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
