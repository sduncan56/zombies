import com.electrotank.electroserver4.extensions.ChainAction;
import com.electrotank.electroserver4.extensions.api.ScheduledCallback;
import com.electrotank.electroserver4.extensions.api.PluginApi;
import com.electrotank.electroserver4.extensions.api.value.EsObject;
import com.electrotank.electroserver4.extensions.api.value.EsObjectRO;
import com.electrotank.electroserver4.extensions.api.value.UserEnterContext;
import com.electrotank.electroserver4.extensions.api.value.UserPublicMessageContext;
import com.electrotank.electroserver4.extensions.BasePlugin;

import java.util.Vector;
import java.util.Random;
import java.util.Date;

public class ZombiePlugin extends BasePlugin
{
	private int numPlayers;
	private String [] playerNames;
	private String [] confirmedNames;
	private boolean [] allDead;
	private int [] scores;
	private int [] positionsX;
	private int [] positionsY;
	private int [] velocitiesX;
	private int [] velocitiesY;
	private Vector<String> collisions;
	private int gameState;
	private Vector<Zombie> zombies;
	private int numOfZombies;

	private int startX;
	private int startY;
	private int startOffset;

	private Random randomNums;

	private Date time;
	private long lastTime;

	private int id;


	public int maxPlayers;

    //not related to the networking
	public static final int UPDATE_DURATION                                  = 50;
	public static final int MAP_WIDTH                                        = 2400;
	public static final int MAP_HEIGHT                                       = 2400;
	public static final int MIN_ZOMBIES                                      = 30;
	public static final int TILE_SIZE                                        = 16;

	public static final int STATE_WAITING  				   					 = 0;
	public static final int STATE_CONFIRM                                    = 1;
  	public static final int STATE_IN_PLAY  				   					 = 2;
  	public static final int STATE_GAME_OVER				   					 = 3;

  	public static final int ACTION_SETUPGAME 			   					 = 0;
  	public static final int ACTION_CONFIRMSETUP                              = 1;
  	public static final int ACTION_UPDATEGAME                                = 2;
  	public static final int ACTION_UPDATEPLAYERS                             = 3;
  	public static final int ACTION_UPDATEZOMBIES                             = 4;
  	public static final int ACTION_UPDATETIME                                = 5;

  	public static final String TAG_PLAYERNAME			   					 = "playername";
  	public static final String TAG_MESSAGETYPE			   					 = "messagetype";


  	public static final String TAG_PLAYERS                                   = "players";
  	public static final String TAG_CONFIRMSETUP                              = "confirmsetup";

  	//all players
  	public static final String TAG_POSITIONSX                                = "positionsx";
  	public static final String TAG_POSITIONSY                                = "positionsy";
  	public static final String TAG_VELOCITIESX                               = "velocitiesx";
  	public static final String TAG_VELOCITIESY                               = "velocitiesy";
  	public static final String TAG_SCORES                                    = "scores";
  	public static final String TAG_ALLDEAD                                   = "alldead";

  	//individual
  	public static final String TAG_POSX                                      = "posx";
  	public static final String TAG_POSY                                      = "posy";
  	public static final String TAG_VELOCITYX                                 = "velocityx";
  	public static final String TAG_VELOCITYY                                 = "velocityy";
  	public static final String TAG_SCORE                                     = "score";
  	public static final String TAG_DEAD                                      = "dead";

  	//zombies
  	public static final String TAG_ZOMBIESX                                  = "zombiesx";
  	public static final String TAG_ZOMBIESY                                  = "zombiesy";
  	public static final String TAG_ZOMBVELSX                                 = "zombvelsx";
  	public static final String TAG_ZOMBVELSY                                 = "zombvelsy";

  	public static final String TAG_ZOMBIESHEALTH                             = "zombieshealth";
  	public static final String TAG_ZOMBIESCANSEE                             = "zombiescansee";
  	public static final String TAG_ZOMBNEARESTPLAYERX                        = "zombnearestplayerx";
  	public static final String TAG_ZOMBNEARESTPLAYERY                        = "zombnearestplayery";

