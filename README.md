SiriProxy-Plex
==

About
--

Voice control for Plex.  Includes support for playing latest version of a specific show, show by season/episode, and onDeck.

Voice Commands
--

+ play "show"
+ play latest episode of "show"
+ play the next episode of "show"
+ on deck tv shows
+ on deck movies


Installation
--

1. Add the following, using your IP, Port and Index to your ~siriproxy/config.yml file    
		\- name: 'Plex'    
		   git: 'git://github.com/hjaltij/SiriProxy-Plex.git'    
		   plex_host: '0.0.0.0' #Internal IP address of your Plex Media Server.    
		   plex_port: '32400' #Most likely you won't have to change this, it runs on port 32400 by default.    
		   plex_tv_index: '2' #This is the path to your TV index within PMS, set to 'auto' for autodetect.        
           plex_movie_index: '1' #This is the path to your Movie index within PMS

		   
2. Run bundler from your siriproxy root directory
	* siriproxy bundle
3. Start siriproxy and test
	* rvmsudo siriproxy server

FAQ
--

1. After I say "on deck" siri just spins and does nothing
	There can be a number of reasons this happens but it basically means PMS didn't return any shows from onDeck.
	* Make sure your PMS server IP and port are correct in config.yml
	* Make sure you have the correct plex_tv_index set.
	* Verify in Plex that something is actually "on deck" 
	 
2. How do I find my TV index?
	* browse to: http://<your PMS server IP:32400/library/sections
	* View page source
	* Find the key for title of your your TV index
		Directory refreshing="0"  **key="1"** type="show" title="TV" art="/:/resources/show-fanart.jpg" agent="com.plexapp.agents.thetvdb"

Recent Updates
--------------
**8-Dec-2011**
+       Added this README.md with "Voice Commands" section to help identify conflicts with other plugins.
+       Added message "Couldn't find anything in on deck queue" when onDeck is empty


**9-Dec-2011**
+       Added support for multiple TV sections: set by using 'auto' for plex_tv_index in config.yml

