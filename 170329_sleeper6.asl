t_action_interval(500).     // time between actions

t_welcome1(3000).
t_thankyou1(2000).
t_welcome2(18000).
t_welcome3(12000).
t_welcome4(7000).
t_random_min(4000).         // time in between spoken sentences (minimum)
t_random_max(12000).        // time in between spoken sentences (maximum)

speed_dontex(1.4).        // general duration multiplier for donning textures
t_dontex001(7000).
t_dontex002(6500).
t_dontex1(5000).
t_dontex2(3000).
t_dontex3(6500).
t_dontex4(6500).
t_dontex5(5000).
t_dontex6(9000).
t_dontex7(20000).
t_dontex8(7000).
t_dontex9(7000).
t_dontex10(7000).
t_dontex11(5000).
t_dontex12(1000000).

sympathy(50).
energy(150).
movement(0).
activity_level(0).
min_movement_walking(0.5).

bodymotion_multi(1).        // multiplier for bodymotion value added to activity level
movement_multi(1).          // multiplier for movement value added to activity level

activity_level_th1(10).     // activity level threshold for small energy reduction
activity_level_th2(30).     // activity level threshold for strong energy reduction
small_energy_cost(0.3).
strong_energy_cost(1.0).

bound_left(-2).             // bounds to the left side (world coordinates)
bound_right(2).             // bounds to the right side (world coordinates)

wait_time(250).             // waiting time between movement adjustments in ms
delta_movement(0.1).        // delta for movement value, gets deducted every adjustment

t_min_live(2000).
t_before_emancipation(180000).
bm_min_start(4).        // bodymotion value to start emancipation
m_min_start(6).         // movement value to start emancipation

max_distance_to_objects(1.2).

t_deep_sleep(120000).    // duration of deep sleep phase

t_before_credits(180).  // time in seconds to stand still before credits roll

// === RULES ===
// returns true, if the distance (=difference) between A and B is less than X
distance_under(A,B,X)
    :- (A-B) < X & (A-B) > (-X).

// standing
a1 :- not a2 & not a3 & not a4.                //(actorstate(ACTOR, waistdown) | actorstate(ACTOR, waistlow) | ).
// walking
a2 :- moving.                                  //movement(M) & min_movement_walking(MM) & M >= MM.
// sitting
a3 :- my_actor(ACTOR) & actorstate(ACTOR, waistlow) & not actorstate(ACTOR, waistdown).
// lying
a4 :- my_actor(ACTOR) & actorstate(ACTOR, waistdown).
// hands up
a5 :- my_actor(ACTOR) & actorstate(ACTOR, handsup).
// hands front
a6 :- my_actor(ACTOR) & actorstate(ACTOR, handsfront).

// position - left side
b1 :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & X < -0.5.
// right side
b2 :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & X > 0.5.
// front side
b3 :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & Z > 0.5.
// front side
b4 :- my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & Z < -0.5.
// center
b5 :- not b1 & not b2 & not b3 & not b4.
// close to bed
b6 :- objectpositon(bedlie, X, Y, _, _) & max_distance_to_objects(MD) & my_agent(AGENT) & agentposition(AGENT, AX, _, AY)
        & distance_under(AX, Y, MD) & distance_under(AY, Y, MD).
// close to seat
b7 :- objectpositon(bedsit, X, Y, _, _) & max_distance_to_objects(MD) & my_agent(AGENT) & agentposition(AGENT, AX, _, AY)
        & distance_under(AX, Y, MD) & distance_under(AY, Y, MD).

// sleep states
c1 :- energy(E) & E >= 90.
c2 :- energy(E) & E < 90 & E >= 50.
c3 :- energy(E) & E < 50 & E >= 20.
c4 :- energy(E) & E < 20.
c5 :- sleeping.
c6 :- wakingUp.

// sympathy
d1 :- sympathy(S) & S > 70.
d2 :- sympathy(S) & S <= 70 & S >40.
d3 :- sympathy(S) & S <= 40 & S >10.
d4 :- sympathy(S) & S <=10.


// === GOALS ===
!start.

// === PLANS ===

+!report : my_agent(AGENT) & sympathy(S) & energy(E) & movement(M) & activity_level(AL) & bodymotion(AGENT, BM)
    <-  .print("REPORT: Sympathy: ", S, " energy: ", E, " movement: ", M, " activity level: ", AL, " bodymotion: ", BM);
        .wait(5000);
        !!report.

