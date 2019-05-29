// === GLOBAL VARS ===
// t_ variables (time) are measured in ms (1 second = 1000 ms)
// s_ variables (speed) are parameters sent to unity (0.5 = half speed, 1 = normal, 2 = double speed, etc)

// phase 1 //
t_welcome1(3000).
t_welcome2(18000).
t_welcome3(12000).
t_welcome4(7000).
t_random_min(4000).         // time in between spoken sentences (minimum)
t_random_max(12000).        // time in between spoken sentences (maximum)

// phase 2 //
t_advise1(34000).
t_advise2(12000).
t_advise3(17000).

// phase 3 //
t_blend_in(10000).          // time for upper body to blend in during the first time going live
t_blend_delay(5000).        // time between complete blend in of upper body and switching to live
t_live(15000).              // base time for live state (phase 3)
t_live_bonus_1(5000).       // bonus time when going live for the first time
t_live_random(5000).        // window of randomness (+-) added to base time

// phase 4 //
s_lie_down(1).
t_lie_down(20000).
t_delay_sympathy(2000).     // time until sympathy starts adjusting, after agent starts lying down

// phase 5, phase 6, phase 7, phase 10 //
t_sympathy_interval(250).   // time between sympathy adjustments
sympathy_increase(0.4).     // sympathy increase when lying down together or close to screen
sympathy_decrease(0.3).     // sympathy decrease when not lying down together and distant to screen
dts_threshold_1(200).       // distance to screen threshold 1 (under this value -> sympathy increases)
dts_threshold_2(500).       // distance to screen threshold 2 (over this value -> sympathy decreases)
sympathy_invite_back(55).   // sympathy needed to trigger invite back (more than this value)

rotation_neutral(0).        // neutral rotation value (degrees)
rotation_positive(90).      // positive rotation value (degrees), should face camera
rotation_negative(-90).     // negative rotation value (degrees), should turn away from camera

// phase 8 //
t_camera_switch(1000).      // duration of camera switch from ortho to perspective
t_before_live(3200).        // time before switching to live
t_before_dream(15000).      // time required for dream sequence to start

// phase 9 //
t_before_switch(500).       // time before switching from perspective to ortho camera
t_camera_switch_back(500).  // duration of same camera switch
t_lift_head(4000).          // TODO

// phase 11 //
max_negative_sympathy(-100).// negative sympathy needed to reach narcotic sleep (= zoom out limit)
distance_trigger(0.8).      // distance from original position needed to trigger end of narcotic sleep (in m)
t_environment_delay(10000). // time the narcotic environment lingers after switching phase
//t_narcotic_get_up(7500).

// phase 12 //
zoom_factor(0.75).          // factor of zoom in during invite back
t_zoom(3000).               // duration of the zoom-in (=the zoom-lerp)
t_delay_invite_back(500).   // delay after zoom, before playing animation
t_invite_back(46000).       // TODO
zoom_factor2(1.0).          // factor of zoom after invite back
t_zoom2(2000).              // duration of the zoom-out

// phase 14 //
number_of_times(2).         // number of times user has to stand up during deep sleep to trigger unsettled sleep
t_time_window(60000).       // time window for user to stand up multiple times to trigger unsettled sleep
times_actor_got_up(0).      // counter for actor getting up
//t_unsettled_get_up(3000).

// phase 15 //
//t_deep_get_up(12000).
t_ortho_switch(10000).      // time to switch from perspective camera to orthographic (= slow zoom out)
live_delay(2000).           // maximum delay in ms

// === INITIAL BELIEFS ===

