state("FTLGame")
{
	int sector : 0x4C5C00;
	int isGameStarted : 0x004C5498, 0x7B4, 0x6e4;
	int isGameOver : 0x4C5C3C;
}

startup
{
    // run when the script first loads, add settings here
	Action<string> DebugOutput = (text) => {
		print("[FTL autosplit:] "+text);
	};
	vars.DebugOutput = DebugOutput;
}

init
{
    timer.IsGameTimePaused = false;
	game.Exited += (s, e) => timer.IsGameTimePaused = true;
}

exit
{
    timer.IsGameTimePaused = true;
}

start
{	
	if (old.isGameStarted == 0 && current.isGameStarted == 1 && current.sector == 1) {
		vars.DebugOutput("Timer started");
		return true;
	}
	return false;
}

reset
{
   return old.isGameStarted == 0 && current.isGameStarted == 1;
}

split
{

	if (old.sector == 0)
	{
		// Game starting
		return;
	}
	if (current.sector == old.sector+1)
	{
		print("Split sector: "+current.sector.ToString());
		return true;
	}
}

isLoading
{
    return current.isGameStarted == 0 || current.isGameOver == 1;
}
