SiriProxy-Plex
==

About
--

Voice control for Plex.

Voice Commands
--

+ play "show"
+ play latest episode of "show"
+ play the next episode of "show"
+ on deck tv shows
+ play a random on deck tv show
+ play a random episode of "show"

+ play the movie "movie"
+ on deck movies
+ play a random on deck movie
+ play a random unwatched movie
+ play a random movie

+ pause movie/tv/show/plex
+ resume movie/tv/show/plex
+ stop movie/tv/show/plex

+ Add new Plex player
+ Switch current Plex player to "player"


Installation
--

1. Add the following, using your IP, port and indexes to your .siriproxy/config.yml file    
		\- name: 'Plex'    
		   git: 'git://github.com/whoismezero/SiriProxy-Plex.git'    
		   plex_host: '0.0.0.0' #Internal IP address of your Plex Media Server.    
		   plex_port: '32400' #Most likely you won't have to change this, it runs on port 32400 by default.    
		   plex_tv_index: '2' #This is the path to your TV index within PMS, set to 'auto' for autodetect.        
		   plex_movie_index: '1' #This is the path to your Movie index within PMS, set to 'auto' for autodetect.       


2. Run bundler from your siriproxy root directory
	* siriproxy bundle

3. Start siriproxy and test
	* rvmsudo siriproxy server

4. Add at least one Plex player
	* "Add new Plex player"

5. Set a Plex as the one in use
	* "Switch current Plex player to (player)"

FAQ
--

1. How do I find my index(es)?
	* browse to: http://<your PMS server IP:32400/library/sections
	* View page source
	* Find the key for title of your your TV or Movie index
		Directory refreshing="0"  **key="1"** type="show" title="TV" art="/:/resources/show-fanart.jpg" agent="com.plexapp.agents.thetvdb"