phase(1).
/*
          (condition)                             (phase name)
phase  1 = no visitor                            = sleep preparation
phase  2 = visitor detected (0 < scaling < 100)  = show visitor around
phase  3 = scaling finished                      = live
//     4 = after some time in live               = lie down
//     5 =                                       = lying down
phase  6 = if visitor lies down as well          = lying down together, sympathy increases
//     7 =                                       = waiting
phase  8 = if sympathy maxes out                 = deep sleep
//     9 = visitor gets up after lying down      = lift head, sigh
phase 10 = visitor doesnt lie down as well       = lying down, but visitor standing, sympathy decreases
phase 11 = visitor doesnt move or lie down       = narcotic sleep
//    12 = visitor doesnt move or lie down (1)   = invite back
//    13 = visitor down again after getting up   = turn towards
phase 14 = visitor gets up and down too often    = unsettled sleep
phase 15 = visitor still lying down after p8     = dream
*/

sympathy(50).
/*
    0       =   hateful         =   agent seeks distance from visitor
    1-49    =   antipathetic    =   agent turns away from visitor
    50      =   neutral         =
    51-99   =   sympathetic     =   agent turns towards visitor, zoom in
    100     =   loving          =   deep sleep, dream sequence while lying down

    ++  by lying down with agent while agent is sleeping
    ++  by being close to the screen when agent is distancing
    --  by not lying down with the agent while agent is sleeping
    --  by being too far away from the screen
*/

time_standing(0).   // counter for time spent standing, not live
time_live(0).       // counter for time spent live
time_lying(0).      // counter for time spent lying

// === INITIAL GOALS ===

!updateTime.

// === PLANS ===

+phase(X) : true
    <-  .print("starting phase ", X);
        !phase(X).

-phase(X) : true
    <-  .drop_desire(phase(X));
        .print("dropped phase ", X).

+!switchToPhase(X) : not phase(X)
    <-  -phase(_);
        .print("switching to phase ", X);
        +phase(X).

+!switchToPhase(X) : phase(X)
    <-  .print("already in phase ", X).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(1) & VALUE > 0
    <-  !!switchToPhase(2).

+actorscaling(ACTOR, VALUE) : my_actor(ACTOR) & phase(2) & VALUE >= 1
    <-  !!switchToPhase(3).

+!phase(1) : my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE > 0
    <-  !!switchToPhase(2).

+!phase(1) : true
    <-  playsound(welcome1);
        +lastsound(welcome1);
        playanimation(prepare_for_sleep, 1, 1, 1);
        ?t_welcome1(T);
        .wait(T);
        playsound(welcome2);
        +lastsound(welcome2);
        ?t_welcome2(T2);
        .wait(T2);
        !waitRandomTime;
        !welcomeAudioLoop.

+!welcomeAudioLoop : true
    <-  .random(RAND);
        !playWelcome(RAND).

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

+!waitRandomTime : true
    <-  ?t_random_min(TRMIN);
        ?t_random_max(TRMAX);
        .random(RAND);
        .print("waiting: ", TRMIN + (TRMAX-TRMIN)*RAND, " ms.");
        .wait(TRMIN + (TRMAX-TRMIN)*RAND).

+!phase(2) : my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE >= 1
    <-  !!switchToPhase(3).

+!phase(2) : my_actor(ACTOR)
    <-  playsound(thankyou1, 1);
        -+lastsound(thankyou1);
        !lookIntoCamera;
        playanimation(show_visitor_around, 1, 1, 1);
        playsound(advise1);
        -+lastsound(advise1);
        ?t_advise1(T);
        .wait(T);
        !adviseAudioLoop.

+!adviseAudioLoop : true
    <-  .random(RAND);
        !playAdvice(RAND).

+!playAdvice(R) : R > 0.6 & not lastsound(advise3)
    <-  playsound(advise3);
        -+lastsound(advise3);
        ?t_advise3(T);
        .wait(T);
        !adviceAudioLoop.

+!playAdvice(R) : R > 0.3 & not lastsound(advise2)
    <-  playsound(advise2);
        -+lastsound(advise2);
        ?t_advise2(T);
        .wait(T);
        !adviceAudioLoop.

