// === INITIAL BELIEFS ===

active_scenario(none).      // currently active scenario

// === RULES ===

// === INITIAL GOALS ===

!get_ready.

// === PLANS ===

+!get_ready : true
        <-  .print("Supervisor is active.");
            ready.

+end : true
        <-  .print("shutting down in 3");
            .wait(300);
            .print("2");
            .wait(300);
            .print("1");
            .wait(400);
            .stopMAS.

+start : not scenario(_)
        <-  .print("Got start command but no scenario selected. Defaulting to sleep.");
            +scenario(sleep);
            .abolish(start);
            +start.

+start : scenario(bat) & active_scenario(none)
        <-  -+active_scenario(bat);
            .drop_desire(send_activeScenario);
            !send_activeScenario;
            +active_agent(agent0, actor0, bat_agent0);
            //.create_agent(bat_agent0, "bat_agent_vortrag.asl");
            //.create_agent(bat_agent0, "bat_agent_v4.asl");
            // -----
            //.create_agent(bat_agent0, "v221116_bat1.asl");
            //.create_agent(bat_agent0, "v221116_bat2.asl");
            //.create_agent(bat_agent0, "v221116_bat3.asl");
            //.create_agent(bat_agent0, "v221116_normal1.asl");
            .create_agent(bat_agent0, "v221116_normal2.asl");
            .send(bat_agent0, tell, my_agent(agent0));
            .send(bat_agent0, tell, my_actor(actor0));
            .print("Initiated bat_agent #0").

+start : scenario(sleep) & active_scenario(none)
        <-  -+active_scenario(sleep);
            .drop_desire(send_activeScenario);
            !send_activeScenario;
            //+active_agent(agent0, actor0, bat_agent0);
            //.create_agent(sleeper_agent0, "v020217_sleeper2.asl"); // old agent
            .create_agent(sleeper_agent0, "170329_sleeper6.asl", [agentClass("RandomOption")]);
            .send(sleeper_agent0, tell, my_agent(agent0));
            .send(sleeper_agent0, tell, my_actor(actor0));
            .print("Initiated sleep agent #0");
            .wait(actorscaling(actor1, VALUE) & VALUE > 0);
            .create_agent(sleeper_agent1, "170329_sleeper6.asl", [agentClass("RandomOption")]);
            .send(sleeper_agent1, tell, my_agent(agent1));
            .send(sleeper_agent1, tell, my_actor(actor1));
            .print("Initiated sleep agent #1").

+start : scenario(sleep_film) & active_scenario(none)
        <-  -+active_scenario(sleep_film);
            .drop_desire(send_activeScenario);
            !!send_activeScenario;
            .print("sleep film scenario activated ...");
            .create_agent(sleeper_agent0, "170314_sleeper5_film.asl", [agentClass("RandomOption")]);
            .send(sleeper_agent0, tell, my_agent(agent0));
            .send(sleeper_agent0, tell, my_actor(actor0));
            .print("Initiated sleep agent #0");
            .create_agent(sleeper_agent1, "170314_sleeper5_film.asl", [agentClass("RandomOption")]);
            .send(sleeper_agent1, tell, my_agent(agent1));
            .send(sleeper_agent1, tell, my_actor(actor1));
            .print("Initiated sleep agent #0").

+start : scenario(wave) & active_scenario(none)
        <-  -+active_scenario(wave);
            .drop_desire(send_activeScenario);
            !send_activeScenario.

+!send_activeScenario : active_scenario(S) & S \== none
        <-  scenario(S);
            .wait(1000);
            !!send_activeScenario.

// add bat agents
+actorscaling(ACTOR, VALUE) : not active_agent(_, ACTOR, _) & active_scenario(bat)
        <-
            if(ACTOR == actor1 & not active_agent(agent1, _, _))
                {
                    +active_agent(agent1, actor1, bat_agent1);
                    .create_agent(bat_agent1, "bat_agent_v2_vortrag.asl");
                    //.create_agent(bat_agent1, "bat_agent_v4.asl");
                    .send(bat_agent1, tell, my_agent(agent1));
                    .send(bat_agent1, tell, my_actor(actor1));
                    .print("Initiated bat_agent #1");
                }
            .

// add waving agents
+actorscaling(ACTOR, VALUE) : not active_agent(_, ACTOR, _) & active_scenario(wave)
        <-  if(ACTOR == actor0 & not active_agent(agent0, _, _))
            {
                +active_agent(agent0, actor0, wave_agent0);
                .create_agent(wave_agent0, "wave_agent1.asl");
                .send(wave_agent0, tell, my_agent(agent0));
                .send(wave_agent0, tell, my_actor(actor0));
                .print("Initiated wave_agent #0");
            }
            else
            {   if(ACTOR == actor1 & not active_agent(agent1, _, _))
                {
                    +active_agent(agent1, actor1, wave_agent1);
                    .create_agent(wave_agent1, "wave_agent2.asl");
                    .send(wave_agent1, tell, my_agent(agent1));
                    .send(wave_agent1, tell, my_actor(actor1));
                    .print("Initiated wave_agent #1");
                }
            }.