+!report : my_agent(AGENT) & not(sympathy(S) & energy(E) & movement(M) & activity_level(AL) & bodymotion(AGENT, BM))
    <-  .print("REPORT failed to gather data. trying again.");
        .wait(5000);
        !!report.

+!adjust_values : my_agent(AGENT) & movement(M) & activity_level(AL) & bodymotion(AGENT, BM) & wait_time(WT) & bodymotion_multi(BMM) & movement_multi(MM)
    <-  -+activity_level(BM * BMM + M * MM);
        !adjust_energy;
        .wait(WT);
        !!adjust_values.

+!adjust_values : my_agent(AGENT) & not (energy(E) & movement(M) & activity_level(AL) & bodymotion(AGENT, BM)) & wait_time(WT)
    <-  .print("failed to adjust values. trying again");
        .wait(WT);
        !!adjust_values.

@very_active_live[atomic]
+!adjust_energy : activity_level(AL) & energy(E) & activity_level_th1(ALT1) & activity_level_th2(ALT2) & small_energy_cost(SMEC)
    & strong_energy_cost(STEC) & AL >= ALT2 & my_agent(AGENT) & agentstate(AGENT, live)
    <-  -+energy(E-STEC).

@less_active_live[atomic]
+!adjust_energy : activity_level(AL) & energy(E) & activity_level_th1(ALT1) & activity_level_th2(ALT2) & small_energy_cost(SMEC)
    & strong_energy_cost(STEC) & AL < ALT2 & AL >= ALT1 & my_agent(AGENT) & agentstate(AGENT, live)
    <-  -+energy(E-SMEC).

@not_active_live
+!adjust_energy : activity_level(AL) & energy(E) & activity_level_th1(ALT1) & activity_level_th2(ALT2) & small_energy_cost(SMEC)
    & strong_energy_cost(STEC) & AL < ALT1 & my_agent(AGENT) & agentstate(AGENT, live) .

@very_active_notlive[atomic]
+!adjust_energy : my_agent(AGENT) & energy(E) & not agentstate(AGENT, live) & bodymotion(AGENT, BM) & bodymotion_multi(BMM)
    & activity_level_th1(ALT1) & activity_level_th2(ALT2) & strong_energy_cost(STEC) & BM * BMM >= ALT2
    <-  -+energy(E-STEC).

@less_active_notlive[atomic]
+!adjust_energy : my_agent(AGENT) & energy(E) & not agentstate(AGENT, live) & bodymotion(AGENT, BM) & bodymotion_multi(BMM)
    & activity_level_th1(ALT1) & activity_level_th2(ALT2) & small_energy_cost(SMEC) & BM * BMM < ALT2 & BM * BMM >= ALT1
    <-  -+energy(E-SMEC).

@not_active_notlive[atomic]
+!adjust_energy : my_agent(AGENT) & not agentstate(AGENT, live) & bodymotion(AGENT, BM) & bodymotion_multi(BMM)
    & activity_level_th1(ALT1) & BM * BMM < ALT1 .

@energy_not_negative[atomic]
+energy(E) : E < 0
    <- -+energy(0).

+energy(E) : E < 10 & E > 0 & objectpositon(bedlie, X, Y, _, _)
    <-  .print("I am very tired").

+energy(E) : E < 50 & E > 20 & not livedelay
    <-  +livedelay;
        live_delay(3).

+energy(E) : (E > 50 | E < 20) & livedelay
    <-  -livedelay;
        live_delay(0).

+!start : true
    <-  .wait(250);
        ?my_actor(ACTOR);
        +welcoming;
        if(my_agent(agent0))
        {
            !!playWelcomeAudio2;
            !!spawnOffset(1001, -1.5, 0);
            !!spawnOffset(1002, 1.5, 0);
            switchToSwapping;
            +swapping;
        }
        .wait(my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE >= 1);
        if(swapping)
        {
            switchToSwapping;
            -swapping;
        }
        !!standbyOffsets;
        -welcoming;
        !goLive;
        //.wait(500);
        ?actorposition(ACTOR,X,Y,Z);
        +lastposition(X,Z);
        !!checkMovement;
        !!adjust_values;
        !!report;
        +cfc(0);
        !!checkForCredits;
        ?t_before_emancipation(TBE);
        .wait(TBE);
        !!killOffsets;
        +ec(0);
        !start_emancipation.