+!playAdvice(R) : not lastsound(advise1)
    <-  playsound(advise1);
        -+lastsound(advise1);
        ?t_advise1(T);
        .wait(T);
        !adviceAudioLoop.

+!playAdvice(R) : true
    <-  .wait(100);
        !adviceAudioLoop.

+!phase(3) : not waslivebefore
    <-  ?t_live(TL);
        ?t_live_bonus_1(TLB);
        ?t_live_random(TLR);
        .random(R1);
        .random(R2);
        playsound(thankyou2, 1);
        -+lastsound(thankyou2);
        ?t_blend_in(T);
        blend_in(upper_body, T/1000);
        ?t_blend_delay(TBD);
        .wait(T + TBD);
        switchToLive;
        if(R1 > 0.5)
        {
            .wait(TL + TLB + R2 * TLR);
        }
        else
        {
            .wait(TL + TLB - R2 * TLR);
        }
        blend_out(upper_body, 0);
        +waslivebefore;
        !!switchToPhase(4).

+!phase(3) : waslivebefore
    <-  setTimedZoom(0,1);
        ?t_live(TL);
        ?t_live_random(TLR);
        .random(R1);
        .random(R2);
        switchToLive;
        if(R1 > 0.5)
        {
            .wait(TL + R2 * TLR);
        }
        else
        {
            .wait(TL - R2 * TLR);
        }
        !!switchToPhase(4).

+!phase(4) : my_actor(ACTOR) & not actorstate(ACTOR, waistdown)
    <-  ?actorposition(ACTOR,X,Y,Z);
        moveTo(X,Z,-10,0);              // look to the left
        !waitForIdle(1000,500);
        ?s_lie_down(S);
        ?t_lie_down(T);
        playanimation(lie_down, 1, S);
        .wait(T*S - 2000);
        +lying;
        !!switchToPhase(5).

+!phase(4) : my_actor(ACTOR) & actorstate(ACTOR, waistdown)
    <-  +lying;
        !!switchToPhase(5).

// phase 5 + (phase 6, phase 7, phase 10)
+!phase(5) : true
    <-  queueanimation(sleep_loop, 1, 1, 1);
        //playanimation(sleep_loop, 1, 1, 1);
        -+sympathy(50);
        ?t_delay_sympathy(TDS);
        .wait(TDS);
        !adjust_sympathy.

+!adjust_sympathy : my_actor(ACTOR) & actorstate(ACTOR, waistdown)
    <-  ?sympathy_increase(SI);
        ?sympathy(S);
        -+sympathy(S+SI);
        ?t_sympathy_interval(T);
        .wait(T);
        !adjust_sympathy.

+!adjust_sympathy : my_actor(ACTOR) & not actorstate(ACTOR, waistdown) & actordistancetoscreen(ACTOR, DISTANCE)
                    & dts_threshold_2(T2) & DISTANCE > T2
    <-  ?sympathy_decrease(SD);
        ?sympathy(S);
        -+sympathy(S-SD);
        ?t_sympathy_interval(T);
        .wait(T);
        !adjust_sympathy.

+!adjust_sympathy : my_actor(ACTOR) & not actorstate(ACTOR, waistdown) & actordistancetoscreen(ACTOR, DISTANCE)
                    & dts_threshold_1(T1) & DISTANCE < T1
    <-  ?sympathy_increase(SI);
        ?sympathy(S);
        -+sympathy(S+SI);
        ?sympathy_invite_back(SIB);
        if(S+SI > SIB)
        {
            !!switchToPhase(12);            // invite back
            .drop_desire(adjust_sympathy);
        }
        ?t_sympathy_interval(T);
        .wait(T);
        !adjust_sympathy.

+!adjust_sympathy : my_actor(ACTOR) & not actorstate(ACTOR, waistdown)
    <-  ?t_sympathy_interval(T);
        .wait(T);
        !adjust_sympathy.

