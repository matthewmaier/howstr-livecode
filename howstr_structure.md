# Howstr_Structure

## Structure
* Howstr
  * software
    * presentation
      * translate graph data into displayed objects
      * define user gestures to track
      * map user gestures to commands
      * send commands to logic
    * logic
      * apply commands to in-memory graph data
      * convert between in-memory and on-disk as necessary
      * push most current version of latest data to presentation
      * 
    * data
      * in-memory arrays stored as JSON-formatted text files
      * worth evaluating databases as an alternative
        * graph database for graph data?
        * relational database for attachments?
  * configuration
    * presentation color scheme
    * choices each individual user made in each model
    * general user preferences
    * gesture-command maps
    * NotionAll schema
  * content
    * models stored on-disk as data
  * logs

## References
https://en.wikipedia.org/wiki/Business_logic#/media/File:Overview_of_a_three-tier_application_vectorVersion.svg
http://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/software.html