+!checkForCredits : activity_level(AL) & AL > 0.3
    <-  -+cfc(0);
        .wait(1000);
        !checkForCredits.

+!checkForCredits : activity_level(AL) & AL <= 0.3 & cfc(CFC) & t_before_credits(TBC) & CFC < TBC
    <-  -+cfc(CFC+1);
        .wait(1000);
        !checkForCredits.

@go_credits[atomic]
+!checkForCredits : activity_level(AL) & AL <= 0.3 & cfc(CFC) & t_before_credits(TBC) & CFC >= TBC
    <-  -phase(_);
        .drop_desire(doSomething);
        ?objectposition(bedsit, X, Y, DX, DY);
        moveTo(X, Y, DX, DY);
        !waitForIdle(1000,0);
        playanimation(sit_down_bed, 1);
        queueanimation(sit_on_bed, 1,1,1);
        displayTexture(Credits, 60, 0,-1,0,1);
        .wait(60000);
        playanimation(sit_up_bed, 1);
        !waitForIdle(1000,500);
        switchToLive;
        !!playWelcomeAudio2;
        !!spawnOffset(1001, -1.5, 0);
        !!spawnOffset(1002, 1.5, 0);
        if(not swapping)
        {
            switchToSwapping;
            +swapping;
        }
        .wait(10000);
        .wait(activity_level(AL) & AL > 2);
        switchToSwapping;
        -swapping;
        +phase(sleep).

+!start_emancipation : my_agent(AGENT) & ((bodymotion(AGENT, BM) & bm_min_start(BMS) & BM > BMS) | (movement(M) & m_min_start(MMS) & M > MMS)) & ec(EC) & EC < 10
    <-  .print("actor too active. delaying emancipation.");
        -+ec(EC+1);
        .wait(3000);
        !start_emancipation.

+!start_emancipation : my_agent(AGENT) & ((bodymotion(AGENT, BM) & bm_min_start(BMS) & BM <= BMS & movement(M) & m_min_start(MMS) & M <= MMS) | (ec(EC) & EC >= 10))
    <-  +phase(sleep).

@movement_update[atomic]
+!checkMovement : lastposition(LX,LZ) & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z)
    <-  ?movement(M);
        //.print("m: ", M);
        if(LX > X)
        {
            -+movement(M+(LX-X));
        }
        else
        {
            -+movement(M+(X-LX));
        }
        ?movement(M2);
        ?delta_movement(D);
        if(LZ > Z)
        {
            -+movement(M2+(LZ-Z) - D);
        }
        else
        {
            -+movement(M2+(Z-LZ) - D);
        }
        -+lastposition(X,Z);
        ?movement(M3);
        ?min_movement_walking(MM);
        if(M3-M > MM)
        {
            +moving;
            if(M3 - M > 3)
            {
                -+movement(M+3);
            }
        }
        else
        {
            -moving;
        }
        !!reCheckMovement.

+!reCheckMovement : true
    <-  ?wait_time(W);
        .wait(W);
        !!checkMovement.

@movement_not_negative[dynamic]
+movement(M) : M < 0
    <-  -+movement(0).

@movement_not_too_high[dynamic]
+movement(M) : M > 50
    <-  -+movement(40).

@energy_not_too_high[dynamic]
+energy(E) : E > 150
    <-  -+energy(150).

+phase(P) : true
    <-  .print("entered phase : ", P);
        !!doSomething.

-!doSomething : true
    <-  .print("SOMETHING TERRIBLE HAPEND");
        .wait(500);
        !doSomething.

@standing
+!doSomething : a1 & c3 & my_agent(AGENT) & not agentstate(AGENT, idle) & activity_level(AL) & AL < 1 & todo
    <-  switchToIdle;
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@react_fast_go_live
+activity_level(AL) & AL > 2 & auto & not sleeping
    -auto;
    switchToLive.


@walk_left
+!doSomething : a1 & b2 & c1 & not sleeping & activity_level(AL) & AL < 0.5
    <-  +auto;
        .random(RAND);
        moveTo(-2+RAND, 0);
        !waitForIdle(2000,1000);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@walk_right
