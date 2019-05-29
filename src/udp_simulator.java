import com.mongodb.BasicDBObject;
//import jasonisp.JasonIsp;
import jasonisp.network.BSONListener;
import jasonisp.network.UDPListenerThread;
import jasonisp.network.UDPSender;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.binding.Bindings;
import javafx.concurrent.Task;
import javafx.concurrent.WorkerStateEvent;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.geometry.Insets;
import javafx.geometry.Orientation;
import javafx.scene.Group;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.effect.BlendMode;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import javafx.stage.WindowEvent;
import javafx.util.Duration;
import org.bson.BSONObject;
import org.bson.BasicBSONEncoder;
import org.bson.BasicBSONObject;
import org.bson.BsonDocument;

import java.io.*;
import java.net.SocketException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.*;



/**
 * Created by Tom on 08.08.2016.
 *
 * NOTE: THIS CODE IS NEITHER WELL WRITTEN NOR THREADSAFE, RANDOM EXCEPTIONS MIGHT OCCUR SOMETIMES
 */
public class udp_simulator extends Application implements Initializable{

    public static final int LISTEN_PORT = 9899;
    public static final String REMOTE_ADDRESS = "localhost";
    public static final int REMOTE_PORT = 9898;

    public static final String SCN = "bat";

    @FXML
    public Button move_actor0;

    @FXML
    public Button move_actor1;

    @FXML
    public Button state_startScaling;

    @FXML
    public Button state_bow;

    @FXML
    public Button state_hands;

    @FXML
    public Button state_wave;

    @FXML
    public Button state_fromText;

    @FXML
    public TextArea agent_actionlog;

    @FXML
    public TextField state_textfield;

    @FXML
    public Label actor0label;

    @FXML
    public Label actor1label;

    @FXML
    public Label agent0label;

    @FXML
    public Label agent1label;

    @FXML
    public VBox fieldVBox;

    @FXML
    public VBox actor0VBox;

    @FXML
    public VBox actor1VBox;
    /**
     * Creates a BSON Object with the given parameters
     * @param actor the actor whos state is to be defined (eg "actor0")
     * @param state the state of the actor that has changed (eg "handstogether")
     * @param active whether the state has become active or not;
     *               this means that true leads to the state being added as a new perception,
     *               while false leads to the state to be removed from the list of perceptions.
     * @return A BasicBSONObject to be sent (has to be encoded before)
     */
    public static BasicBSONObject createActorStateObject(String actor, String state, boolean active)
    {
        BasicBSONObject basicBSONObject = new BasicBSONObject();
        basicBSONObject.put("type", "actorstate");
        BasicBSONObject data = new BasicBSONObject();
        data.put("actorname", actor);
        data.put("statename", state);
        data.put("active", active);
        basicBSONObject.put("data", data);

        return basicBSONObject;
    }

    public static BasicBSONObject createActorScalingObject(String actor, float value)
    {
        BasicBSONObject basicBSONObject = new BasicBSONObject();
        basicBSONObject.put("type", "actorscaling");
        BasicBSONObject data = new BasicBSONObject();
        data.put("actorname", actor);
        data.put("scalingvalue", value);
        basicBSONObject.put("data", data);

        return basicBSONObject;
    }

    public static BasicBSONObject createAgentStateObject(String agent, String state, boolean active)
    {
        BasicBSONObject basicBSONObject = new BasicBSONObject();
        basicBSONObject.put("type", "agentstate");
        BasicBSONObject data = new BasicBSONObject();
        data.put("agentname", agent);
        data.put("statename", state);
        data.put("active", active);
        basicBSONObject.put("data", data);

        return basicBSONObject;
    }

    public static BasicBSONObject createAgentPositionObject(String agent, double x, double y, double z)
    {
        BasicBSONObject basicBSONObject = new BasicBSONObject();
        basicBSONObject.put("type", "agentposition");
        BasicBSONObject data = new BasicBSONObject();
        data.put("agentname", agent);
        data.put("x", x);
        data.put("y", y);
        data.put("z", z);
        data.put("forward_x", x);
        data.put("forward_y", y);
        data.put("forward_z", z + 1);
        basicBSONObject.put("data", data);

        return basicBSONObject;
    }