  	public static final String TAG_SERVERTIME                                = "servertime";

  	public static final String TAG_COLLISIONS                                = "collisions";





	@Override
	public void init(EsObjectRO info)
	{
		maxPlayers = 2;
		numPlayers = 0;
		playerNames = new String[maxPlayers];
		confirmedNames = new String[maxPlayers];
		allDead = new boolean[maxPlayers];
		scores = new int[maxPlayers];
		positionsX = new int[maxPlayers];
		positionsY = new int[maxPlayers];
		velocitiesX = new int[maxPlayers];
		velocitiesY = new int[maxPlayers];
		collisions = new Vector();
		zombies = new Vector();

		numOfZombies = 0;

		startX = MAP_WIDTH/2;
		startY = MAP_HEIGHT/2;
		startOffset = 30;

		randomNums = new Random();

		time = new Date();
		lastTime = time.getTime();

        id = getApi().scheduleExecution(UPDATE_DURATION, -1, new ScheduledCallback() {
        	public void scheduledCallback()
        	{
        		updateGame();
        	}
        });

	}

	@Override
	public ChainAction userEnter(UserEnterContext context)
	{
		if (numPlayers < 2)
		{
			playerNames[numPlayers] = context.getUserName();
			numPlayers++;


			attemptToStartGame();

		}
		return ChainAction.OkAndContinue;
	}

  	public void attemptToStartGame()
  	{
  	    if(numPlayers == 2 && gameState == STATE_WAITING)
  		{

  			 startGame();
  		}
  	}

    public void startGame()
    {
        getApi().setGameLockState(true);


    	for (int i = 0; i < numPlayers; i++)
    	{
    		positionsX[i] = startX;
    		positionsY[i] = startY;
    		velocitiesX[i] = 0;
    		velocitiesY[i] = 0;

    		startX += startOffset;
    	}

        sendInitData();

    	gameState = STATE_CONFIRM;

    }

    public void sendInitData()
    {
    	EsObject message = new EsObject();

    	message.setInteger( TAG_MESSAGETYPE, ACTION_SETUPGAME);

    	message.setIntegerArray(TAG_POSITIONSX, positionsX);
        message.setIntegerArray(TAG_POSITIONSY, positionsY);
    	message.setStringArray(TAG_PLAYERS, playerNames);

    	getApi().sendPluginMessageToRoom(getApi().getZoneId(), getApi().getRoomId(), message);
    }