+!doSomething : a1 & b1 & c1 & not sleeping & activity_level(AL) & AL < 0.5
    <-  +auto;
        .random(RAND);
        moveTo(2-RAND, 0);
        !waitForIdle(2000,1000);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@seat
+!doSomething : (a1 | a2) & b7 & (c2|c3) & objectposition(bedsit, X, Y, DX, DY) & not sleeping
    <-  +sitting;
        .print("sitting");
        moveTo(X, Y, DX, DY);
        !waitForIdle(1000,0);
        playanimation(sit_down_bed, 1);
        queueanimation(sit_on_bed, 1,1,1);
        ?t_action_interval(TAI);
        .random(RAND);
        .wait(TAI * (RAND+1) * 10);
        playanimation(sit_up_bed, 1);
        !waitForIdle(1000,500);
        -sitting;
        !doSomething.

@bed
+!doSomething : (a1 | a2) & b6 & (c2|c3|c4) & objectposition(bedlie, X, Y, DX, DY) & not sleeping
    <-  +sleeping;
        moveTo(X, Y, DX, DY);
        !waitForIdle(1000,0);
        playanimation(lie_down_bed, 1);
        queueanimation(lie_on_bed, 1,1,1);
        ?t_action_interval(TAI);
        .random(RAND);
        .wait(TAI * (RAND+1) * 10);
        playanimation(lie_up_bed, 1);
        !waitForIdle(1000,500);
        -sleeping;
        !doSomething.

@stroll_around
+!doSomething : a1 & (c1|c2) & not sleeping & activity_level(AL) & AL < 2
    <-  +auto;
        !moveAround;
        !doSomething.

@get_up
+!doSomething : (not a4 & not a3) & c1 & sleeping
    <-  -sleeping;
        playanimation(deep_get_up, 1);
        !waitForIdle(1000, 0);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@default_live[chance(3)]
+!doSomething : my_agent(AGENT) & agentstate(AGENT, idle) & activity_level(AL) & AL > 2 & not sleeping & not a4
    <-  -auto;
        switchToLive;
        ?t_action_interval(TAI);
        ?t_min_live(TML);
        .wait(TAI+TML);
        !doSomething.

@default_live_lying
+!doSomething : my_agent(AGENT) & agentstate(AGENT, idle) & a4 & objectposition(bedlie, X, Y, DX, DY) & b6
    <-  +sleeping;
        moveTo(X, Y, DX, DY);
        !waitForIdle(1000,0);
        playanimation(lie_down_bed, 1);
        queueanimation(lie_on_bed, 1,1,1);
        !blendin;
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@default_live_lying_somewhere_else
+!doSomething : my_agent(AGENT) & agentstate(AGENT, idle) & a4 & my_actor(ACTOR) & actorposition(ACTOR, X, Y, Z) & not b6
    <-  +sleeping;
        moveTo(X, Z);
        !waitForIdle(1000,0);
        playanimation(lie_down, 1);
        queueanimation(sleep_loop, 1,1,1);
        !blendin;
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@default_live_sleeping
+!doSomething : my_agent(AGENT) & activity_level(AL) & AL > 3 & sleeping & b6
    <-  -sleeping;
        -auto;
        +wakingUp;
        playanimation(lie_up_bed, 1);
        !waitForIdle(1000,250);
        switchToLive;
        ?t_action_interval(TAI);
        .wait(TAI);
        -wakingUp;
        !doSomething.

@do_nothing[chance(2)]
+!doSomething : true
    <-  ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

+actorstate(ACTOR, waistdown) : my_actor(ACTOR) & not sleeping
    <-  +sleeping.

+actorstate(ACTOR, waistdown) : my_actor(ACTOR) & sleeping
    <-  !blendin.

-actorstate(ACTOR, waistdown) : my_actor(ACTOR) & sleeping
    <-  -sleeping;
        !blendout.

+!blendin : not blendedin
    <-  +blendedin;
        blend_in(upper_body, 3);
        blend_in(lower_body, 3).

+!blendin : blendedin .

+!blendout : not blendedin .

+!blendout : blendedin
    <-  -blendedin;
        blend_out(upper_body, 3);
        blend_out(lower_body, 3).


@walk_slow
+!doSomething : b4 & (c3 | c4) & not slow
    <-  +slow;
        movespeed(0.5);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@walk_normal