    public static BasicBSONObject createActorPositionObject(String actor, double x, double y, double z)
    {
        BasicBSONObject basicBSONObject = new BasicBSONObject();
        basicBSONObject.put("type", "actorposition");
        BasicBSONObject data = new BasicBSONObject();
        data.put("actorname", actor);
        data.put("x", x);
        data.put("y", y);
        data.put("z", z);
        data.put("forward_x", x);
        data.put("forward_y", y);
        data.put("forward_z", z + 1);
        basicBSONObject.put("data", data);

        return basicBSONObject;
    }

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) throws Exception {

        Parent root = FXMLLoader.load(getClass().getResource("simulator_v0.fxml"));
        primaryStage.setTitle("Simulator for Intraspace AI testing");
        primaryStage.setScene(new Scene(root));

        // as per http://www.java2s.com/Code/Java/JavaFX/Stagecloseevent.htm
        primaryStage.setOnCloseRequest(new EventHandler<WindowEvent>() {
            public void handle(WindowEvent we) {
                System.out.println("shutting down");
                BasicBSONObject basicBSONObject = new BasicBSONObject();
                basicBSONObject.put("type", "end");
                udpSender.Send(bsonEncoder.encode(basicBSONObject));

                System.exit(0);
            }
        });
        /*
        primaryStage.setHeight(530);
        primaryStage.setWidth(800);
        */
        //primaryStage.setResizable(false);
        primaryStage.sizeToScene();

        primaryStage.getIcons().add(new Image("file:res/blank.png"));
        //primaryStage.getIcons().add(new Image("file:res/icon.png"));

        primaryStage.show();
    }

    public int agent0x, agent0y, agent1x, agent1y, actor0x, actor0y, actor1x, actor1y;
    public MyToggleButton[][] buttons;
    public String agent0state, agent1state;
    public static UDPSender udpSender;
    public static BasicBSONEncoder bsonEncoder;

    public void updateLabels()
    {
        agent0label.setText("Agent 0, Pos: (" + agent0x + "," + agent0y + "), State: " + agent0state);
        agent1label.setText("Agent 1, Pos: (" + agent1x + "," + agent1y + "), State: " + agent1state);

        actor0label.setText("Actor 0, Pos: (" + actor0x + "," + actor0y + "), States:");
        actor1label.setText("Actor 1, Pos: (" + actor1x + "," + actor1y + "), States:");
    }

    ImageView none;
    ImageView actor0;
    ImageView actor1;
    ImageView agent0;
    ImageView agent1;
    ToggleGroup toggleGroup;

    ArrayList<String> actor0states;
    ArrayList<String> actor1states;

    @Override
    public void initialize(URL location, ResourceBundle resources) {

        none = new ImageView(new Image("file:res/none.png"));
        actor0 = new ImageView(new Image("file:res/actor0.png"));
        actor1 = new ImageView(new Image("file:res/actor1.png"));
        agent0 = new ImageView(new Image("file:res/agent0.png"));
        agent1 = new ImageView(new Image("file:res/agent1.png"));
        toggleGroup = new ToggleGroup();

        actor0states = new ArrayList<>();
        actor1states = new ArrayList<>();

        buttons = new MyToggleButton[10][10];

        agent0state = "idle";
        agent1state = "idle";

        agent0x = -10;
        agent0y = -10;
        agent1x = -10;
        agent1y = -10;
        actor0x = -1;
        actor0y = 0;
        actor1x = 0;
        actor1y = 0;

        updateLabels();

        //fieldVBox.getChildren().removeAll();
        for(int i = 9; i >=0; i--) {
            HBox hBox = new HBox();
            Separator separator = new Separator();
            separator.setOrientation(Orientation.VERTICAL);

            for(int j = 0; j < 10; j++)
            {
                MyToggleButton toggleButton = new MyToggleButton(none, j-5, i-5, toggleGroup);

                buttons[j][i] = toggleButton;
                //image2.setBlendMode(BlendMode.OVERLAY);

                //toggleButton.setGraphic(toggleImage);
                //toggleButton.setText("" + (j-5) + "," + (i-5));
                hBox.getChildren().add(toggleButton);
                if(j==4)
                {
                    hBox.getChildren().add(separator);
                }

                if(toggleButton.x == actor0x && toggleButton.y == actor0y)
                {
                    toggleButton.myGroup.getChildren().addAll(actor0);
                }
                if(toggleButton.x == actor1x && toggleButton.y == actor1y)
                {
                    toggleButton.myGroup.getChildren().addAll(actor1);
                }

            }

            fieldVBox.getChildren().add(hBox);

            if(i == 5)
            {
                separator = new Separator();
                separator.setOrientation(Orientation.HORIZONTAL);
                fieldVBox.getChildren().add(separator);
            }

        }

        try {
            udpSender = new UDPSender(REMOTE_ADDRESS, REMOTE_PORT);
        } catch (Exception e) {
            e.printStackTrace();
        }
        bsonEncoder = new BasicBSONEncoder();

        state_fromText.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                final String txt = state_textfield.getText();
                if(txt.equals(""))
                    return;
                if(buttons[actor0x+5][actor0y+5].isSelected())
                {
                    if(actor0states.contains(txt))
                        return;
                    actor0states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor0VBox.getChildren().addAll(button);

                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor0states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor0", txt, false)));
                            actor0VBox.getChildren().remove(button);
                        }
                    });

                }
                if(buttons[actor1x+5][actor1y+5].isSelected())
                {
                    if(actor1states.contains(txt))
                        return;
                    actor1states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor1VBox.getChildren().addAll(button);

                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor1states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor1", txt, false)));
                            actor1VBox.getChildren().remove(button);
                        }
                    });

                }
            }
        });

        state_bow.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                final String txt = "bow";
                if (buttons[actor0x + 5][actor0y + 5].isSelected()) {
                    actor0states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor0VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor0states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor0", txt, false)));
                            actor0VBox.getChildren().remove(button);
                        }
                    });
                }
                if (buttons[actor1x + 5][actor1y + 5].isSelected()) {
                    actor1states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor1VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor1states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor1", txt, false)));
                            actor1VBox.getChildren().remove(button);
                        }
                    });
                }
            }
        });

        state_hands.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                final String txt = "handstogether";
                if (buttons[actor0x + 5][actor0y + 5].isSelected()) {
                    actor0states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor0VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor0states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor0", txt, false)));
                            actor0VBox.getChildren().remove(button);
                        }
                    });
                }
                if (buttons[actor1x + 5][actor1y + 5].isSelected()) {
                    actor1states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor1VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor1states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor1", txt, false)));
                            actor1VBox.getChildren().remove(button);
                        }
                    });
                }
            }
        });


        state_wave.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                final String txt = "wave";
                if (buttons[actor0x + 5][actor0y + 5].isSelected()) {
                    actor0states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor0VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor0states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor0", txt, false)));
                            actor0VBox.getChildren().remove(button);
                        }
                    });
                }
                if (buttons[actor1x + 5][actor1y + 5].isSelected()) {
                    actor1states.add(txt);
                    final Button button = new Button(txt);
                    button.setMaxWidth(Double.MAX_VALUE);
                    actor1VBox.getChildren().addAll(button);
                    button.setOnAction(new EventHandler<ActionEvent>() {
                        @Override
                        public void handle(ActionEvent event) {
                            actor1states.remove(txt);
                            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor1", txt, false)));
                            actor1VBox.getChildren().remove(button);
                        }
                    });
                }
            }
        });

        move_actor0.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                Toggle toggle = toggleGroup.getSelectedToggle();
                if(toggle!=null && actor0moving == false)
                {
                    actor0moving = true;
                    MyToggleButton button = ((MyToggleButton) toggle);
//                    MoveThread moveThread = new MoveThread(0, button.x, button.y);
//                    Platform.runLater(moveThread);
                    moveActorTo(0, button.x, button.y);
                    //button.myGroup.getChildren().add(actor0);
                }
            }
        });

        move_actor1.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                Toggle toggle = toggleGroup.getSelectedToggle();
                if (toggle != null && actor1moving == false) {
                    actor1moving = true;
                    MyToggleButton button = ((MyToggleButton) toggle);
                    moveActorTo(1, button.x, button.y);
                    //((MyToggleButton)toggle).myGroup.getChildren().add(actor1);
                }
            }
        });


        state_startScaling.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                if (buttons[actor0x + 5][actor0y + 5].isSelected())
                {
                    try {
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor0", 0.0F)));
                        Thread.sleep(250);
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor0", 0.5F)));
                        Thread.sleep(250);
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor0", 1.0F)));
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    agent0x = -1;
                    agent0y = 0;
                    buttons[agent0x + 5][agent0y + 5].myGroup.getChildren().addAll(agent0);
                }
                if (buttons[actor1x + 5][actor1y + 5].isSelected()) {
                    try {
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor1", 0.0F)));
                        Thread.sleep(250);
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor1", 0.5F)));
                        Thread.sleep(250);
                        udpSender.Send(bsonEncoder.encode(createActorScalingObject("actor1", 1.0F)));
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    agent1x = 0;
                    agent1y = 0;
                    buttons[agent1x + 5][agent1y + 5].myGroup.getChildren().addAll(agent1);

                }
            }
        });


        myListenerThread mlt = new myListenerThread(this);
        mlt.start();

        Timeline tl = new Timeline(new KeyFrame(Duration.millis(100), new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                updateField();
                updateLabels();
                sendPositions();
                sendStates();
            }
        }));
        tl.setCycleCount(Timeline.INDEFINITE);
        tl.play();

    }


    public synchronized void moveAgentTo(final int agentID, final int x, final int y)
    {
        //System.out.println("moving: " + agentID + " to " + x + "," + y);
        if(agentID == 0)
        {
            agent0state = "move";

            if(agent0x > x)
                agent0x--;
            if(agent0x < x)
                agent0x++;
            if(agent0y > y)
                agent0y--;
            if(agent0y < y)
                agent0y++;
        }

        if(agentID == 1)
        {
            agent1state = "move";

            if(agent1x > x)
                agent1x--;
            if(agent1x < x)
                agent1x++;
            if(agent1y > y)
                agent1y--;
            if(agent1y < y)
                agent1y++;
        }

        if(agentID == 0 && agent0x == x && agent0y == y)
        {
            agent0state = "idle";
            return;
        }
        if(agentID == 1 && agent1x == x && agent1y == y)
        {
            agent1state = "idle";
            return;
        }

        Task<Void> sleeper = new Task<Void>() {
            @Override
            protected Void call() throws Exception {
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                }
                return null;
            }
        };
        sleeper.setOnSucceeded(new EventHandler<WorkerStateEvent>() {
            @Override
            public void handle(WorkerStateEvent event) {
                moveAgentTo(agentID, x, y);
            }
        });
        new Thread(sleeper).start();
    }

    // cheap thread synching bc method sync no work
    public boolean actor0moving = false, actor1moving = false;

        public synchronized void moveActorTo(final int actorID, final int x, final int y)
        {
            //System.out.println("moving actor" + actorID + " to "  + x + "," + y);

                if (actorID == 0) {
                    if(actor0x > x)
                        actor0x--;
                    if(actor0x < x)
                        actor0x++;
                    if(actor0y > y)
                        actor0y--;
                    if(actor0y < y)
                        actor0y++;

                    if(agent0state.equals("live"))
                    {
                        agent0x = actor0x;
                        agent0y = actor0y;
                    }
                }

            if (actorID == 1) {
                if(actor1x > x)
                    actor1x--;
                if(actor1x < x)
                    actor1x++;
                if(actor1y > y)
                    actor1y--;
                if(actor1y < y)
                    actor1y++;

                if(agent1state.equals("live"))
                {
                    agent1x = actor1x;
                    agent1y = actor1y;
                }
            }

            if(actorID == 0 && actor0x == x && actor0y == y)
            {
                actor0moving = false;
                return;
            }
            if(actorID == 1 && actor1x == x && actor1y == y)
            {
                actor1moving = false;
                return;
            }

            Task<Void> sleeper = new Task<Void>() {
                @Override
                protected Void call() throws Exception {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                    }
                    return null;
                }
            };
            sleeper.setOnSucceeded(new EventHandler<WorkerStateEvent>() {
                @Override
                public void handle(WorkerStateEvent event) {
                    moveActorTo(actorID, x, y);
                }
            });
            new Thread(sleeper).start();
        }

    public void updateField()
    {
        if(agent0x  > -6 && !buttons[agent0x+5][agent0y+5].myGroup.getChildren().contains(agent0))
            buttons[agent0x+5][agent0y+5].myGroup.getChildren().addAll(agent0);
        if(agent1x  > -6 && !buttons[agent1x+5][agent1y+5].myGroup.getChildren().contains(agent1))
            buttons[agent1x+5][agent1y+5].myGroup.getChildren().addAll(agent1);
        if(!buttons[actor0x+5][actor0y+5].myGroup.getChildren().contains(actor0))
            buttons[actor0x+5][actor0y+5].myGroup.getChildren().addAll(actor0);
        if(!buttons[actor1x+5][actor1y+5].myGroup.getChildren().contains(actor1))
            buttons[actor1x+5][actor1y+5].myGroup.getChildren().addAll(actor1);
    }

    public void sendPositions()
    {
        udpSender.Send(bsonEncoder.encode(createActorPositionObject("actor0", actor0x, 0, actor0y)));
        udpSender.Send(bsonEncoder.encode(createActorPositionObject("actor1", actor1x, 0, actor1y)));
        udpSender.Send(bsonEncoder.encode(createAgentPositionObject("agent0", agent0x, 0, agent0y)));
        udpSender.Send(bsonEncoder.encode(createAgentPositionObject("agent1", agent1x, 0, agent1y)));
    }

    public void sendStates()
    {
        udpSender.Send(bsonEncoder.encode(createAgentStateObject("agent0", agent0state, true)));
        udpSender.Send(bsonEncoder.encode(createAgentStateObject("agent1", agent1state, true)));

        for(String s : actor0states)
        {
            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor0", s, true)));
        }

        for(String s : actor1states)
        {
            udpSender.Send(bsonEncoder.encode(createActorStateObject("actor1", s, true)));
        }
    }

    private class MyToggleButton extends ToggleButton
    {
        public ImageView blank;//, agent0, agent1, actor0, actor1;
        public Group myGroup;
        public int x, y;


        public MyToggleButton(ImageView _blank, int _x, int _y, ToggleGroup _toggleGroup)
        {
            super();
            this.x = _x;
            this.y = _y;
            this.blank = _blank;

            this.setToggleGroup(_toggleGroup);
            this.setPrefSize(50, 50);

            myGroup = new Group(blank);
            this.setGraphic(myGroup);
        }
    }

    Calendar cal = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");

    public void alog(String log)
    {
        cal = Calendar.getInstance();
        log = sdf.format(cal.getTime()) + ": " + log;
        this.agent_actionlog.appendText(log + "\n");
    }

    public void sync(String agentName)
    {
        if(agentName.equals("agent0"))
        {
            moveAgentTo(0, actor0x, actor0y);

            do {
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }while(!agent0state.equals("idle"));
            agent0state = "live";
        }
        if(agentName.equals("agent1"))
        {
            moveAgentTo(1, actor1x, actor1y);
            do {
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }while(!agent1state.equals("idle"));
            agent1state = "live";
        }
    }

    private class myListenerThread extends Thread
    {
        private udp_simulator father;
           public myListenerThread(udp_simulator _father)
           {
               super();
               this.father = _father;
           }

        @Override
        public void run()
        {
            try
            {
                UDPListenerThread udpListenerThread = new UDPListenerThread(LISTEN_PORT);
                BSONListener bsonListener = new BSONListener(udpListenerThread);
                udpListenerThread.start();

            while(true) {
                BsonDocument input = bsonListener.GetNextBsonObject();

                if (input != null) {
                    String type = input.getString("type", null).getValue();
                    BsonDocument data = input.getDocument("data", null);

                    if (type != null && data != null) {
                        switch (type) {
                            case "ready" :
                            {
                                System.out.println("Got ready from AI. Starting.");

                                BasicBSONObject basicBSONObject = new BasicBSONObject();
                                basicBSONObject.put("type", "scenario");
                                BasicBSONObject dat = new BasicBSONObject();
                                dat.put("name", SCN);
                                basicBSONObject.put("data", dat);
                                udpSender.Send(bsonEncoder.encode(basicBSONObject));

                                Thread.sleep(300);

                                basicBSONObject = new BasicBSONObject();
                                basicBSONObject.put("type", "start");
                                udpSender.Send(bsonEncoder.encode(basicBSONObject));

                                Thread.sleep(300);

                                basicBSONObject = new BasicBSONObject();
                                basicBSONObject.put("type", "camerainfo");
                                dat = new BasicBSONObject();
                                dat.put("camera_x", 0F);
                                dat.put("camera_y", 0F);
                                dat.put("camera_z", -5F);
                                dat.put("camera_forward_x", 0F);
                                dat.put("camera_forward_y", 0F);
                                dat.put("camera_forward_z", 1F);
                                dat.put("screenwidth", 10F);
                                basicBSONObject.put("data", dat);
                                udpSender.Send(bsonEncoder.encode(basicBSONObject));

                                break;
                            }
                            case "agentaction": {
                                String agentName = data.getString("agentname").getValue();
                                String actionTerm = data.getString("actionterm").getValue();

                                agentName = "agent" + (Character.getNumericValue(agentName.charAt(agentName.length()- 1)) /*- 1*/);

//                                System.out.println("Got: " + agentName + ":" + actionTerm);
                                father.alog(agentName + ":" + actionTerm);

                                if(actionTerm.contains("moveTo"))
                                {
                                    String[] values = actionTerm.split(",|\\(|\\)");
                                    //System.out.println("values: " + Arrays.toString(values));
                                    int x = (int)Float.parseFloat(values[1]);
                                    int y = (int)Float.parseFloat(values[2]);

                                    if(x > 4)
                                        x=4;
                                    if(x < -5)
                                        x=-5;
                                    if(y>4)
                                        y=4;
                                    if(y<-5)
                                        y=-5;
                                    father.moveAgentTo((Character.getNumericValue(agentName.charAt(agentName.length() - 1))), x, y);


                                } else if(actionTerm.contains("switchToLive"))
                                {
                                    sync(agentName);
                                } else if(actionTerm.contains("switchToIdle"))
                                {
                                    if(agentName.equals("agent0"))
                                        agent0state = "idle";
                                    if(agentName.equals("agent1"))
                                        agent1state = "idle";

                                } else if(actionTerm.contains("playanimation"))
                                {
                                    if(agentName.equals("agent0"))
                                        agent0state = "action";
                                    if(agentName.equals("agent1"))
                                        agent1state = "action";

                                    Thread.sleep(2000);

                                    if(agentName.equals("agent0"))
                                        agent0state = "idle";
                                    if(agentName.equals("agent1"))
                                        agent1state = "idle";
                                }

                                break;
                            }
                            case "scenario" :
                                break;
                            default: {
                                System.out.println("Got this: " + input.toString() + "\nDont know what do.");
                                break;
                            }


                        }
                    }
                } else {
                    //System.out.println("zzz");
                    Thread.sleep(50);
                }

            }
            }catch (Exception e)
            {
                e.printStackTrace();
            }
        }
    }
}
