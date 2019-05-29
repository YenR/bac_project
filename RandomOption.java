import jason.asSemantics.Agent;
import jason.asSemantics.Option;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;

import java.lang.Exception;
import java.lang.Integer;
import java.util.ArrayList;
import java.util.List;




public class RandomOption extends Agent {

    public Option selectOption(List<Option> options) {

        List<Option> chanced = new ArrayList<>(options);

        for(Option o : options)
        {
            int chance = 1;
            try {
                Literal l = o.getPlan().getLabel().getAnnot("chance");
                chance = Integer.parseInt(l.getTerm(0).toString());
            }
            catch(Exception e) {}
            for(int i = 1; i < chance; i++)
                chanced.add(o);
        }

        double r = Math.random() * chanced.size();
        return chanced.get((int)r);

    }
}