+!doSomething : (c1 | c2) & slow
    <-  -slow;
        movespeed(1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@deep_sleep
+!doSomething : a4 & (c1 | c2) & activity_level(AL) & AL < 1
    <-  -auto;
        .print("starting deep sleep!");
        !blendout;
        +deepsleep;
        switchToCamera(CameraHand, 3);
        switchToLive;
        ?t_deep_sleep(TDS);
        .wait(TDS);
        .wait(activity_level(AL2) & AL2 < 1);
        switchToCamera(CameraFront, 3);
        switchToSwapping;
        .wait(5000);
        !doSomething.

@narcotic_sleep
+!doSomething : a4 & b4 & (c3 | c4) & not b6
    <-  !blendout;
        environment(narcotic);
        playanimation(narcotic_sleep_loop, 1, 1, 1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@narcotic_sleep_bed
+!doSomething : a4 & b4 & (c3 | c4) & b6
    <-  !blendout;
        environment(narcotic);
        playanimation(narcotic_sleep_loop, 2, 1, 1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@zoom_out
+!doSomething : a1 & b4 & not zoom(-3)
    <-  -+zoom(-3);
        setTimedZoom(-3, 4);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@zoom_in
+!doSomething : a1 & b3 & not zoom(0)
    <-  -+zoom(0);
        setTimedZoom(0, 4);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@zoom_in_less
+!doSomething : a1 & b5 & not zoom(-1.5)
    <-  -+zoom(-1.5);
        setTimedZoom(-1.5, 4);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@unsettled_sleep
+!doSomething : a4 & (c1 | c2) & activity_level(AL) & AL >= 8 & not b6
    <-  playanimation(unsettled_sleep_loop, 1, 1, 1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@unsettled_sleep_bed
+!doSomething : a4 & (c1 | c2) & activity_level(AL) & AL >= 8 & b6
    <-  playanimation(unsettled_sleep_loop, 2, 1, 1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@fall_asleep
+!doSomething : energy(E) & E < 10 & objectposition(bedlie, X, Y, DX, DY)
    <-  +sleeping;
        moveTo(X, Y, DX, DY);
        !waitForIdle(1000,0);
        playanimation(lie_down_bed, 1);
        queueanimation(lie_on_bed, 1,1,1);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

// // // NOT IMPLEMENTED YET // // //

@yawn
+!doSomething : (c3 | c4) & todo
    <-  //playanimation(yawn, 1);
        //!waitForIdle(1000, 500);
        .print("yawn");
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@prepare_bed
+!doSomething : (a1 | a5 | a6) & b3 & c3 & todo
    <-  .print("prepare bed");
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@wake_up
+!doSomething : not a4 & (c1 | c2) & sleeping & todo
    <-  -sleeping;
        playanimation(deep_get_up, 1);
        !waitForIdle(500,500);
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@invite_back
+!doSomething : a1 & b4 & d4 & todo
    <-  //TODO playanimation(invite_back, 1);
        //!waitForIdle(500,500);
        .print("invite back");
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@lift_head
+!doSomething : a4 & (c1 | c2 | c3) & todo
    <-  playanimation(lift_head, 1);
        queueanimation(sleep_loop, 1, 1, 1);
        .wait(1000);
        !blendin;
        ?t_action_interval(TAI);
        .wait(3000 + TAI);
        !doSomething.

@turn_toward
+!doSomething : a4 & b3 & c5 & d1 & todo
    <-  //playanimation(turn_toward, 1);
        .print("turntoward");
        ?t_action_interval(TAI);
        .wait(TAI);
        !doSomething.

@invite_visitor
+!doSomething : (a1 | a3 | a4) & c2 & todo
    <-  // playanimation(invite_visitor,1);
        .print("invite visitor");
        !waitForIdle(1000,500);
        !doSomething.

+!playWelcomeAudio2 : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS > 0
    <-  .print("skipping welcome audio").

+!playWelcomeAudio2 : my_actor(ACTOR) & ((actorscaling(ACTOR, AS) & AS <= 0) | not actorscaling(ACTOR, _))
    <-  playsound(explain1);
        .wait(60000 * 7);
        !playWelcomeAudio2.

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
        playsound(null, 1);
        if(swapping)
        {
            switchToSwapping;
            -swapping;
        }
        !!standbyOffsets;
        //.drop_desire(playWelcomeAudio);
        //playsound(thankyou1, 1);
        ?t_thankyou1(T);
        .wait(T);
        //playsound(advise1);
        +donning;
        !new_donning.

+!new_donning : true
    <-  moveTo(5,0);
        //!lookIntoCamera;
        ?speed_dontex(SDT);
        ?t_dontex001(DT001);
        ?t_dontex002(DT002);
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
        ?t_dontex11(DT11);
        ?t_dontex12(DT12);
        displayTexture(donning001, DT001*SDT/1000);
        .wait(DT001*SDT);
        displayTexture(donning002, DT002*SDT/1000);
        .wait(DT002*SDT);
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
        .wait(DT6*SDT);
        displayTexture(donning07, DT7*SDT/1000);
        ?camerapos(CX,CZ);
        moveTo(-1,0, CX, CZ);
        !waitForIdle(2000,500);
        //!lookIntoCamera;
        //!waitForIdle(500,500);
        playanimation(donning_shadow, 1);
        .wait(DT7*SDT);
        !waitForIdle(2000,1000);
        moveTo(5,0);
        displayTexture(donning08, DT8*SDT/1000);
        .wait(DT8*SDT);
        displayTexture(donning09, DT9*SDT/1000);
        .wait(DT9*SDT);
        displayTexture(donning10, DT10*SDT/1000);
        .wait(DT10*SDT);
        displayTexture(donning11, DT11*SDT/1000);
        .wait(DT11*SDT);
        displayTexture(donning12, DT12*SDT/1000);
        .wait(my_actor(ACTOR) & actorscaling(ACTOR, VALUE) & VALUE > 0);
        displayTexture(donning12, 0.1);
        // start scaling here
        .

+actorscaling(ACTOR, AS) : my_actor(ACTOR) & donning & AS >= 1
    <-  -donning;
        playsound(thankyou3, 1).

+actorscaling(ACTOR, AS) : my_actor(ACTOR) & donning & AS >= 0.5 & not verygood
    <-  +verygood;
        playsound(verygood1, 1).

+!goLive : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS < 1
   <-  .print("goLive reached, but scaling not finished. restarting.");
       !start.

+!goLive : my_actor(ACTOR) & actorscaling(ACTOR, AS) & AS >= 1
    <-  switchToLive.

@stop_in_motion
+!moveAround : movement(M) & M > 0.5 .

@leerlauf[chance(30)]
+!moveAround : movement(M) & M <= 0.5
    <-  .wait(200);
        !moveAround.

@move[chance(5)]
+!moveAround : movement(M) & M <= 0.5
    <-  .random(R);
        ?bound_left(BL);
        ?bound_right(BR);
        moveTo(BL + (BR-BL)*R, 0);
        !waitForIdle(1000,250);
        !moveAround.

@lookIntoCam[chance(3)]
+!moveAround : movement(M) & M <= 0.5
    <-  !lookIntoCamera;
        .random(R2);
        !waitForIdle(1000, 500 + R2 * 1000);
        !moveAround.

@stopRandomly[chance(1)]
+!moveAround : movement(M) & M <= 0.5 .


+!waitRandomTime : true
    <-  ?t_random_min(TRMIN);
        ?t_random_max(TRMAX);
        .random(RAND);
        .print("waiting: ", TRMIN + (TRMAX-TRMIN)*RAND, " ms.");
        .wait(TRMIN + (TRMAX-TRMIN)*RAND).

+!spawnOffset(NR, X, Y) : true
        <-  ?my_agent(AGENT);
            spawnOffset(NR, X, Y, 1);
            .concat("sleeperOffset", NR, AGNAME);
            +active_agent(AGNAME);
            .create_agent(AGNAME, "170307_sleeperOffset.asl");
            .send(AGNAME, achieve, run);
            .print("created agent: ", AGNAME).

+!killOffsets : active_agent(AGNAME)
    <-  //.send(AGNAME, achieve, walkOut);
        -active_agent(AGNAME);
        !!killOffsets;
        .wait(20000);
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

+sleeping : true
    <-  !rest.

+!rest : not sleeping .

+!rest : sleeping & energy(E)
    <-  -+energy(E+1);
        .wait(500);
        !!rest.

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
