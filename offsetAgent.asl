
+timeout(TIME) : true
    <-  .wait(TIME);
        .my_name(NAME);
        .print("I'm going off to die.");
        .rand(RAND);
        if(RAND > 0.5)
        {
            moveTo(-20,0);
        }
        else
        {
            moveTo(20,0);
        }
        .wait(10000);
        killOffset;
        .kill_agent(NAME).

+!run : master(M)
    <-  //switchToIdle;
        .wait(500);
        .send(M, askOne, phase(_), PHASE);
        -+phase(PHASE);
        ?phase(phase(X));
        .random(RANDOM);
        if(X == 2)
        {
            if(RANDOM > 0.5)
            {
                playanimation(donning, 1);
            }
            else
            {
                playanimation(donning, 2);
            }
        }
        else
        {
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
        }
        .wait(5000);        // TODO: doesnt wait for idle?
        !run.

+!run : not master(_)
    <-  .print("got no master!?");
        .wait(1000);
        !run.

-!run : true
    <-  .print("stopped running!?");
        .wait(1000);
        !run.
