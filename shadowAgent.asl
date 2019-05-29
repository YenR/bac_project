+!die : true
    <-  .drop_desire(phase(2));
        .drop_desire(phase(1));
        printText("Well done!", 5, screen, 0.25, 0.75);
        .print("Im told to die.");
        visibility(0);
        switchToIdle;
        .wait(3000);
        killOffset;
        .my_name(NAME);
        .kill_agent(NAME).

+!phase(2) : true
    <-  printText("I will show you how to put on the skeleton.", 80, screen, 0.25, 0.75);
        .drop_desire(phase(1));
        switchToIdle;
        !waitForIdle;
        visibility(0.5);
        //printSprite(exclam_mark, 4, head, 0.55, 0.45);
        ?actorposition(actor0, X, Y, Z);
        if(camerapos(CX,CZ))
        {
            moveTo(X,Z+1,CX,CZ);
        }
        else
        {
            moveTo(X,Z+1,0,-3);
        }
        !waitForIdle;
        !donning.

+!donning : true
    <-  !waitForIdle;
        playanimation(donning_shadow, 1);
        printText("Please imitate my actions.", 60, screen, 0.25, 0.75);
        !donning.

+!phase(1) : true
    <-  visibility(0);                  // move out of camera while invisible
        switchToGround;
        !waitForIdle;
        if(cameraborder(LB, RB))
        {
            moveTo(RB+2, 0, 0, 0);
        }
        else
        {
            moveTo(5,0, 0, 0);
        }
        !waitForIdle;
        visibility(0.3);                // become visible and move towards the bat
        ?agentposition(agent0, X, Y, Z);
        if(camerapos(CX,CZ))
        {
           moveTo(X+1.2,Z,CX,CZ);              // look into camera
        }
        else
        {
            moveTo(X+1.2,Z,0,-3);              // look into camera
        }
        !waitForIdle;
        printText("Please wait on the X marked on the floor.", 150, screen, 0.25, 0.75);
        playanimation(donning_armsforward, 1);  // stretch arms forward
        !waitForIdle;
        !phase(1).                      // repeat


+!waitForIdle : true
    <-  .wait(1000);
        if(not agentstate(agent10, idle))
        {
            .wait(agentstate(agent10, idle));
        }
        .wait(1000).


+!turnToScreen : true
        <-  ?agentposition(agent10, X, Y, Z);
            if(camerapos(CX,CZ))
            {
               moveTo(X,Z,CX,CZ);              // look into camera
            }
            else
            {
                moveTo(X,Z,0,-3);              // look into camera
            }
            !waitForIdle.

