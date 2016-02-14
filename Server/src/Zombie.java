/**
 * @(#)Zombie.java
 *
 *
 * @author
 * @version 1.00 2010/5/14
 */

import java.awt.Point;


public class Zombie {

	private boolean canSeePlayer;
	private float x, y;
	private float xVel, yVel;
	private Point nearestPlayer;
	private float movementSpeed;
	private int number;
	private int health;
	private Boolean dead;


    public Zombie(int X, int Y, int zombNum)
    {
    	canSeePlayer = false;
    	x = X;
    	y = Y;
    	number = zombNum;
    	movementSpeed = 0.1f;

    	health = 5;

    	xVel = 0;
    	yVel = 0;

    	dead = false;

    	nearestPlayer = new Point();

    	//System.out.println("Zombie number: " + number);
        //System.out.println("%d, %d,", x, y);
    }

    public void updatePos(long timeDiff)
    {
    	x += (int)timeDiff*xVel;
    	y += (int)timeDiff*yVel;
    //	System.out.println(timeDiff);
    	//System.out.println("Zombie number: " + number);
    	//System.out.println(x + "," + y);

    }

    public void checkNearestPlayer(int pX, int pY)
    {
    	if (nearestPlayer.x == -1 || nearestPlayer.y == -1)
    	{
    		nearestPlayer.x = pX;
    		nearestPlayer.y = pY;
    	}
    	else if (pX < nearestPlayer.x && pY < nearestPlayer.y)
    	{
    		nearestPlayer.x = pX;
    		nearestPlayer.y = pY;
    	}
    	System.out.println("Zombie number: " + number);
    	System.out.println(nearestPlayer.x + " " + nearestPlayer.y);

    }

    public void determineDirection()
    {
    	if (canSeePlayer)
    	{
    		xVel = 0;
    		yVel = 0;

    		if (x < nearestPlayer.x)
    		{
    			xVel = movementSpeed;
    		}
    		else if (x > nearestPlayer.x)
    		{
    			xVel = -movementSpeed;
    		}
    		if (y < nearestPlayer.y)
    		{
    			yVel = movementSpeed;
    		}
    		else if (y > nearestPlayer.y)
    		{
    			yVel = -movementSpeed;
    		}
    	}

    }

    public float getX()
    {
    	return x;
    }

    public float getY()
    {
    	return y;
    }

    public float getXVel()
    {
    	return xVel;
    }

    public float getYVel()
    {
    	return yVel;
    }

    public int getHealth()
    {
    	return health;
    }

    public int getNumber()
    {
    	return number;
    }

    public void setHealth(int h)
    {
    	health = h;
    	if (health <= 0)
    	{
    		dead = true;
    	}
    }

    public void setCanSee(Boolean see)
    {
    	canSeePlayer = see;
    }

    public void setNearestPlayer(int x, int y)
    {
    	nearestPlayer.x = x;
    	nearestPlayer.y = y;
    }


}