    @Override
    public final void request(String playerName, EsObjectRO requestParameters)
    {
    	if (gameState == STATE_CONFIRM)
    	{
    		if (requestParameters.getInteger(TAG_MESSAGETYPE) == ACTION_CONFIRMSETUP)
    		{
    	    	for (int i = 0; i < playerNames.length; i++)
    		    {
    			    if (playerNames[i] == playerName)
    			    {
    				    confirmedNames[i] = playerName;
    			    }
    		    }
    		}


    		Boolean canStart = true;

   		    for (int i = 0; i < confirmedNames.length; i++)
    		{
    			if (confirmedNames[i] == null)
    			{
    			    canStart = false;
    			}
    		}

    		if (canStart)
    		{
    			gameState = STATE_IN_PLAY;
    		}
    	}

    	if (gameState == STATE_IN_PLAY)
    	{
    		if (requestParameters.getInteger(TAG_MESSAGETYPE) == ACTION_UPDATEPLAYERS)
    		{
    	    	for (int i = 0; i < playerNames.length; i++)
    		    {
    			    if (playerNames[i] == playerName)
    			    {
    				    positionsX[i] = requestParameters.getInteger(TAG_POSX);
    				    positionsY[i] = requestParameters.getInteger(TAG_POSY);
    				    velocitiesX[i] = requestParameters.getInteger(TAG_VELOCITYX);
    				    velocitiesY[i] = requestParameters.getInteger(TAG_VELOCITYY);

                        allDead[i] = requestParameters.getBoolean(TAG_DEAD);
    				    scores[i] = requestParameters.getInteger(TAG_SCORE);


    			    }
    		    }
    		}
    		if (requestParameters.getInteger(TAG_MESSAGETYPE) == ACTION_UPDATEZOMBIES)
    		{
    		    int[] zombiesHealth = new int[zombies.size()];
    		    boolean[] canSees = new boolean[zombies.size()];
    		    int[] nearestPlayersX = new int[zombies.size()];
    		    int[] nearestPlayersY = new int[zombies.size()];

    			zombiesHealth = requestParameters.getIntegerArray(TAG_ZOMBIESHEALTH);
    			canSees = requestParameters.getBooleanArray(TAG_ZOMBIESCANSEE);
    			nearestPlayersX = requestParameters.getIntegerArray(TAG_ZOMBNEARESTPLAYERX);
    			nearestPlayersY = requestParameters.getIntegerArray(TAG_ZOMBNEARESTPLAYERY);


    			for (int i = 0; i < zombies.size(); i++)
    			{

    				int health = zombiesHealth[i];

    				if (health < zombies.get(i).getHealth())
    				{
    					zombies.get(i).setHealth(health);
    				}


    				if (canSees[i])
    				{
    					zombies.get(i).setCanSee(true);
    					zombies.get(i).setNearestPlayer(nearestPlayersX[i], nearestPlayersY[i]);
    				}
    				else
    				{
    					zombies.get(i).setCanSee(false);
    				}

    			}
    		}
    		if (requestParameters.getInteger(TAG_MESSAGETYPE) == ACTION_UPDATETIME)
    		{
    			updateTime(playerName);
    		}


    	}
    }

    public void updateGame()
    {
    	EsObject message = new EsObject();

        if (gameState == STATE_CONFIRM)
        {
        	sendInitData();
        }
    	if (gameState == STATE_IN_PLAY)
    	{
    		updatePlayState();
    		float[] zombiesX = new float[zombies.size()];
    		float[] zombiesY = new float[zombies.size()];
    		float[] zombVelsX = new float[zombies.size()];
    		float[] zombVelsY = new float[zombies.size()];
    		float[] zombiesHealth = new float[zombies.size()];

    		zombiesX = fillZombieArray(1);
    		zombiesY = fillZombieArray(2);
    		zombVelsX = fillZombieArray(3);
    		zombVelsY = fillZombieArray(4);
    		zombiesHealth = fillZombieArray(5);

    		message.setInteger(TAG_MESSAGETYPE, ACTION_UPDATEGAME);
    	    message.setIntegerArray(TAG_POSITIONSX, positionsX);
    	    message.setIntegerArray(TAG_POSITIONSY, positionsY);
    	    message.setIntegerArray(TAG_VELOCITIESX, velocitiesX);
    	    message.setIntegerArray(TAG_VELOCITIESY, velocitiesY);
    	    message.setBooleanArray(TAG_ALLDEAD, allDead);
    	    message.setIntegerArray(TAG_SCORES, scores);

    	    message.setFloatArray(TAG_ZOMBIESX, zombiesX);
    	    message.setFloatArray(TAG_ZOMBIESY, zombiesY);
    	    message.setFloatArray(TAG_ZOMBVELSX, zombVelsX);
    	    message.setFloatArray(TAG_ZOMBVELSY, zombVelsY);
    	    message.setFloatArray(TAG_ZOMBIESHEALTH, zombiesHealth);

    	    String[] cols = new String[collisions.size()];
    	    collisions.toArray(cols);

    	    message.setStringArray(TAG_COLLISIONS, cols);
    	}



        getApi().sendPluginMessageToRoom(getApi().getZoneId(), getApi().getRoomId(), message);
    }