+sympathy(S) : max_negative_sympathy(MNS) & S <= MNS
    <-  !!switchToPhase(11);              // narcotic sleep
        .drop_desire(adjust_sympathy).

+sympathy(S) : S <= 0
    <-  ?t_sympathy_interval(T);
        setTimedZoom((S-50) / 10 , T/1000).

+sympathy(S) : S >= 100 & not deepsleep
    <-  +deepsleep;
        .print("100 sympathy reached, start deepsleep");
        !!switchToPhase(8);               // deep sleep
        .drop_desire(adjust_sympathy).

+sympathy(S) : S >= 100 & deepsleep
    <-  .drop_desire(adjust_sympathy).

+sympathy(S) : S < 50
    <-  ?t_sympathy_interval(T);
        setTimedZoom((S-50) / 10 , T/1000);
        ?rotation_negative(R);
        setTimedXRotation(((S-50)/50) * (-R), T/1000).

+sympathy(S) : S == 50 & phase(N) & N > 2
    <-  ?t_sympathy_interval(T);
        setTimedXRotation(0, T/1000).

+sympathy(S) : S > 50
    <-  ?t_sympathy_interval(T);
        ?rotation_positive(R);
        setTimedXRotation(((S-50)/50) * R , T/1000);
        setTimedZoom((S-50) / 100 , T/1000).

// pseudo phase 9
-actorstate(ACTOR, waistdown) : my_actor(ACTOR) & phase(8)
    <-  -phase(8);
        -deepsleep;
        setXRotation(0, 10);        // reset rotation?
        playanimation(sleep_loop, 1, 1, 1);
        playsound(sigh1);
        ?t_before_switch(TBS);
        .wait(TBS);
        ?t_camera_switch_back(T);
        switchToCamera(CameraFront, T/1000);
        .wait(T);
        ?t_lift_head(TLH);
        playanimation(lift_head, 1);
        .wait(TLH-1000);
        queueanimation(sleep_loop, 1, 1, 1);
        +phase(9).

+!phase(9) : my_actor(ACTOR) & actorstate(ACTOR, waistdown)
    <-  setXRotation(90, 10);           // turn towards?
        ?times_actor_got_up(N);
        ?number_of_times(NOT);
        if(N+1 >= NOT)
        {
            !!switchToPhase(14);      // unsetttled sleep
        }
        else
        {
           -+times_actor_got_up(N+1);
           !!decrease_tagu;
            -+sympathy(90);
           !!switchToPhase(8);
        }
        .

+!phase(9) : my_actor(ACTOR) & not actorstate(ACTOR, waistdown)
    <-  ?times_actor_got_up(N);
        -+times_actor_got_up(N+1);
        !!decrease_tagu;
        !!switchToPhase(5).

-actorstate(ACTOR, waistdown) : my_actor(ACTOR) & not phase(14)
    <-  ?times_actor_got_up(N);
        -+times_actor_got_up(N+1);
        !!decrease_tagu.

+!decrease_tagu : true
    <-  ?t_time_window(TTW);
        .wait(TTW);
        ?times_actor_got_up(TAGU);
        -+times_actor_got_up(TAGU-1).

+!phase(8) : true
    <-  //setZoom(0);       // TODO ?
        ?t_camera_switch(T);
        switchToCamera(CameraEye, T/1000);
        ?t_before_live(TBL);
        .wait(TBL);
        switchToLive;
        ?t_before_dream(TBD);
        .wait(TBD);
        !!switchToPhase(15).              // start dreaming

+!phase(11) : true
    <-  environment(narcotic);
        setTimedZoom(0,1);
        setXRotation(0, 10);
        playanimation(narcotic_sleep_loop, 1, 1, 1);
        ?my_actor(ACTOR);
        ?actorposition(ACTOR,X,Y,Z);
        -+narcotic_position(X, Y, Z).

