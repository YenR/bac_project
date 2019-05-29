+actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == handstogether & not cd(handstogether)
                    <- 	.my_name(NAME);
                        agentaction(NAME, action1);
                       	+cd(handstogether).

+cd(handstogether) : true
                    <-  .wait(2000);
                        -cd(handstogether).

-cd(handstogether) : actorstate(ACTOR, STATE) & my_actor(ACTOR) & STATE == handstogether
                    <-  .my_name(NAME);
                        agentaction(NAME, action1);
                        +cd(handstogether).

-actorstate(ACTOR, STATE) : my_actor(ACTOR) & STATE == handstogether
                    <-  .my_name(NAME);
                        agentaction(NAME, switchToLive).


+actorstate(ACTOR, STATE) : not my_actor(ACTOR) & STATE == bow & not cd(bow)
                    <- 	.my_name(NAME);
                        agentaction(NAME, action2);
                       	+cd(bow).

+cd(bow) : true
                    <-  .wait(2000);
                        -cd(bow).

-cd(bow) : true.

-actorstate(ACTOR, STATE) : not my_actor(ACTOR) & STATE == bow
                    <-  .my_name(NAME);
                        agentaction(NAME, switchToLive).

+actorstate(ACTOR, STATE) : my_actor(ACTOR)
                    <- .print("perceived: ", STATE, " from: ", ACTOR, ". But no reaction.").
					
-actorstate(ACTOR, STATE) : my_actor(ACTOR)
                    <- .print("stopped perceiving: ", STATE, " from: ", ACTOR).

+my_actor(A) : true
					<- 	.my_name(NAME);
						.print("I am ", NAME, ", I watch ", A, ".").