    public void gameOver()
    {
        getApi().cancelScheduledExecution(id);

    	gameState = STATE_GAME_OVER;
    	getApi().setGameLockState(false);

    }

    public void updateTime(String player)
    {
    	EsObject message = new EsObject();

        message.setInteger(TAG_MESSAGETYPE, ACTION_UPDATETIME);
        //System.out.println(System.currentTimeMillis());
    	message.setString(TAG_SERVERTIME, Long.toString(System.currentTimeMillis()));
    	getApi().sendPluginMessageToUser(player, message);
    }

    public boolean detectCollision(int left1, int top1, int left2, int top2)
    {

    	int right1, right2;
    	int bottom1, bottom2;

    	right1 = left1+TILE_SIZE;
    	right2 = left2+TILE_SIZE;
    	bottom1 = top1+TILE_SIZE;
    	bottom2 = top2+TILE_SIZE;

    	if (bottom1 < top2) return false;
    	if (top1 > bottom2) return false;
    	if (right1 < left2) return false;
    	if (left1 > right2) return false;

    	return true;
    }


    public void updatePlayState()
    {
    	for (int i = 0; i < numPlayers; i++)
    	{
    		if (allDead[i] == true)
    		{
    			gameOver();
    			return;
    		}
    	}

    	if (zombies.size() < MIN_ZOMBIES)
    	{
    		int zombiesNeeded = MIN_ZOMBIES-zombies.size();

    		for (int i = zombiesNeeded; i > 0; i--)
    		{
    			generateZombie();
    		}
    	}

    	long timeDiff = System.currentTimeMillis() - lastTime;
    	lastTime += timeDiff;

    	//System.out.println(time.getTime());
    	//System.out.println(lastTime);

        collisions.removeAllElements();

    	float[] zombiesX = new float[zombies.size()];
    	float[] zombiesY = new float[zombies.size()];
    	zombiesX = fillZombieArray(1);
    	zombiesY = fillZombieArray(2);

    	for (int i = 0; i < zombies.size(); i++)
    	{
    		for (int j = 0; j < numPlayers; j++)
    		{
    			zombies.get(i).checkNearestPlayer(positionsX[j], positionsY[j]);
    			if (detectCollision(positionsX[j], positionsY[j], (int)zombiesX[i], (int)zombiesY[i]))
    			{
    				collisions.add(zombies.get(i).getNumber()+"-"+playerNames[j]);
    			}
    		}



    		zombies.get(i).determineDirection();
    		zombies.get(i).updatePos(timeDiff);
    	}
    }

    public void generateZombie()
    {
    	int randX = randomNums.nextInt(MAP_WIDTH);
    	int randY = randomNums.nextInt(MAP_HEIGHT);

    	numOfZombies++;

    	int dirFrom = randomNums.nextInt(3);
    	switch(dirFrom)
    	{
    		case 0:
    		    zombies.add(new Zombie(randX, 0, numOfZombies));
    		    break;
    		case 1:
    			zombies.add(new Zombie(0, randY, numOfZombies));
    			break;
    		case 2:
    			zombies.add(new Zombie(randX, MAP_HEIGHT, numOfZombies));
    			break;
    		case 3:
    			zombies.add(new Zombie(MAP_WIDTH, randY, numOfZombies));
    			break;
    	}
    }

    public float[] fillZombieArray(int val)
    {
    	float[] zombArray = new float[zombies.size()];
    	for (int i = 0; i < zombies.size(); i++)
    	{
    		switch(val)
    		{
    			case 1:
    				zombArray[i] = zombies.get(i).getX();
    				break;
    			case 2:
    				zombArray[i] = zombies.get(i).getY();
    				break;
    			case 3:
    				zombArray[i] = zombies.get(i).getXVel();
    				break;
    			case 4:
    				zombArray[i] = zombies.get(i).getYVel();
    				break;
    			case 5:
    				zombArray[i] = (float)zombies.get(i).getHealth();
    				break;
    		}

    	}

        return zombArray;
    }


}
