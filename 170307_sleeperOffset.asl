
+!die : true
    <-  .my_name(NAME);
        killOffset;
        .kill_agent(NAME).

+!run : true
    <-  .print("starting up!");
        .random(RAND);
        .wait(1000 + RAND * 3000);
        switchToSwapping;
        +swapping;
        playanimation(prepare_for_sleep, 1, 1, 1);
        +running.

+!walkOut : running & swapping
    <-  .drop_desire(walkAround);
        switchToSwapping;
        -swapping;
        .random(RAND);
        if(RAND > 0.5)
        {
            moveTo(-20,0);
        }
        else
        {
            moveTo(20,0);
        }
        .

+!walkOut : running & not swapping
    <-  .drop_desire(walkAround);
        .random(RAND);
        if(RAND > 0.5)
        {
            moveTo(-20,0);
        }
        else
        {
            moveTo(20,0);
        }
        .

+!walkOut : not running
    <-  .wait({+running});
        !walkOut.

+!walkIn : true
    <-  .random(RAND);
        moveTo(-2 + RAND*4, 0).

+!walkAround : not running
    <-  .wait({+running});
        !walkAround.

+!walkAround : running
    <-  .random(RAND);
        moveTo(-2 + RAND*4, 1);
        .random(RAND2);
        .wait(3000 + RAND2 * 5000);
        !walkAround.