+actorstate(ACTOR, waistdown) : my_actor(ACTOR) & (phase(11) | phase(12))
    <-  -phase(_);
        playanimation(sleep_loop, 1, 1, 1);
        -narcotic_position(_,_,_);
        !!switchBackEnvironment;
        !!switchToPhase(5).

+actorposition(ACTOR, X, Y, Z) : my_actor(ACTOR) & (phase(11) | phase(12)) & distance_trigger(DT)
    & narcotic_position(PX, PY, PZ) & (PX - X > DT | X - PX > DT | Z - PZ > DT | PZ - Z > DT)
    <-  -phase(_);
        playanimation(narcotic_get_up, 1);
        //?t_narcotic_get_up(T);
        //.wait(T);
        !waitForIdle(1000,100);
        !!switchBackEnvironment;
        -narcotic_position(_,_,_);
        -sleeping;
        !!switchToPhase(3).

+!switchBackEnvironment : true
    <-  ?t_environment_delay(T);
        .wait(T);
        environment(default).

+!phase(12) : true
    <-  ?my_actor(ACTOR);
        ?actorposition(ACTOR,X,Y,Z);
        -+narcotic_position(X, Y, Z);
        ?zoom_factor(ZF);
        ?t_zoom(TZ);
        setTimedZoom(ZF, TZ/1000);
        ?t_delay_invite_back(DIB);
        .wait(DIB);
        setXRotation(0, 10);
        ?t_invite_back(TIB);
        playanimation(invite_back, 1);
        playsound(whisper1);
        .wait(TIB-1000);
        queueanimation(sleep_loop, 1, 1, 1);
        ?zoom_factor2(ZF2);
        ?t_zoom2(TZ2);
        setTimedZoom(ZF2, TZ2/1000);
        .wait(TZ2);
        !!switchToPhase(11).      // narcotic sleep

+!phase(14) : true
    <-  setXRotation(0, 10);
        playanimation(unsettled_sleep_loop, 1, 1, 1).

-actorstate(ACTOR, waistdown) : my_actor(ACTOR) & phase(14)
    <-  playanimation(unsettled_get_up, 1);
        //?t_unsettled_get_up(T);
        //.wait(T);
        !waitForIdle(1000,500);
        -sleeping;
        !!switchToPhase(3).

+!phase(15) : true
    <-  ?t_ortho_switch(TOS);
        //?t_deep_get_up(TGU);
        ?live_delay(LD);
        switchToCamera(CameraFront, TOS/1000);
        //playanimation(deep_get_up, 1);
        //.wait(TGU);
        //!waitForIdle(1000,500);
        //switchToLive;
        -sleeping;
        live_delay(LD/1000);
        .print("DREAM STATE REACHED - MILESTONE 1").

// failsafe for random exception?
+?actordistancetoscreen(ACTOR, DISTANCE) : my_actor(ACTOR) & not actordistancetoscreen(ACTOR, _)
    <-  +actordistancetoscreen(ACTOR, 300);
        .print("FAILED TEST GOAL ACTORDISTANCETOSCREEN, ADDING DEFAULT VALUE = 300").


+!updateTime : my_agent(AGENT) & agentstate(AGENT, live) & my_actor(ACTOR) & actorstate(ACTOR, waistdown)
    <-  ?time_live(T);
        -+time_live(T+1);
        .wait(1000);
        !!updateTime.

+!updateTime : my_agent(AGENT) & agentstate(AGENT, live)
    <-  ?time_live(T);
        -+time_live(T+1);
        .wait(1000);
        !!updateTime.

+!updateTime : lying
    <-  ?time_lying(T);
        -+time_lying(T+1);
        .wait(1000);
        !!updateTime.

+!updateTime : not lying & my_agent(AGENT) & not agentstate(AGENT, live)
    <-  ?time_standing(T);
        -+time_standing(T+1);
        .wait(1000);
        !!updateTime.

-!updateTime : true
    <-  .wait(100);
        !!updateTime.



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
